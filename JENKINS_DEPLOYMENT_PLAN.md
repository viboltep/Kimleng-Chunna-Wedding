# Jenkins CI/CD Deployment Plan for Flutter Web App

## Overview
This document outlines the complete plan to deploy the Kimleng & Chunna Wedding Invitation Flutter Web app to a DigitalOcean Ubuntu VPS using Jenkins.

## Prerequisites

### VPS Setup (DigitalOcean)
- Ubuntu 22.04+ LTS
- Minimum 2GB RAM, 1 vCPU
- SSD storage (minimum 20GB)

### Required Software on VPS
- Docker (for Jenkins)
- Nginx (web server)
- SSH access configured
- Firewall configured (ports 22, 80, 443 open)

### Local Machine Setup
- Jenkins installed (or use cloud Jenkins)
- SSH key pair generated
- Access to VPS via SSH

## Architecture

```
[GitHub Repo] → [Jenkins] → [Build Flutter Web] → [Deploy to VPS] → [Nginx serves app]
```

## Step-by-Step Implementation Plan

### Phase 1: VPS Preparation

#### 1.1 Install Docker and Jenkins on VPS
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Jenkins via Docker
sudo docker run -d \
  --name jenkins \
  --restart=always \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(which docker):/usr/bin/docker \
  jenkins/jenkins:lts

# Get initial admin password
sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

#### 1.2 Install Nginx and Create Web Directory
```bash
# Install Nginx
sudo apt install nginx -y

# Create web directory for app
sudo mkdir -p /var/www/kimleng-wedding
sudo chown -R www-data:www-data /var/www/kimleng-wedding

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

#### 1.3 Create Nginx Configuration
Create file: `/etc/nginx/sites-available/kimleng-wedding`
```nginx
server {
    listen 80;
    listen [::]:80;
    server_name your-domain.com;  # Replace with your domain

    root /var/www/kimleng-wedding/web;
    index index.html;

    # Gzip compression for better performance
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript 
               application/x-javascript application/xml+rss 
               application/json application/javascript application/xml;

    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff|woff2|ttf)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Main location - serve Flutter app
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/kimleng-wedding /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### Phase 2: Jenkins Configuration

#### 2.1 Initial Jenkins Setup
1. Access Jenkins: `http://your-vps-ip:8080`
2. Enter initial admin password
3. Install suggested plugins
4. Create admin user
5. Install additional plugins:
   - Pipeline
   - SSH Pipeline Steps
   - Git
   - Flutter

#### 2.2 Configure SSH Access
On your local machine:
```bash
# Generate SSH key if not exists
ssh-keygen -t rsa -b 4096 -C "jenkins@your-vps"

# Copy public key to VPS
ssh-copy-id -i ~/.ssh/id_rsa.pub root@your-vps-ip
```

In Jenkins:
1. Go to Jenkins → Manage Jenkins → Configure System
2. Add SSH site: your-vps-ip, port 22, credentials (SSH Username with private key)

#### 2.3 Configure Flutter SDK in Jenkins
```bash
# In Jenkins container
sudo docker exec -it jenkins bash
cd /var/jenkins_home
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.x.x-stable.tar.xz
tar xf flutter_linux_3.x.x-stable.tar.xz
export PATH="$PATH:/var/jenkins_home/flutter/bin"
flutter doctor -v
```

### Phase 3: Create Jenkinsfile

The Jenkinsfile should be committed to your repository (see `Jenkinsfile` in repo root).

### Phase 4: Create Jenkins Job

1. Login to Jenkins
2. Click "New Item"
3. Name: "kimleng-wedding-deploy"
4. Choose "Pipeline"
5. Configure:
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: your-github-repo-url
   - Branch: main or master
   - Script Path: Jenkinsfile
6. Save

### Phase 5: Manual Trigger or Set Webhooks

#### Option A: Manual Trigger
- Click "Build Now" in Jenkins

#### Option B: GitHub Webhook (Automatic)
1. In Jenkins job: Configure → Build Triggers → GitHub hook trigger
2. In GitHub repo: Settings → Webhooks → Add webhook
3. Payload URL: `http://your-vps-ip:8080/github-webhook/`
4. Content type: application/json
5. Events: Just the push event
6. Save

## Deployment Flow

1. **Push code** to GitHub repository
2. **Jenkins detects** the change (via webhook or manual trigger)
3. **Jenkins fetches** the code
4. **Builds** Flutter web app (`flutter build web`)
5. **Transfers** build artifacts to VPS via SSH
6. **Deploys** files to `/var/www/kimleng-wedding`
7. **Reloads** Nginx to serve new version

