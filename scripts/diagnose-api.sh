#!/usr/bin/env bash
# Docker API Diagnostic Script
# Diagnoses why backend API is not responding

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       DOCKER API DIAGNOSTIC TOOL                       ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running!${NC}"
    echo "Please start Docker Desktop and try again."
    exit 1
fi

echo -e "${GREEN}✅ Docker is running${NC}"
echo ""

# Step 1: Container Status
echo -e "${YELLOW}━━━ STEP 1: Container Status ━━━${NC}"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "NAMES|base2" || echo "No base2 containers found"
echo ""

# Count containers
CONTAINER_COUNT=$(docker ps --filter "name=base2" | wc -l)
echo "Total base2 containers running: $((CONTAINER_COUNT - 1))"
echo ""

# Step 2: Backend Container Health
echo -e "${YELLOW}━━━ STEP 2: Backend Container Health ━━━${NC}"
if docker ps | grep -q "base2_backend"; then
    echo -e "${GREEN}✅ Backend container is running${NC}"

    # Check health status
    HEALTH=$(docker inspect base2_backend --format='{{.State.Health.Status}}' 2>/dev/null || echo "no-healthcheck")
    echo "Health status: $HEALTH"
else
    echo -e "${RED}❌ Backend container is NOT running!${NC}"
    echo "Run: docker compose -f local.docker.yml up -d backend"
    exit 1
fi
echo ""

# Step 3: Test Backend Internally
echo -e "${YELLOW}━━━ STEP 3: Test Backend API Internally ━━━${NC}"
echo "Testing: curl http://localhost:5000/api/health (inside container)"

