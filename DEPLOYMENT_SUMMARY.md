# Kimleng & Chunna Wedding Invitation - Deployment Summary

## 📋 Overview
Complete deployment plan for the Flutter Web wedding invitation app to DigitalOcean Ubuntu VPS using Jenkins CI/CD.

## 🚀 Quick Start

### 1. VPS Setup
Run the automated setup script on your DigitalOcean VPS:
```bash
# On your VPS
curl -O https://raw.githubusercontent.com/your-repo/kimleng_chunna_wedding/master/server-setup.sh
chmod +x server-setup.sh
sudo ./server-setup.sh
```

Or manually follow the steps in `JENKINS_DEPLOYMENT_PLAN.md`.

### 2. Jenkins Setup
```bash
# Start Jenkins using Docker Compose
cd kimleng_chunna_wedding
docker-compose up -d

# Get initial password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

# Access Jenkins at http://your-vps-ip:8080
```

### 3. Configure Jenkins Job
1. Install suggested plugins
2. Create admin user
3. New Item → Pipeline
4. Configure Git repository
5. Point to `Jenkinsfile` in repo
6. Save and run

## 📁 Files Created

### Core Files
- `JENKINS_DEPLOYMENT_PLAN.md` - Complete deployment guide
- `Jenkinsfile` - CI/CD pipeline configuration
- `docker-compose.yml` - Jenkins container setup
- `server-setup.sh` - Automated VPS preparation

### Alternative Options
- `.github/workflows/deploy.yml` - GitHub Actions (alternative to Jenkins)
- `deploy.sh` - Manual deployment script

## 🔧 Configuration Required

### Update Jenkinsfile
Before deploying, update these variables in `Jenkinsfile`:
```groovy
VPS_HOST = 'your-vps-ip-or-domain'
VPS_USER = 'root'  // or your preferred user
DEPLOY_PATH = '/var/www/kimleng-wedding'
```

### Update server-setup.sh
Update domain name in Nginx configuration if you have a domain.

## 📊 Architecture

```
┌─────────────┐
│  GitHub     │
│  Repository │
└──────┬──────┘
       │ Push code
       ▼
┌─────────────┐
│  Jenkins    │ (Docker on VPS)
│  CI/CD      │
└──────┬──────┘
       │ Build & Test
       ▼
┌─────────────┐
│  Flutter    │
│  Build Web  │
└──────┬──────┘
       │ Deploy
       ▼
┌─────────────┐
│   Nginx     │
│  Web Server │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Users     │
│   Browser   │
└─────────────┘
```

## 🎯 Deployment Flow

1. **Developer** pushes code to GitHub
2. **Jenkins** detects the change (webhook)
3. **Pipeline** runs:
   - Checkout code
   - Setup Flutter
   - Install dependencies
   - Run tests
   - Build web app
   - Deploy to VPS
   - Reload Nginx
4. **Users** see updated site

## 🔐 Security Checklist

- [ ] SSH key-based authentication only
- [ ] Firewall configured (UFW)
- [ ] Jenkins behind reverse proxy or VPN
- [ ] SSL certificate installed (Let's Encrypt)
- [ ] Strong Jenkins admin password
- [ ] Fail2Ban configured
- [ ] Root login disabled
- [ ] Regular security updates

## 📈 Monitoring

### Check System Status
```bash
# Check Jenkins
docker ps | grep jenkins

# Check Nginx
sudo systemctl status nginx

# Check disk space
df -h

# Check memory
free -h
```

### View Logs
```bash
# Jenkins logs
docker logs -f jenkins

# Nginx access logs
sudo tail -f /var/log/nginx/access.log

# Nginx error logs
sudo tail -f /var/log/nginx/error.log
```

## 🛠️ Troubleshooting

### Common Issues

**Jenkins won't start**
```bash
# Check Docker
docker ps
docker logs jenkins

# Restart Jenkins
docker restart jenkins
```

**Build fails**
- Check Flutter installation in Jenkins
- Verify PATH in Jenkinsfile
- Check Flutter version compatibility

**Deployment fails**
- Verify SSH connection
- Check permissions on /var/www/kimleng-wedding
- Ensure Nginx is running

**503 Error**
- Check Nginx status
- Verify files in /var/www/kimleng-wedding/web
- Check Nginx configuration: `sudo nginx -t`

## 🔄 Rollback Procedure

If deployment fails:
```bash
# On VPS
cd /var/www/kimleng-wedding
ls -la web.backup-*

# Restore backup
sudo cp -r web.backup-TIMESTAMP/* web/
sudo systemctl reload nginx
```

## 💰 Cost Breakdown

| Item | Cost/Month | Cost/Year |
|------|-----------|-----------|
| DigitalOcean Droplet (2GB) | $12 | $144 |
| Domain Name (optional) | - | $12 |
| SSL Certificate (Let's Encrypt) | Free | Free |
| **Total** | **$12** | **$156** |

## 📚 Additional Resources

- [Flutter Web Deployment](https://flutter.dev/docs/deployment/web)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [DigitalOcean Tutorials](https://www.digitalocean.com/community/tutorials)

## ✅ Pre-Deployment Checklist

- [ ] DigitalOcean VPS created
- [ ] SSH access configured
- [ ] Domain name configured (optional)
- [ ] Jenkins installed and running
- [ ] Flutter SDK installed in Jenkins
- [ ] SSH keys configured
- [ ] Jenkinsfile updated with VPS details
- [ ] Jenkins job created
- [ ] Webhook configured (optional)
- [ ] Nginx configured
- [ ] SSL certificate installed (optional)
- [ ] Firewall configured
- [ ] Backup script created

## 🎉 Going Live

Once all steps are complete:

1. Push code to main branch
2. Jenkins will automatically build and deploy
3. Visit your site at http://your-vps-ip or https://your-domain.com
4. Monitor deployment logs in Jenkins
5. Check site is working
6. Celebrate! 🎊

## 📞 Support

For detailed instructions, see:
- **JENKINS_DEPLOYMENT_PLAN.md** - Complete deployment guide
- **Jenkinsfile** - Pipeline configuration
- **server-setup.sh** - VPS setup script

---

**Ready to deploy?** Follow the steps in `JENKINS_DEPLOYMENT_PLAN.md`!