## Rollback Plan

If deployment fails:
```bash
# On VPS, restore previous version
sudo cp -r /var/www/kimleng-wedding.backup /var/www/kimleng-wedding
sudo systemctl reload nginx
```

## Monitoring

### Check Jenkins Logs
```bash
sudo docker logs -f jenkins
```

### Check Nginx Logs
```bash
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### Check Application
```bash
curl -I http://your-domain.com
```

## Security Considerations

1. **Firewall**: Use UFW to manage ports
   ```bash
   sudo ufw allow 22/tcp
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw enable
   ```

2. **SSL/TLS**: Use Let's Encrypt for HTTPS
   ```bash
   sudo apt install certbot python3-certbot-nginx -y
   sudo certbot --nginx -d your-domain.com
   ```

3. **Jenkins Security**: Change default port, use strong passwords

4. **SSH Security**: Disable password auth, use key-based only

## Troubleshooting

### Jenkins Build Fails
- Check Flutter SDK installation in Jenkins container
- Verify Flutter PATH in pipeline
- Check build logs for specific errors

### Deployment Fails
- Verify SSH connection from Jenkins to VPS
- Check permissions on `/var/www/kimleng-wedding`
- Review deployment script syntax

### Nginx Issues
- Test configuration: `sudo nginx -t`
- Check file permissions
- Review Nginx error logs

## Cost Estimate

- DigitalOcean Droplet: $6-12/month (Basic plan)
- Domain (optional): $10-15/year
- Total: ~$82-159/year

## Next Steps

1. Follow Phase 1 to set up VPS
2. Set up Jenkins (Phase 2)
3. Add Jenkinsfile to repository
4. Create Jenkins job
5. Test deployment
6. Set up GitHub webhook for automatic deployment
7. Configure SSL certificate
8. Go live! 🎉

## Support

For issues, check:
- Jenkins console output
- VPS logs (`/var/log/`)
- Flutter build logs
- Nginx error logs

## Advanced Configuration

### Using Docker Compose for Jenkins (Recommended)

Create `docker-compose.yml` for easier Jenkins management:

```yaml
version: '3.8'

services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins
    restart: always
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
      - /usr/bin/docker:/usr/bin/docker
    environment:
      - JAVA_OPTS=-Xmx1024m
    networks:
      - jenkins_network

networks:
  jenkins_network:
    driver: bridge

volumes:
  jenkins_home:
```

Start Jenkins:
```bash
docker-compose up -d
```

### Post-Deployment Verification Checklist

After deployment, verify:

1. **Application Accessibility**
   ```bash
   curl -I http://your-domain.com
   # Should return HTTP 200
   ```

2. **Check Build Artifacts**
   ```bash
   ls -la /var/www/kimleng-wedding/web/
   # Should contain index.html and other build files
   ```

3. **Check Nginx Status**
   ```bash
   sudo systemctl status nginx
   # Should show "active (running)"
   ```

4. **Test from Browser**
   - Open http://your-domain.com
   - Check console for errors (F12)
   - Verify all images load
   - Test responsive design on mobile

5. **Performance Check**
   ```bash
   curl -w "@-" -o /dev/null -s "http://your-domain.com" <<'EOF'
   time_namelookup:  %{time_namelookup}\n
   time_connect:  %{time_connect}\n
   time_starttransfer:  %{time_starttransfer}\n
   time_total:  %{time_total}\n
   EOF
   ```

### Backup Strategy

Create automated backups:

```bash
# Create backup script: /root/backup-wedding-app.sh
#!/bin/bash
BACKUP_DIR="/root/backups"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR

# Backup web directory
tar -czf $BACKUP_DIR/web_backup_$DATE.tar.gz /var/www/kimleng-wedding

# Keep only last 7 days of backups
find $BACKUP_DIR -name "web_backup_*.tar.gz" -mtime +7 -delete

echo "Backup completed: $BACKUP_DIR/web_backup_$DATE.tar.gz"
```

Make it executable:
```bash
chmod +x /root/backup-wedding-app.sh
```

Add to crontab (daily at 2 AM):
```bash
crontab -e
# Add this line:
0 2 * * * /root/backup-wedding-app.sh >> /var/log/backup.log 2>&1
```

### Performance Optimization

#### Enable Nginx Caching
Add to `/etc/nginx/sites-available/kimleng-wedding`:

```nginx
# FastCGI cache settings (optional)
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m max_size=100m inactive=60m;

# Add to server block:
location ~* \.(wasm)$ {
    proxy_cache my_cache;
    proxy_cache_valid 200 1d;
    add_header Cache-Control "public, max-age=86400";
}
```

#### Flutter Web Optimization
Update `pubspec.yaml`:

```yaml
flutter:
  build-web:
    base-href: "/"