INTERNAL_TEST=$(docker exec base2_backend curl -s http://localhost:5000/api/health 2>&1)
if [[ $INTERNAL_TEST == *"ok"* ]] || [[ $INTERNAL_TEST == *"success"* ]]; then
    echo -e "${GREEN}✅ Backend API responds internally${NC}"
    echo "Response: $INTERNAL_TEST"
else
    echo -e "${RED}❌ Backend API does NOT respond internally${NC}"
    echo "Response: $INTERNAL_TEST"
    echo ""
    echo "Issue: Backend server is not running or not listening on port 5000"
fi
echo ""

# Step 4: Check Port Binding
echo -e "${YELLOW}━━━ STEP 4: Check What Port Backend is Listening On ━━━${NC}"
PORT_CHECK=$(docker exec base2_backend netstat -tulpn 2>/dev/null | grep node || echo "netstat not available, trying lsof...")

if [[ $PORT_CHECK == *"netstat not available"* ]]; then
    PORT_CHECK=$(docker exec base2_backend lsof -i -P -n 2>/dev/null | grep LISTEN || echo "Port check tools not available")
fi

if [[ -n $PORT_CHECK ]]; then
    echo "$PORT_CHECK"

    if [[ $PORT_CHECK == *"5000"* ]]; then
        echo -e "${GREEN}✅ Backend is listening on port 5000${NC}"
    else
        echo -e "${RED}❌ Backend is NOT listening on port 5000${NC}"
        echo "Check backend/server.js for the correct port"
    fi

    if [[ $PORT_CHECK == *"0.0.0.0"* ]]; then
        echo -e "${GREEN}✅ Backend is binding to 0.0.0.0 (accessible from Docker network)${NC}"
    elif [[ $PORT_CHECK == *"127.0.0.1"* ]] || [[ $PORT_CHECK == *"localhost"* ]]; then
        echo -e "${RED}❌ Backend is binding to 127.0.0.1 (NOT accessible from Docker network)${NC}"
        echo "Fix: Change app.listen() in server.js to bind to 0.0.0.0"
    fi
else
    echo -e "${YELLOW}⚠️  Could not check port binding (tools not available in container)${NC}"
fi
echo ""

# Step 5: Test from Nginx Container
echo -e "${YELLOW}━━━ STEP 5: Test Backend from Nginx Container ━━━${NC}"
echo "Testing: wget http://backend:5000/api/health (from nginx)"

NGINX_TEST=$(docker exec base2_nginx wget -qO- http://backend:5000/api/health 2>&1 || echo "FAILED")
if [[ $NGINX_TEST == *"ok"* ]] || [[ $NGINX_TEST == *"success"* ]]; then
    echo -e "${GREEN}✅ Nginx can reach backend via Docker network${NC}"
    echo "Response: $NGINX_TEST"
else
    echo -e "${RED}❌ Nginx CANNOT reach backend via Docker network${NC}"
    echo "Response: $NGINX_TEST"
    echo ""
    echo "Issue: Docker networking problem or backend not accessible"
fi
echo ""

# Step 6: Check Traefik Labels
echo -e "${YELLOW}━━━ STEP 6: Check Traefik Routing Labels ━━━${NC}"
LABELS=$(docker inspect base2_backend --format='{{json .Config.Labels}}' | grep -o '"traefik[^"]*":"[^"]*"' || echo "No Traefik labels found")

if [[ $LABELS == *"traefik.enable"*"true"* ]]; then
    echo -e "${GREEN}✅ Traefik is enabled for backend${NC}"
else
    echo -e "${RED}❌ Traefik is NOT enabled for backend${NC}"
fi

if [[ $LABELS == *"traefik.http.services.api.loadbalancer.server.port"* ]]; then
    PORT=$(echo "$LABELS" | grep -o 'traefik.http.services.api.loadbalancer.server.port":"[^"]*' | cut -d'"' -f3)
    echo "Traefik routing to backend port: $PORT"

    if [[ $PORT == "5000" ]]; then
        echo -e "${GREEN}✅ Traefik port configuration is correct${NC}"
    else
        echo -e "${RED}❌ Traefik is configured for port $PORT but backend may be on 5000${NC}"
    fi
else
    echo -e "${RED}❌ Traefik loadbalancer port not configured${NC}"
fi

echo ""
echo "All Traefik labels:"
echo "$LABELS"
echo ""

# Step 7: Backend Logs
echo -e "${YELLOW}━━━ STEP 7: Backend Logs (Last 20 Lines) ━━━${NC}"
docker logs base2_backend --tail 20
echo ""

# Step 8: Test External Access
echo -e "${YELLOW}━━━ STEP 8: Test External Access via Traefik ━━━${NC}"
echo "Testing: curl http://localhost/api/health"

EXTERNAL_TEST=$(curl -s -w "\nHTTP_CODE:%{http_code}" http://localhost/api/health 2>&1)
HTTP_CODE=$(echo "$EXTERNAL_TEST" | grep "HTTP_CODE" | cut -d':' -f2)
RESPONSE=$(echo "$EXTERNAL_TEST" | grep -v "HTTP_CODE")

echo "HTTP Status: $HTTP_CODE"
echo "Response: $RESPONSE"

if [[ $HTTP_CODE == "200" ]] && [[ $RESPONSE == *"ok"* ]]; then
    echo -e "${GREEN}✅ External API access is WORKING!${NC}"
elif [[ $HTTP_CODE == "404" ]]; then
    echo -e "${RED}❌ 404 Not Found - Traefik routing not configured correctly${NC}"
elif [[ -z $HTTP_CODE ]]; then
    echo -e "${RED}❌ Connection failed - Traefik may not be running${NC}"
else
    echo -e "${RED}❌ External API access FAILED with HTTP $HTTP_CODE${NC}"
fi
echo ""

# Step 9: Environment Variables
echo -e "${YELLOW}━━━ STEP 9: Environment Variables ━━━${NC}"
if [ -f .env ]; then
    echo "Backend port in .env:"
    grep BACKEND_PORT .env || echo "BACKEND_PORT not set in .env"

    echo ""
    echo "Backend environment variables:"
    docker exec base2_backend env | grep -E "PORT|NODE_ENV|DB_HOST" || echo "Environment vars not accessible"
else
    echo -e "${RED}❌ .env file not found!${NC}"
fi
echo ""

# Step 10: Docker Network
echo -e "${YELLOW}━━━ STEP 10: Docker Network Configuration ━━━${NC}"
NETWORK_CHECK=$(docker network inspect base2_network 2>/dev/null | grep -A 5 "base2_backend" || echo "Backend not in base2_network")

if [[ $NETWORK_CHECK == *"IPv4Address"* ]]; then
    IP=$(echo "$NETWORK_CHECK" | grep "IPv4Address" | cut -d'"' -f4)
    echo -e "${GREEN}✅ Backend is connected to base2_network${NC}"
    echo "Backend IP: $IP"
else
    echo -e "${RED}❌ Backend is NOT connected to base2_network${NC}"
    echo "Run: docker network connect base2_network base2_backend"
fi
echo ""

# Summary
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    DIAGNOSTIC SUMMARY                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Determine the issue
if [[ $INTERNAL_TEST == *"ok"* ]] && [[ $NGINX_TEST == *"ok"* ]] && [[ $HTTP_CODE == "200" ]]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED - API IS WORKING!${NC}"
elif [[ $INTERNAL_TEST != *"ok"* ]]; then
    echo -e "${RED}🔴 ISSUE: Backend server is not responding${NC}"
    echo "Fix: Check backend/server.js and restart: docker compose -f local.docker.yml restart backend"
elif [[ $NGINX_TEST != *"ok"* ]]; then
    echo -e "${RED}🔴 ISSUE: Docker networking problem${NC}"
    echo "Fix: Backend may not be binding to 0.0.0.0 or not on base2_network"
elif [[ $HTTP_CODE != "200" ]]; then
    echo -e "${RED}🔴 ISSUE: Traefik routing not configured correctly${NC}"
    echo "Fix: Check Traefik labels in local.docker.yml"
fi

echo ""
echo "For more help, review the detailed output above."
echo ""
