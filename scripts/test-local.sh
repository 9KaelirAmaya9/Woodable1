#!/bin/bash

# Rico's Tacos - Simple Local Test
# Quick verification that services are running

echo "=========================================="
echo "Rico's Tacos - Quick Local Test"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo "ℹ $1"
}

echo "Checking Docker Services..."
echo "----------------------------"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running!"
    echo "Please start Docker Desktop and try again"
    exit 1
fi
print_success "Docker is running"

# Check if services are up
SERVICES=("postgres" "backend" "react-app" "nginx")
ALL_RUNNING=true

for service in "${SERVICES[@]}"; do
    if docker compose -f local.docker.yml ps 2>/dev/null | grep -q "$service.*Up"; then
        print_success "$service is running"
    else
        print_error "$service is NOT running"
        ALL_RUNNING=false
    fi
done

echo ""
echo "Testing Endpoints..."
echo "--------------------"

# Test PostgreSQL
if docker compose -f local.docker.yml exec postgres pg_isready -U myuser > /dev/null 2>&1; then
    print_success "PostgreSQL is ready"
    
    # Check menu count
    MENU_COUNT=$(docker compose -f local.docker.yml exec -T postgres psql -U myuser -d mydatabase -tAc "SELECT COUNT(*) FROM menu_items;" 2>/dev/null || echo "0")
    if [ "$MENU_COUNT" -eq "169" ]; then
        print_success "Menu items: $MENU_COUNT ✓"
    else
        echo -e "${YELLOW}⚠ Menu items: $MENU_COUNT (expected 169)${NC}"
    fi
else
    print_error "PostgreSQL is not ready"
fi

# Test Backend
if curl -f http://localhost:5001/api/health > /dev/null 2>&1; then
    print_success "Backend API is responding"
else
    echo -e "${YELLOW}⚠ Backend API not accessible (might use Traefik routing)${NC}"
fi

# Test Frontend
if curl -f http://localhost:3000 > /dev/null 2>&1; then
    print_success "Frontend is accessible"
else
    print_error "Frontend is not accessible"
fi

echo ""
echo "=========================================="

if [ "$ALL_RUNNING" = true ]; then
    echo -e "${GREEN}✓ All services are running!${NC}"
    echo ""
    echo "Access points:"
    echo "  • Frontend: http://localhost:3000"
    echo "  • Backend: http://localhost:5001/api/health"
    echo "  • Nginx: http://localhost:8080"
    echo "  • pgAdmin: http://localhost:5050"
    echo ""
    echo "Test the ordering flow:"
    echo "  1. Open http://localhost:3000"
    echo "  2. Browse menu"
    echo "  3. Add items to cart"
    echo "  4. Test checkout (Stripe test: 4242 4242 4242 4242)"
    echo ""
else
    echo -e "${RED}✗ Some services are not running${NC}"
    echo ""
    echo "Start services with: ./scripts/start.sh"
    echo "Check logs with: ./scripts/logs.sh"
fi

echo "=========================================="
