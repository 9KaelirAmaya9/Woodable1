#!/usr/bin/env bash
# Database restore script for PostgreSQL

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load environment variables
if [ ! -f "$PROJECT_ROOT/.env" ]; then
    echo -e "${RED}❌ Error: .env file not found${NC}"
    exit 1
fi

set -a
source "$PROJECT_ROOT/.env"
set +a

BACKUP_DIR="${BACKUP_DIR:-$PROJECT_ROOT/backups}"

# Function to list available backups
list_backups() {
    echo -e "${GREEN}📦 Available backups:${NC}"
    ls -lht "$BACKUP_DIR"/*.sql.gz 2>/dev/null | nl | awk '{print $1, $10, "(" $6 ")", $7, $8}' || {
        echo -e "${RED}No backups found in $BACKUP_DIR${NC}"
        exit 1
    }
}

# Show available backups
list_backups
echo ""

# Get backup file
if [ $# -eq 0 ]; then
    echo -e "${YELLOW}Enter backup number to restore (or full path):${NC}"
    read -r BACKUP_INPUT

    # If number provided, get nth backup
    if [[ "$BACKUP_INPUT" =~ ^[0-9]+$ ]]; then
        BACKUP_FILE=$(ls -t "$BACKUP_DIR"/*.sql.gz 2>/dev/null | sed -n "${BACKUP_INPUT}p")
    else
        BACKUP_FILE="$BACKUP_INPUT"
    fi
else
    BACKUP_FILE="$1"
fi

# Validate backup file
if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}❌ Backup file not found: $BACKUP_FILE${NC}"
    exit 1
fi

echo -e "${YELLOW}⚠️  WARNING: This will DROP and recreate the database!${NC}"
echo "Database: $POSTGRES_DB"
echo "Backup: $(basename "$BACKUP_FILE")"
echo ""
echo -e "${RED}All current data will be LOST!${NC}"
echo ""
read -p "Type 'YES' to continue: " CONFIRM

if [ "$CONFIRM" != "YES" ]; then
    echo "Restore cancelled"
    exit 0
fi

echo ""
echo -e "${GREEN}🔄 Starting database restore...${NC}"

# Verify backup integrity
echo "Verifying backup file..."
if ! gunzip -t "$BACKUP_FILE" 2>/dev/null; then
    echo -e "${RED}❌ Backup file is corrupted!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Backup file is valid${NC}"

# Stop backend to prevent connections
echo "Stopping backend service..."
docker compose -f "$PROJECT_ROOT/local.docker.yml" stop backend 2>/dev/null || true

# Restore database
echo "Restoring database..."
if gunzip -c "$BACKUP_FILE" | docker compose -f "$PROJECT_ROOT/local.docker.yml" exec -T postgres \
    psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"; then

    echo -e "${GREEN}✅ Restore successful!${NC}"
else
    echo -e "${RED}❌ Restore failed!${NC}"
    exit 1
fi

# Restart backend
echo "Restarting backend service..."
docker compose -f "$PROJECT_ROOT/local.docker.yml" start backend

echo ""
echo -e "${GREEN}🎉 Database restored successfully!${NC}"
echo "Backup: $(basename "$BACKUP_FILE")"
