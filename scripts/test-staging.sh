#!/bin/bash
# ============================================
# Test Staging Environment
# ============================================
# Validates staging environment functionality
# Usage: ./scripts/test-staging.sh [IP_ADDRESS]

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}Staging Environment Tests${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Load environment
export ENV_FILE="${ENV_FILE:-.env.staging}"
ENV_PATH="$PROJECT_ROOT/$ENV_FILE"

if [ -f "$ENV_PATH" ]; then
    set -a
    source "$ENV_PATH"
    set +a
fi

# Get IP address from argument or environment
if [ -n "$1" ]; then
    IP_ADDRESS="$1"
elif [ -f "$PROJECT_ROOT/DO_userdata.json" ]; then
    IP_ADDRESS=$(python3 -c "import json; print(json.load(open('$PROJECT_ROOT/DO_userdata.json')).get('ip_address', ''))" 2>/dev/null || echo "")
fi

if [ -z "$IP_ADDRESS" ]; then
    echo -e "${RED}ERROR: IP address not provided${NC}"
    echo "Usage: $0 [IP_ADDRESS]"
    echo "Or ensure DO_userdata.json exists with ip_address"
    exit 1
fi

# Determine base URL
if [ -n "$WEBSITE_DOMAIN" ] && [ "$WEBSITE_DOMAIN" != "staging.ricostacos.com" ]; then
    BASE_URL="https://$WEBSITE_DOMAIN"
    echo -e "${BLUE}Testing domain: $WEBSITE_DOMAIN${NC}"
else
    BASE_URL="http://$IP_ADDRESS"
    echo -e "${BLUE}Testing IP: $IP_ADDRESS${NC}"
fi

echo ""

# Counters
PASSED=0
FAILED=0
TOTAL=0

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    ((TOTAL++))
    echo -n "Testing $test_name... "
    
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((FAILED++))
        return 1
    fi
}

# ============================================
# 1. Network Connectivity
# ============================================
echo -e "${BLUE}[1/7] Network Connectivity${NC}"
run_test "Ping droplet" "ping -c 1 -W 5 $IP_ADDRESS"
echo ""

# ============================================
# 2. SSH Access
# ============================================
echo -e "${BLUE}[2/7] SSH Access${NC}"

SSH_KEY_PATH="${LOCAL_SSH_KEY_PATH:-~/.ssh/$PROJECT_NAME}"
if [ -f "$SSH_KEY_PATH" ]; then
    run_test "SSH connection" "ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -i $SSH_KEY_PATH root@$IP_ADDRESS 'echo ok'"
else
    echo -e "${YELLOW}⚠ SSH key not found at $SSH_KEY_PATH, skipping SSH test${NC}"
fi
echo ""

# ============================================
# 3. HTTP/HTTPS Accessibility
# ============================================
echo -e "${BLUE}[3/7] HTTP/HTTPS Accessibility${NC}"

run_test "Frontend accessible" "curl -f -s -o /dev/null -w '%{http_code}' --max-time 10 $BASE_URL | grep -q '200\|301\|302'"
run_test "API health endpoint" "curl -f -s --max-time 10 $BASE_URL/api/health"

# Check if HTTPS is configured
if [[ "$BASE_URL" == "https://"* ]]; then
    run_test "SSL certificate valid" "curl -f -s -o /dev/null --max-time 10 $BASE_URL"
fi
echo ""

# ============================================
# 4. API Endpoints
# ============================================
echo -e "${BLUE}[4/7] API Endpoints${NC}"

run_test "Menu API" "curl -f -s --max-time 10 $BASE_URL/api/menu | grep -q '\['"
run_test "Categories API" "curl -f -s --max-time 10 $BASE_URL/api/menu/categories | grep -q '\['"

echo ""

# ============================================
# 5. Docker Services
# ============================================
echo -e "${BLUE}[5/7] Docker Services${NC}"

