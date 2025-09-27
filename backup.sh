#!/bin/bash

# Backup Script for VPS Services
# This script creates backups of all important data

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create backup directory with timestamp
BACKUP_DIR="backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

print_status "Creating backup in: $BACKUP_DIR"

# Function to backup volume
backup_volume() {
    local volume_name=$1
    local backup_name=$2
    
    print_status "Backing up $volume_name..."
    
    if docker volume ls | grep -q "$volume_name"; then
        docker run --rm \
            -v "$volume_name":/source:ro \
            -v "$(pwd)/$BACKUP_DIR":/backup \
            alpine:latest \
            tar czf "/backup/$backup_name" -C /source .
        print_success "$volume_name backed up to $backup_name"
    else
        print_error "Volume $volume_name not found"
    fi
}

# Backup all volumes
backup_volume "postgres_data" "postgres_backup.tar.gz"
backup_volume "n8n_data" "n8n_backup.tar.gz"
backup_volume "node_red_data" "node_red_backup.tar.gz"
backup_volume "redis_data" "redis_backup.tar.gz"
backup_volume "npm_data" "npm_backup.tar.gz"

# Backup configuration files
print_status "Backing up configuration files..."
cp -r cloudflared "$BACKUP_DIR/" 2>/dev/null || true
cp .env "$BACKUP_DIR/" 2>/dev/null || true
cp docker-compose.yml "$BACKUP_DIR/" 2>/dev/null || true

# Create backup info file
cat > "$BACKUP_DIR/backup_info.txt" << EOF
Backup created: $(date)
VPS Services Backup
==================

Services backed up:
- PostgreSQL Database
- n8n Workflows
- Node-RED Flows
- Redis Cache
- NPM Configuration
- Cloudflare Tunnel Config

To restore:
1. Stop services: docker compose down
2. Extract volumes from backup files
3. Start services: docker compose up -d
EOF

# Create compressed archive
print_status "Creating compressed backup archive..."
cd backup
tar czf "$(basename "$BACKUP_DIR").tar.gz" "$(basename "$BACKUP_DIR")"
cd ..

print_success "Backup completed successfully!"
print_status "Backup location: $BACKUP_DIR"
print_status "Compressed archive: backup/$(basename "$BACKUP_DIR").tar.gz"

# Optional: Upload to cloud storage
read -p "Do you want to upload backup to cloud storage? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Please configure your cloud storage upload method here"
    # Example: rsync, scp, or cloud CLI tools
fi
