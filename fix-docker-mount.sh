#!/bin/bash

# Fix Docker Mount Issues Script
# This script fixes common Docker mount issues

set -e

echo "🔧 Fixing Docker Mount Issues..."
echo "=================================="

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

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Step 1: Stop all containers
print_status "Stopping all containers..."
docker compose down

# Step 2: Check if config files exist
print_status "Checking config files..."

config_files=(
    "postgresql.conf"
    "redis.conf"
    "prometheus.yml"
    "nginx-static.conf"
    "cloudflared/config.yml"
)

for file in "${config_files[@]}"; do
    if [ -f "$file" ]; then
        print_success "✓ $file exists"
    else
        print_error "✗ $file missing"
        exit 1
    fi
done

# Step 3: Clean up Docker system
print_status "Cleaning up Docker system..."
docker system prune -f

# Step 4: Remove old volumes (optional)
read -p "Do you want to remove old volumes? This will delete all data! (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Removing old volumes..."
    docker volume prune -f
fi

# Step 5: Rebuild and start services
print_status "Rebuilding and starting services..."
docker compose up -d --build

# Step 6: Check service status
print_status "Checking service status..."
sleep 10
docker compose ps

# Step 7: Check logs for errors
print_status "Checking logs for errors..."
docker compose logs --tail=50

print_success "Docker mount issues fixed!"
print_status "Services should now be running properly."
print_status "Check 'docker compose ps' to verify all services are healthy."