if [ -f "$SSH_KEY_PATH" ]; then
    run_test "Docker running" "ssh -o StrictHostKeyChecking=no -i $SSH_KEY_PATH root@$IP_ADDRESS 'docker ps -q' | grep -q ."
    run_test "Backend container" "ssh -o StrictHostKeyChecking=no -i $SSH_KEY_PATH root@$IP_ADDRESS 'docker ps | grep -q backend'"
    run_test "Frontend container" "ssh -o StrictHostKeyChecking=no -i $SSH_KEY_PATH root@$IP_ADDRESS 'docker ps | grep -q react-app'"
    run_test "Database container" "ssh -o StrictHostKeyChecking=no -i $SSH_KEY_PATH root@$IP_ADDRESS 'docker ps | grep -q postgres'"
    run_test "Nginx container" "ssh -o StrictHostKeyChecking=no -i $SSH_KEY_PATH root@$IP_ADDRESS 'docker ps | grep -q nginx'"
else
    echo -e "${YELLOW}⚠ SSH key not found, skipping Docker service checks${NC}"
fi
echo ""

# ============================================
# 6. Database Connectivity
# ============================================
echo -e "${BLUE}[6/7] Database Connectivity${NC}"

if [ -f "$SSH_KEY_PATH" ]; then
    run_test "Database accessible" "ssh -o StrictHostKeyChecking=no -i $SSH_KEY_PATH root@$IP_ADDRESS 'docker exec \$(docker ps -q -f name=postgres) pg_isready -U $POSTGRES_USER'"
    run_test "Database has tables" "ssh -o StrictHostKeyChecking=no -i $SSH_KEY_PATH root@$IP_ADDRESS 'docker exec \$(docker ps -q -f name=postgres) psql -U $POSTGRES_USER -d $POSTGRES_DB -c \"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '\"'\"'public'\"'\"';\"' | grep -q '[0-9]'"
else
    echo -e "${YELLOW}⚠ SSH key not found, skipping database checks${NC}"
fi
echo ""

# ============================================
# 7. Environment Configuration
# ============================================
echo -e "${BLUE}[7/7] Environment Configuration${NC}"

if [ -f "$SSH_KEY_PATH" ]; then
    # Check if Stripe is in test mode
    run_test "Stripe test mode" "ssh -o StrictHostKeyChecking=no -i $SSH_KEY_PATH root@$IP_ADDRESS 'grep -q \"STRIPE_SECRET_KEY=sk_test_\" /opt/apps/*/backend/.env || grep -q \"STRIPE_SECRET_KEY=sk_test_\" /srv/backend/.env'"
    
    # Check NODE_ENV
    run_test "NODE_ENV is staging" "ssh -o StrictHostKeyChecking=no -i $SSH_KEY_PATH root@$IP_ADDRESS 'grep -q \"NODE_ENV=staging\" /opt/apps/*/backend/.env || grep -q \"NODE_ENV=staging\" /srv/backend/.env'"
else
    echo -e "${YELLOW}⚠ SSH key not found, skipping environment checks${NC}"
fi
echo ""

# ============================================
# Summary
# ============================================
echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}Test Summary${NC}"
echo -e "${CYAN}============================================${NC}"
echo -e "Total tests: $TOTAL"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All tests PASSED${NC}"
    echo ""
    echo -e "${CYAN}Next Steps:${NC}"
    echo "  1. Test the application in a browser:"
    echo "     $BASE_URL"
    echo ""
    echo "  2. Test order flow with Stripe test card:"
    echo "     Card: 4242 4242 4242 4242"
    echo "     Expiry: Any future date"
    echo "     CVC: Any 3 digits"
    echo ""
    echo "  3. Check application logs:"
    echo "     ssh root@$IP_ADDRESS 'docker logs -f \$(docker ps -q -f name=backend)'"
    echo ""
    exit 0
else
    echo -e "${RED}❌ Some tests FAILED${NC}"
    echo ""
    echo -e "${YELLOW}Troubleshooting:${NC}"
    echo "  1. Check Docker container status:"
    echo "     ssh root@$IP_ADDRESS 'docker ps -a'"
    echo ""
    echo "  2. View backend logs:"
    echo "     ssh root@$IP_ADDRESS 'docker logs \$(docker ps -q -f name=backend)'"
    echo ""
    echo "  3. View cloud-init logs:"
    echo "     ssh root@$IP_ADDRESS 'cat /var/log/cloud-init-output.log'"
    echo ""
    exit 1
fi
