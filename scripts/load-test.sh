#!/usr/bin/env bash
# Load Testing Script using Apache Bench (ab)

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
TARGET_URL="${1:-http://localhost:5001}"
CONCURRENT_USERS="${2:-50}"
TOTAL_REQUESTS="${3:-1000}"

echo "═══════════════════════════════════════════════════════════"
echo "               LOAD TESTING SUITE"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Target: $TARGET_URL"
echo "Concurrent Users: $CONCURRENT_USERS"
echo "Total Requests: $TOTAL_REQUESTS"
echo ""

# Check if ab is installed
if ! command -v ab &> /dev/null; then
    echo -e "${RED}❌ Apache Bench (ab) not installed${NC}"
    echo "Install with:"
    echo "  Ubuntu/Debian: sudo apt-get install apache2-utils"
    echo "  macOS: brew install apache2-utils"
    exit 1
fi

# Test 1: Health Endpoint
echo -e "${YELLOW}Test 1: Health Endpoint (warmup)${NC}"
ab -n 100 -c 10 "$TARGET_URL/api/health" 2>&1 | grep -E "Requests per second|Time per request|Failed requests"
echo ""

# Test 2: Menu Categories (Read-heavy)
echo -e "${YELLOW}Test 2: Menu Categories (read-heavy)${NC}"
ab -n "$TOTAL_REQUESTS" -c "$CONCURRENT_USERS" "$TARGET_URL/api/menu/categories" 2>&1 | grep -E "Requests per second|Time per request|Failed requests|95%"
echo ""

# Test 3: Menu Items (Database joins)
echo -e "${YELLOW}Test 3: Menu Items with Joins${NC}"
ab -n "$TOTAL_REQUESTS" -c "$CONCURRENT_USERS" "$TARGET_URL/api/menu/items" 2>&1 | grep -E "Requests per second|Time per request|Failed requests|95%"
echo ""

# Test 4: Order Creation (Write-heavy) - Need auth token
# Note: Simplified, in production use proper auth
echo -e "${YELLOW}Test 4: POST Requests (simulated)${NC}"
echo "Note: Full order creation test requires authentication"
echo "Run manual test with valid JWT token"
echo ""

# Test 5: Concurrent Connections
echo -e "${YELLOW}Test 5: High Concurrency Test${NC}"
HIGH_CONCURRENT=$((CONCURRENT_USERS * 2))
ab -n $((TOTAL_REQUESTS / 2)) -c "$HIGH_CONCURRENT" "$TARGET_URL/api/health" 2>&1 | grep -E "Requests per second|Time per request|Failed requests"
echo ""

# Test 6: Sustained Load
echo -e "${YELLOW}Test 6: Sustained Load (60 seconds)${NC}"
ab -t 60 -c "$CONCURRENT_USERS" "$TARGET_URL/api/menu/items" 2>&1 | grep -E "Requests per second|Time per request|Failed requests|95%"
echo ""

# Performance Benchmarks
echo "═══════════════════════════════════════════════════════════"
echo "              PERFORMANCE BENCHMARKS"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Run full benchmark:"
ab -n "$TOTAL_REQUESTS" -c "$CONCURRENT_USERS" -g results.tsv "$TARGET_URL/api/menu/items" > benchmark_results.txt

# Parse results
REQUESTS_PER_SEC=$(grep "Requests per second" benchmark_results.txt | awk '{print $4}')
MEAN_TIME=$(grep "Time per request.*mean" benchmark_results.txt | head -1 | awk '{print $4}')
FAILED=$(grep "Failed requests" benchmark_results.txt | awk '{print $3}')
P95=$(grep "95%" benchmark_results.txt | awk '{print $2}')

echo -e "${GREEN}Results:${NC}"
echo "  Requests/sec:    $REQUESTS_PER_SEC"
echo "  Mean time:       ${MEAN_TIME}ms"
echo "  95th percentile: ${P95}ms"
echo "  Failed:          $FAILED"
echo ""

# Evaluation
if (( $(echo "$MEAN_TIME < 500" | bc -l) )); then
    echo -e "${GREEN}✅ EXCELLENT: Mean response time < 500ms${NC}"
elif (( $(echo "$MEAN_TIME < 1000" | bc -l) )); then
    echo -e "${YELLOW}⚠️  GOOD: Mean response time < 1s${NC}"
else
    echo -e "${RED}❌ SLOW: Mean response time > 1s${NC}"
    echo "Consider optimization"
fi

if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}✅ PERFECT: No failed requests${NC}"
else
    echo -e "${RED}❌ WARNING: $FAILED failed requests${NC}"
    echo "Check error logs"
fi

echo ""
echo "Full results saved to: benchmark_results.txt"
echo "Detailed timing: results.tsv (import to spreadsheet)"
echo ""

# Cleanup
rm -f results.tsv

echo "═══════════════════════════════════════════════════════════"
echo -e "${GREEN}Load testing complete!${NC}"
echo "═══════════════════════════════════════════════════════════"