```

Build with optimization flags:
```bash
flutter build web --release --web-renderer canvaskit --csp
```

### Security Hardening

#### 1. Fail2Ban Setup
```bash
sudo apt install fail2ban -y
sudo systemctl start fail2ban
sudo systemctl enable fail2ban
```

#### 2. Disable Root Login
```bash
sudo nano /etc/ssh/sshd_config
# Set: PermitRootLogin no
sudo systemctl restart sshd
```

#### 3. Set Up SSH Key Only
```bash
sudo nano /etc/ssh/sshd_config
# Set:
# PasswordAuthentication no
# PubkeyAuthentication yes
sudo systemctl restart sshd
```

#### 4. Jenkins Security Headers
Install "Strict Crumb Issuer" plugin and configure:
- Jenkins → Configure Global Security
- Enable CSRF Protection
- Add "Host Name Verification" under SSH Server

### SSL/TLS Configuration

#### Install Certbot
```bash
sudo apt install certbot python3-certbot-nginx -y
```

#### Obtain Certificate
```bash
sudo certbot --nginx -d your-domain.com -d www.your-domain.com
```

#### Auto-renewal
```bash
sudo certbot renew --dry-run
# Add to crontab:
sudo crontab -e
# Add: 0 0,12 * * * certbot renew --quiet
```

#### Update Nginx Config for SSL
```nginx
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    
    # Redirect HTTP to HTTPS
    # ...
}

server {
    listen 80;
    listen [::]:80;
    server_name your-domain.com www.your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

### Monitoring Setup

#### Install Monitoring Tools
```bash
# Install htop for process monitoring
sudo apt install htop -y

# Install NetData for detailed monitoring (optional)
bash <(curl -Ss https://my-netdata.io/kickstart.sh)
```

#### Set Up Log Rotation
```bash
sudo nano /etc/logrotate.d/kimleng-wedding
```

Add:
```
/var/www/kimleng-wedding/web/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 www-data www-data
    sharedscripts
}
```

### Disaster Recovery

If everything fails, restore from backup:

```bash
# List available backups
ls -lh /root/backups/

# Restore latest backup
LATEST_BACKUP=$(ls -t /root/backups/web_backup_*.tar.gz | head -1)
sudo rm -rf /var/www/kimleng-wedding/web/*
sudo tar -xzf $LATEST_BACKUP -C /
sudo systemctl reload nginx
```

### Scaling Considerations

If traffic increases:

1. **Enable Cloudflare CDN**
   - Sign up at cloudflare.com
   - Add domain
   - Update nameservers
   - Enable caching

2. **Upgrade VPS Resources**
   - DigitalOcean: Resize droplet
   - More RAM for Jenkins builds
   - Faster CPU for build process

3. **Implement Load Balancing** (if needed)
   - Add multiple Nginx instances
   - Use HAProxy or Nginx as load balancer

### Maintenance Schedule

**Weekly:**
- Check Jenkins builds are succeeding
- Review Nginx logs for errors
- Verify backup integrity

**Monthly:**
- Update system packages
- Review SSL certificate expiry
- Check disk space usage

**Quarterly:**
- Security audit
- Performance review
- Update dependencies in Flutter app

## Quick Reference Commands

### Jenkins
```bash
# Start Jenkins
docker-compose up -d

# Stop Jenkins
docker-compose down

# View logs
docker logs -f jenkins

# Restart Jenkins
docker restart jenkins
```

### Nginx
```bash
# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx

# Restart Nginx
sudo systemctl restart nginx

# View logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### Application
```bash
# Check app status
sudo ls -la /var/www/kimleng-wedding/web/

# Check permissions
sudo chown -R www-data:www-data /var/www/kimleng-wedding

# Free up disk space
sudo apt autoremove
sudo apt autoclean
```

### SSH
```bash
# Connect to VPS
ssh root@your-vps-ip

# Copy files to VPS
scp -r build/web/* root@your-vps-ip:/var/www/kimleng-wedding/web/

# Check SSH connections
who
```

## Conclusion

This deployment plan provides a comprehensive guide to deploy your Flutter web app using Jenkins to a DigitalOcean VPS. The setup ensures:

✅ **Automated deployments** with Jenkins CI/CD  
✅ **Secure hosting** with Nginx and SSL  
✅ **Backup strategy** for disaster recovery  
✅ **Monitoring** and maintenance procedures  
✅ **Scalability** for future growth  

Following this plan will result in a production-ready deployment that's secure, maintainable, and scalable. 🎉

