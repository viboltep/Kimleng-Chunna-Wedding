# Deployment Cheat Sheet

Quick reference for deploying the Kimleng & Chunna Wedding Invitation app.

## 🚀 Initial Setup

### On VPS (First Time)
```bash
# Upload and run setup script
scp kimleng_chunna_wedding/server-setup.sh root@your-vps-ip:/root/
ssh root@your-vps-ip "chmod +x /root/server-setup.sh && /root/server-setup.sh"

# Install Jenkins with Docker Compose
cd /root
mkdir jenkins && cd jenkins
# Upload docker-compose.yml to this directory
docker-compose up -d

# Get Jenkins password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### Configure SSH (Local Machine)
```bash
# Generate SSH key if needed
ssh-keygen -t rsa -b 4096

# Copy to VPS
ssh-copy-id root@your-vps-ip

# Test connection
ssh root@your-vps-ip "echo 'SSH works!'"
```

## 🔧 Configuration Updates

### Update Jenkinsfile
```bash
# Edit Jenkinsfile
nano kimleng_chunna_wedding/Jenkinsfile

# Update these lines:
# VPS_HOST = 'your-vps-ip-or-domain'
# VPS_USER = 'root'
# DEPLOY_PATH = '/var/www/kimleng-wedding'

# Commit changes
git add kimleng_chunna_wedding/Jenkinsfile
git commit -m "Update deployment config"
git push
```

### Update Nginx Config (on VPS)
```bash
# Edit config
sudo nano /etc/nginx/sites-available/kimleng-wedding

# Update server_name if you have a domain
server_name your-domain.com;

# Test and reload
sudo nginx -t
sudo systemctl reload nginx
```

## 🚢 Deployment Commands

### Manual Deployment
```bash
# Build locally
cd kimleng_chunna_wedding
flutter clean
flutter pub get
flutter build web --release

# Deploy to VPS
rsync -avz --delete build/web/ root@your-vps-ip:/var/www/kimleng-wedding/web/

# Reload Nginx
ssh root@your-vps-ip "sudo systemctl reload nginx"
```

### Automated Deployment (via Jenkins)
```bash
# Push to GitHub (triggers Jenkins)
git add .
git commit -m "Your commit message"
git push origin main

# Or trigger manually in Jenkins UI:
# http://your-vps-ip:8080 → kimleng-wedding-deploy → Build Now
```

### GitHub Actions Deployment (Alternative)
```bash
# Set up secrets in GitHub repo:
# Settings → Secrets → New repository secret
# VPS_HOST: your-vps-ip
# VPS_USER: root
# SSH_PRIVATE_KEY: your-private-key

# Push to trigger
git push origin main
```

## 🛠️ Troubleshooting

### Jenkins Issues
```bash
# Check Jenkins status
docker ps | grep jenkins

# View Jenkins logs
docker logs -f jenkins

# Restart Jenkins
docker restart jenkins

# Rebuild Jenkins
docker-compose down
docker-compose up -d
```

### Build Issues
```bash
# Check Flutter version
flutter --version

# Clean build
flutter clean
flutter pub get
flutter build web --release

# Check for errors
flutter doctor -v
```

### Deployment Issues
```bash
# Test SSH connection
ssh root@your-vps-ip "ls -la /var/www/kimleng-wedding"

# Check Nginx status
sudo systemctl status nginx

# Check Nginx logs
sudo tail -f /var/log/nginx/error.log

# Check file permissions
sudo chown -R www-data:www-data /var/www/kimleng-wedding
```

### App Not Loading
```bash
# Check if files exist
ls -la /var/www/kimleng-wedding/web/

# Check Nginx config
sudo nginx -t

# Test from server
curl http://localhost

# Check firewall
sudo ufw status
```

## 🔒 Security Setup

### SSL Certificate
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Get certificate
sudo certbot --nginx -d your-domain.com

# Test renewal
sudo certbot renew --dry-run
```

### Firewall
```bash
# Allow required ports
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable

# Check status
sudo ufw status verbose
```

### SSH Security
```bash
# Edit SSH config
sudo nano /etc/ssh/sshd_config

# Add these lines:
# PermitRootLogin no
# PasswordAuthentication no
# PubkeyAuthentication yes

# Restart SSH
sudo systemctl restart sshd
```

## 📊 Monitoring

### Check App Status
```bash
# HTTP status
curl -I http://your-vps-ip

# Response time
curl -o /dev/null -s -w '%{time_total}\n' http://your-vps-ip

# Check disk space
df -h

# Check memory usage
free -h
```

### View Logs
```bash
# Jenkins build logs
# Access: http://your-vps-ip:8080 → kimleng-wedding-deploy → Build # → Console Output

# Nginx access logs
sudo tail -f /var/log/nginx/access.log

# Nginx error logs
sudo tail -f /var/log/nginx/error.log

# System logs
sudo journalctl -u nginx -f
```

## 🔄 Maintenance

### Backup
```bash
# Manual backup
sudo tar -czf ~/backup-$(date +%Y%m%d).tar.gz /var/www/kimleng-wedding/

# Restore backup
sudo tar -xzf ~/backup-TIMESTAMP.tar.gz -C /
```

### Updates
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Update Flutter (in Jenkins)
docker exec -it jenkins bash
cd /var/jenkins_home
flutter upgrade

# Update Jenkins
docker-compose pull
docker-compose up -d
```

### Cleanup
```bash
# Remove old builds
docker system prune -a

# Remove old backups (keep last 7 days)
find ~/backups -name "*.tar.gz" -mtime +7 -delete

# Clear Nginx cache
sudo rm -rf /var/cache/nginx/*
```

## 📋 Useful Aliases

Add to `~/.bashrc` or `~/.zshrc`:

```bash
# Deployment aliases
alias deploy='cd kimleng_chunna_wedding && flutter build web --release'
alias deploy-now='deploy && rsync -avz build/web/ root@your-vps-ip:/var/www/kimleng-wedding/web/ && ssh root@your-vps-ip "sudo systemctl reload nginx"'
alias jenkins-logs='ssh root@your-vps-ip "docker logs -f jenkins"'
alias nginx-logs='ssh root@your-vps-ip "sudo tail -f /var/log/nginx/error.log"'
alias app-status='curl -I http://your-vps-ip'

# After adding, reload shell
source ~/.bashrc
```

## 🎯 Quick Deployment Workflow

```bash
# 1. Make changes to your code
nano lib/main.dart

# 2. Commit changes
git add .
git commit -m "Update features"
git push

# 3. Wait for Jenkins (or check status)
curl http://your-vps-ip:8080

# 4. Verify deployment
curl -I http://your-vps-ip

# Done! 🎉
```

## 📞 Emergency Rollback

```bash
# List backups
ssh root@your-vps-ip "ls -lh /root/backups/"

# Restore latest backup
ssh root@your-vps-ip "cd /var/www/kimleng-wedding && LATEST=\$(ls -t /root/backups/web_backup_*.tar.gz | head -1) && sudo tar -xzf \$LATEST -C / && sudo systemctl reload nginx"

# Verify
curl -I http://your-vps-ip
```

## 🎓 Learning Resources

- Jenkins Pipeline Syntax: https://www.jenkins.io/doc/book/pipeline/
- Flutter Web: https://flutter.dev/web
- Nginx Configuration: https://nginx.org/en/docs/
- DigitalOcean Community: https://www.digitalocean.com/community

---

**Tip**: Bookmark this file for quick reference during deployment!

