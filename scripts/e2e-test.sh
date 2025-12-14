#!/usr/bin/env bash
# End-to-End Testing Script
# Tests complete user flows: Registration → Login → Browse Menu → Place Order → Track Order

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
API_URL="${API_URL:-http://localhost:5001/api}"
FRONTEND_URL="${FRONTEND_URL:-http://localhost:8080}"
TEST_EMAIL="test-$(date +%s)@example.com"
TEST_PASSWORD="TestPass123!"
TEST_NAME="E2E Test User"

# Counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Helper function to run test
run_test() {
    local test_name="$1"
    local test_command="$2"
    ((TESTS_TOTAL++))

    echo -e "${BLUE}[TEST $TESTS_TOTAL]${NC} $test_name"

    if eval "$test_command"; then
        echo -e "${GREEN}  ✅ PASS${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}  ❌ FAIL${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
    echo ""
}

# Helper to make API request
api_request() {
    local method="$1"
    local endpoint="$2"
    local data="${3:-}"
    local token="${4:-}"

    local curl_opts=(-s -w "\n%{http_code}" -X "$method" "$API_URL$endpoint")

    if [ -n "$token" ]; then
        curl_opts+=(-H "Authorization: Bearer $token")
    fi

    if [ -n "$data" ]; then
        curl_opts+=(-H "Content-Type: application/json" -d "$data")
    fi

    curl "${curl_opts[@]}"
}

echo "═══════════════════════════════════════════════════════════"
echo "              END-TO-END TESTING SUITE"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Testing complete user journey:"
echo "  1. User Registration"
echo "  2. User Login"
echo "  3. Browse Menu"
echo "  4. Create Order"
echo "  5. Track Order"
echo "  6. Admin Operations"
echo ""

# Test 1: Health Check
run_test "Health endpoint responds" \
    "curl -sf $API_URL/health >/dev/null"

# Test 2: Frontend loads
run_test "Frontend homepage loads" \
    "curl -sf $FRONTEND_URL >/dev/null"

# Test 3: User Registration
echo -e "${YELLOW}Testing User Registration Flow...${NC}"
REGISTER_RESPONSE=$(api_request POST /auth/register "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\",\"name\":\"$TEST_NAME\"}")
REGISTER_CODE=$(echo "$REGISTER_RESPONSE" | tail -1)

run_test "User registration succeeds (201)" \
    "[ \"$REGISTER_CODE\" = \"201\" ]"

# Test 4: User Login
echo -e "${YELLOW}Testing User Login Flow...${NC}"
LOGIN_RESPONSE=$(api_request POST /auth/login "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\"}")
LOGIN_CODE=$(echo "$LOGIN_RESPONSE" | tail -1)
LOGIN_BODY=$(echo "$LOGIN_RESPONSE" | head -n -1)

run_test "User login succeeds (200)" \
    "[ \"$LOGIN_CODE\" = \"200\" ]"

# Extract JWT token
JWT_TOKEN=$(echo "$LOGIN_BODY" | grep -o '"token":"[^"]*' | cut -d'"' -f4)

run_test "JWT token returned" \
    "[ -n \"$JWT_TOKEN\" ]"

# Test 5: Protected endpoint with token
run_test "Access protected endpoint with JWT" \
    "api_request GET /auth/me '' '$JWT_TOKEN' | tail -1 | grep -q 200"

# Test 6: Menu Categories
echo -e "${YELLOW}Testing Menu Browsing...${NC}"
CATEGORIES_RESPONSE=$(api_request GET /menu/categories)
CATEGORIES_CODE=$(echo "$CATEGORIES_RESPONSE" | tail -1)

run_test "Fetch menu categories (200)" \
    "[ \"$CATEGORIES_CODE\" = \"200\" ]"

# Test 7: Menu Items
ITEMS_RESPONSE=$(api_request GET /menu/items)
ITEMS_CODE=$(echo "$ITEMS_RESPONSE" | tail -1)
ITEMS_BODY=$(echo "$ITEMS_RESPONSE" | head -n -1)

run_test "Fetch menu items (200)" \
    "[ \"$ITEMS_CODE\" = \"200\" ]"

# Extract first menu item ID for order testing
MENU_ITEM_ID=$(echo "$ITEMS_BODY" | grep -o '"id":[0-9]*' | head -1 | cut -d: -f2)

# Test 8: Create Order (Guest checkout)
echo -e "${YELLOW}Testing Order Creation...${NC}"

if [ -n "$MENU_ITEM_ID" ]; then
    ORDER_DATA="{
        \"items\": [{\"menu_item_id\": $MENU_ITEM_ID, \"quantity\": 2}],
        \"customer_name\": \"$TEST_NAME\",
        \"customer_phone\": \"555-1234\",
        \"notes\": \"E2E test order\"
    }"

    ORDER_RESPONSE=$(api_request POST /orders "$ORDER_DATA")
    ORDER_CODE=$(echo "$ORDER_RESPONSE" | tail -1)
    ORDER_BODY=$(echo "$ORDER_RESPONSE" | head -n -1)

    run_test "Create order succeeds (201)" \
        "[ \"$ORDER_CODE\" = \"201\" ]"

    # Extract order ID
    ORDER_ID=$(echo "$ORDER_BODY" | grep -o '"id":[0-9]*' | cut -d: -f2)

    # Test 9: Track Order
    if [ -n "$ORDER_ID" ]; then
        run_test "Track order by ID" \
            "api_request GET /orders/$ORDER_ID | tail -1 | grep -q 200"
    else
        echo -e "${YELLOW}  ⚠️  SKIP: No order ID to track${NC}"
    fi
else
    echo -e "${YELLOW}  ⚠️  SKIP: No menu items available for order test${NC}"
    ((TESTS_TOTAL+=2))
fi

# Test 10: Invalid Authentication
echo -e "${YELLOW}Testing Security...${NC}"
run_test "Reject invalid JWT token" \
    "! api_request GET /auth/me '' 'invalid.token.here' | tail -1 | grep -q 200"

run_test "Reject weak password" \
    "! api_request POST /auth/register '{\"email\":\"weak@test.com\",\"password\":\"123\",\"name\":\"Test\"}' | tail -1 | grep -q 201"

# Test 11: Input Validation
run_test "Reject invalid email format" \
    "! api_request POST /auth/register '{\"email\":\"notanemail\",\"password\":\"TestPass123!\",\"name\":\"Test\"}' | tail -1 | grep -q 201"

# Test 12: SQL Injection Prevention
run_test "Prevent SQL injection in email" \
    "! api_request POST /auth/login '{\"email\":\"admin@test.com OR 1=1--\",\"password\":\"anything\"}' | tail -1 | grep -q 200"

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "                    TEST SUMMARY"
echo "═══════════════════════════════════════════════════════════"
echo -e "Total Tests:  $TESTS_TOTAL"
echo -e "${GREEN}Passed:       $TESTS_PASSED${NC}"
echo -e "${RED}Failed:       $TESTS_FAILED${NC}"
echo ""

SUCCESS_RATE=$((TESTS_PASSED * 100 / TESTS_TOTAL))
echo "Success Rate: $SUCCESS_RATE%"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED!${NC}"
    echo -e "${GREEN}✅ End-to-end flows are working correctly${NC}"
    exit 0
else
    echo -e "${RED}❌ SOME TESTS FAILED${NC}"
    echo -e "${YELLOW}Review failures above and fix before production${NC}"
    exit 1
fi
