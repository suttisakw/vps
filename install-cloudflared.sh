#!/bin/bash

# Cloudflare Tunnel Setup Script
# This script helps you set up Cloudflare Tunnel for your VPS

set -e

echo "🌐 Cloudflare Tunnel Setup"
echo "=========================="

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

# Check if cloudflared is installed
if ! command -v cloudflared &> /dev/null; then
    print_error "Cloudflared is not installed. Please run setup.sh first."
    exit 1
fi

# Step 1: Login to Cloudflare
print_status "Step 1: Login to Cloudflare"
echo "This will open your browser to authenticate with Cloudflare."
echo "Make sure you have access to the domain you want to use."
read -p "Press Enter to continue..."

cloudflared tunnel login

# Step 2: Create tunnel
print_status "Step 2: Creating tunnel..."
read -p "Enter tunnel name (default: my-vps-tunnel): " TUNNEL_NAME
TUNNEL_NAME=${TUNNEL_NAME:-my-vps-tunnel}

TUNNEL_OUTPUT=$(cloudflared tunnel create $TUNNEL_NAME)
TUNNEL_ID=$(echo "$TUNNEL_OUTPUT" | grep -oP '(?<=id: )[a-f0-9-]+')

print_success "Tunnel created with ID: $TUNNEL_ID"

# Step 3: Update config file
print_status "Step 3: Updating Cloudflare config..."
if [ -f cloudflared/config.yml ]; then
    # Update the tunnel ID in config.yml
    sed -i "s/\${TUNNEL_ID}/$TUNNEL_ID/g" cloudflared/config.yml
    print_success "Config file updated with tunnel ID"
else
    print_error "Config file not found. Please ensure cloudflared/config.yml exists."
    exit 1
fi

# Step 4: Create DNS records
print_status "Step 4: Creating DNS records..."
echo "You need to create DNS records in Cloudflare for the following domains:"
echo "- npm.yourdomain.com"
echo "- n8n.yourdomain.com" 
echo "- nodered.yourdomain.com"
echo ""
echo "Run these commands to create the DNS records:"
echo "cloudflared tunnel route dns $TUNNEL_ID npm.yourdomain.com"
echo "cloudflared tunnel route dns $TUNNEL_ID n8n.yourdomain.com"
echo "cloudflared tunnel route dns $TUNNEL_ID nodered.yourdomain.com"
echo ""
read -p "Press Enter after creating DNS records..."

# Step 5: Start tunnel service
print_status "Step 5: Starting tunnel..."
cloudflared tunnel run $TUNNEL_NAME

print_success "Cloudflare Tunnel setup completed!"
echo ""
print_status "Your services should now be accessible via:"
echo "- https://npm.yourdomain.com (Nginx Proxy Manager)"
echo "- https://n8n.yourdomain.com (n8n)"
echo "- https://nodered.yourdomain.com (Node-RED)"
