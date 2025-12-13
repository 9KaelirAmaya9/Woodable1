#!/usr/bin/env bash
# Database backup script for PostgreSQL
# Reads credentials from .env file to ensure consistency

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load environment variables
if [ ! -f "$PROJECT_ROOT/.env" ]; then
    echo -e "${RED}❌ Error: .env file not found${NC}"
    echo "Please create .env from .env.example"
    exit 1
fi

# Source .env file
set -a
source "$PROJECT_ROOT/.env"
set +a

# Configuration
BACKUP_DIR="${BACKUP_DIR:-$PROJECT_ROOT/backups}"
RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-7}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/${POSTGRES_DB}_${TIMESTAMP}.sql.gz"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo -e "${GREEN}🔄 Starting database backup...${NC}"
echo "Database: $POSTGRES_DB"
echo "User: $POSTGRES_USER"
echo "Host: ${DB_HOST:-localhost}"
echo "Backup file: $BACKUP_FILE"
echo ""

# Perform backup
if docker compose -f "$PROJECT_ROOT/local.docker.yml" exec -T postgres \
    pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" --clean --if-exists | gzip > "$BACKUP_FILE"; then

    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo -e "${GREEN}✅ Backup successful!${NC}"
    echo "Size: $BACKUP_SIZE"
    echo "Location: $BACKUP_FILE"
else
    echo -e "${RED}❌ Backup failed!${NC}"
    rm -f "$BACKUP_FILE"
    exit 1
fi

# Clean old backups
echo ""
echo -e "${YELLOW}🧹 Cleaning backups older than ${RETENTION_DAYS} days...${NC}"
OLD_BACKUPS=$(find "$BACKUP_DIR" -name "*.sql.gz" -type f -mtime +$RETENTION_DAYS)

if [ -n "$OLD_BACKUPS" ]; then
    echo "$OLD_BACKUPS" | while read -r file; do
        echo "Deleting: $(basename "$file")"
        rm -f "$file"
    done
    echo -e "${GREEN}✅ Cleanup complete${NC}"
else
    echo "No old backups to delete"
fi

# List current backups
echo ""
echo -e "${GREEN}📦 Current backups:${NC}"
ls -lh "$BACKUP_DIR"/*.sql.gz 2>/dev/null | awk '{print $9, "(" $5 ")"}' || echo "No backups found"

# Verify backup integrity
echo ""
echo -e "${YELLOW}🔍 Verifying backup integrity...${NC}"
if gunzip -t "$BACKUP_FILE" 2>/dev/null; then
    echo -e "${GREEN}✅ Backup file is valid${NC}"
else
    echo -e "${RED}❌ Backup file is corrupted!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 Backup process complete!${NC}"
