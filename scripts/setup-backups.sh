#!/usr/bin/env bash
# Setup automated database backups with cron

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${GREEN}🔧 Setting up automated backups...${NC}"
echo ""

# Default: Daily at 2 AM
read -p "Backup frequency (default: daily at 2 AM) - Enter cron schedule or press Enter: " CRON_SCHEDULE
CRON_SCHEDULE=${CRON_SCHEDULE:-"0 2 * * *"}

CRON_JOB="$CRON_SCHEDULE cd $SCRIPT_DIR/.. && $SCRIPT_DIR/backup.sh >> /var/log/db-backup.log 2>&1"

echo ""
echo -e "${YELLOW}Cron job to be added:${NC}"
echo "$CRON_JOB"
echo ""

read -p "Add this cron job? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ]; then
    echo "Cancelled"
    exit 0
fi

# Add to crontab
(crontab -l 2>/dev/null | grep -v "backup.sh"; echo "$CRON_JOB") | crontab -

echo -e "${GREEN}✅ Automated backups configured!${NC}"
echo ""
echo "Schedule: $CRON_SCHEDULE"
echo "Log file: /var/log/db-backup.log"
echo ""
echo "To view cron jobs: crontab -l"
echo "To remove: crontab -e"
