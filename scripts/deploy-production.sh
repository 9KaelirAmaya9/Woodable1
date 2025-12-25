#!/bin/bash

# Production Deployment Script
# Automates the deployment process with validation and health checks

set -e  # Exit on error

echo "🚀 Los Ricos Tacos - Production Deployment"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${RED}❌ Error: .env file not found${NC}"
    echo "   Copy .env.production to .env and configure all values"
    exit 1
fi

# Validate environment
echo "🔍 Step 1: Validating environment configuration..."
node scripts/validate-env.js
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Environment validation failed${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Environment validated${NC}"
echo ""

# Pull latest images
echo "📦 Step 2: Pulling latest Docker images..."
docker-compose -f local.docker.yml pull
echo -e "${GREEN}✅ Images pulled${NC}"
echo ""

# Build services
echo "🔨 Step 3: Building services..."
docker-compose -f local.docker.yml build --no-cache
echo -e "${GREEN}✅ Services built${NC}"
echo ""

# Stop existing containers
echo "🛑 Step 4: Stopping existing containers..."
docker-compose -f local.docker.yml down
echo -e "${GREEN}✅ Containers stopped${NC}"
echo ""

# Start services
echo "🚀 Step 5: Starting services..."
docker-compose -f local.docker.yml up -d
echo -e "${GREEN}✅ Services started${NC}"
echo ""

# Wait for services to be healthy
echo "⏳ Step 6: Waiting for services to be healthy..."
sleep 10

# Check health
BACKEND_HEALTHY=$(docker inspect --format='{{.State.Health.Status}}' base2_backend 2>/dev/null || echo "unknown")
POSTGRES_HEALTHY=$(docker inspect --format='{{.State.Health.Status}}' base2_postgres 2>/dev/null || echo "unknown")

if [ "$BACKEND_HEALTHY" != "healthy" ] || [ "$POSTGRES_HEALTHY" != "healthy" ]; then
    echo -e "${YELLOW}⚠️  Warning: Some services may not be healthy yet${NC}"
    echo "   Backend: $BACKEND_HEALTHY"
    echo "   Postgres: $POSTGRES_HEALTHY"
    echo "   Check logs: docker-compose -f local.docker.yml logs"
else
    echo -e "${GREEN}✅ All services healthy${NC}"
fi
echo ""

# Initialize database (if needed)
echo "🗄️  Step 7: Initializing database..."
docker exec base2_backend node /app/scripts/init-database.js
echo ""

# Setup admin users
echo "👤 Step 8: Setting up admin users..."
docker exec base2_backend node /app/scripts/setup-admins.js
echo ""

# Seed menu
echo "🌮 Step 9: Seeding menu data..."
docker exec base2_backend node /app/scripts/seed-menu.js
echo ""

# Final health check
echo "🏥 Step 10: Final health check..."
HEALTH_CHECK=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/api/health || echo "000")

if [ "$HEALTH_CHECK" = "200" ]; then
    echo -e "${GREEN}✅ Backend API is responding${NC}"
else
    echo -e "${RED}❌ Backend API health check failed (HTTP $HEALTH_CHECK)${NC}"
    echo "   Check logs: docker logs base2_backend"
fi
echo ""

# Display access information
echo "=========================================="
echo -e "${GREEN}✅ Deployment Complete!${NC}"
echo "=========================================="
echo ""
echo "📍 Access Points:"
echo "   Frontend:  http://localhost:3000"
echo "   Backend:   http://localhost:5000"
echo "   pgAdmin:   http://localhost:5050"
echo "   Traefik:   http://localhost:8082/dashboard/"
echo ""
echo "📊 View logs:"
echo "   docker-compose -f local.docker.yml logs -f"
echo ""
echo "🛑 Stop services:"
echo "   docker-compose -f local.docker.yml down"
echo ""
