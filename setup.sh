#!/bin/bash

# VPS Setup Script for Cloudflare Tunnel + NPM + Docker Services
# Author: AI Assistant
# Version: 1.0

set -e  # Exit on any error

echo "🚀 Starting VPS Setup for Cloudflare Tunnel + NPM + Docker Services"
echo "================================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
   exit 1
fi

# Check if .env file exists
if [ ! -f .env ]; then
    print_warning ".env file not found. Creating from .env.example..."
    cp .env.example .env
    print_warning "Please edit .env file with your actual configuration before continuing!"
    print_warning "Especially update passwords and domain names."
    read -p "Press Enter to continue after editing .env file..."
fi

# Update system
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install required packages
print_status "Installing required packages..."
sudo apt install -y ca-certificates curl gnupg lsb-release wget unzip

# Install Docker
print_status "Installing Docker..."
if ! command -v docker &> /dev/null; then
    # Add Docker's official GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
        sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Add Docker repository
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
        https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Add user to docker group
    sudo usermod -aG docker $USER
    print_success "Docker installed successfully"
else
    print_success "Docker is already installed"
fi

# Install Cloudflared
print_status "Installing Cloudflared..."
if ! command -v cloudflared &> /dev/null; then
    curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb \
        -o cloudflared.deb
    sudo dpkg -i cloudflared.deb
    rm cloudflared.deb
    print_success "Cloudflared installed successfully"
else
    print_success "Cloudflared is already installed"
fi

# Create necessary directories
print_status "Creating project directories..."
mkdir -p cloudflared
mkdir -p init-scripts
mkdir -p backup

# Set proper permissions
print_status "Setting up permissions..."
sudo chown -R $USER:$USER .

# Start Docker services
print_status "Starting Docker services..."
docker compose up -d

# Wait for services to be ready
print_status "Waiting for services to start..."
sleep 30

# Check if services are running
print_status "Checking service status..."
if docker compose ps | grep -q "Up"; then
    print_success "Docker services are running"
else
    print_error "Some services failed to start. Check logs with: docker compose logs"
    exit 1
fi

# Display service information
echo ""
echo "🎉 Setup completed successfully!"
echo "=================================="
echo ""
print_status "Service URLs (after Cloudflare Tunnel setup):"
echo "  - Nginx Proxy Manager: https://npm.yourdomain.com"
echo "  - n8n: https://n8n.yourdomain.com"
echo "  - Node-RED: https://nodered.yourdomain.com"
echo ""
print_status "Local access (for testing):"
echo "  - NPM Admin: http://$(curl -s ifconfig.me):81"
echo "  - n8n: http://$(curl -s ifconfig.me):5678"
echo "  - Node-RED: http://$(curl -s ifconfig.me):1880"
echo ""
print_status "Default credentials:"
echo "  - NPM: admin@example.com / changeme"
echo "  - n8n: admin / (check your .env file)"
echo ""
print_warning "Next steps:"
echo "1. Configure Cloudflare Tunnel:"
echo "   cloudflared tunnel login"
echo "   cloudflared tunnel create my-vps-tunnel"
echo "   # Copy the tunnel ID to cloudflared/config.yml"
echo ""
echo "2. Set up DNS records in Cloudflare"
echo "3. Configure NPM proxy hosts"
echo "4. Update firewall settings"
echo ""
print_success "Setup script completed! 🚀"
