#!/bin/bash

# Server Setup Script for Kimleng & Chunna Wedding Invitation
# Run this script on your Ubuntu VPS

set -e

echo "🚀 Starting server setup for Kimleng & Chunna Wedding Invitation..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Update system
echo -e "${YELLOW}Updating system packages...${NC}"
sudo apt update && sudo apt upgrade -y

# Install Docker
echo -e "${YELLOW}Installing Docker...${NC}"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    echo -e "${GREEN}Docker installed successfully!${NC}"
else
    echo "Docker is already installed"
fi

# Install Docker Compose
echo -e "${YELLOW}Installing Docker Compose...${NC}"
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}Docker Compose installed successfully!${NC}"
else
    echo "Docker Compose is already installed"
fi

# Install Nginx
echo -e "${YELLOW}Installing Nginx...${NC}"
sudo apt install nginx -y

# Create web directory
echo -e "${YELLOW}Creating web directory...${NC}"
sudo mkdir -p /var/www/kimleng-wedding
sudo chown -R www-data:www-data /var/www/kimleng-wedding

# Create Nginx configuration
echo -e "${YELLOW}Creating Nginx configuration...${NC}"
sudo tee /etc/nginx/sites-available/kimleng-wedding > /dev/null <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name _;

    root /var/www/kimleng-wedding/web;
    index index.html;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript 
               application/x-javascript application/xml+rss 
               application/json application/javascript application/xml;

    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff|woff2|ttf|wasm)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Main location
    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
EOF

# Enable site
echo -e "${YELLOW}Enabling Nginx site...${NC}"
sudo ln -sf /etc/nginx/sites-available/kimleng-wedding /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
echo -e "${YELLOW}Testing Nginx configuration...${NC}"
sudo nginx -t

# Start and enable services
echo -e "${YELLOW}Starting services...${NC}"
sudo systemctl restart nginx
sudo systemctl enable nginx

# Configure firewall
echo -e "${YELLOW}Configuring firewall...${NC}"
if command -v ufw &> /dev/null; then
    sudo ufw allow 22/tcp
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw --force enable
fi

# Install Git if not present
echo -e "${YELLOW}Installing Git...${NC}"
sudo apt install git -y

echo -e "${GREEN}✅ Server setup completed successfully!${NC}"
echo ""
echo "Next steps:"
echo "1. Install Jenkins by running:"
echo "   sudo docker run -d --name jenkins --restart=always -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -v \$(which docker):/usr/bin/docker jenkins/jenkins:lts"
echo ""
echo "2. Get Jenkins initial password:"
echo "   sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
echo ""
echo "3. Access Jenkins at: http://your-vps-ip:8080"
echo ""
echo "4. Configure DNS for your domain (optional)"

