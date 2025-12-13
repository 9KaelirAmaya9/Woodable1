# Digital Ocean Production Deployment

## Overview

You now have **two deployment options**:

1. **Automated Digital Ocean Deployment** - Creates droplet, configures DNS, deploys app
2. **Manual Server Deployment** - Deploy to any server with Docker

---

## Option 1: Automated Digital Ocean Deployment (Recommended)

### Prerequisites

1. **Digital Ocean Account**
   - Sign up at https://www.digitalocean.com
   - Get API token: Account → API → Generate New Token

2. **Python Environment**
   ```bash
   cd digital_ocean
   python -m venv .venv
   source .venv/bin/activate  # Windows: .venv\Scripts\activate
   pip install -r requirements.txt
   ```

3. **Configure .env**
   ```env
   DO_API_TOKEN=your_digital_ocean_api_token
   DO_DROPLET_NAME=losricostacos-prod
   DO_API_REGION=nyc3
   DO_API_SIZE=s-2vcpu-4gb
   WEBSITE_DOMAIN=losricostacos.com
   ```

### Deployment Steps

```bash
# 1. Activate Python environment
cd digital_ocean
source .venv/bin/activate

# 2. Run deployment
python deploy_production.py
```

**What it does:**
1. ✅ Generates SSH key for deployment
2. ✅ Uploads SSH key to Digital Ocean
3. ✅ Creates droplet with Docker pre-installed
4. ✅ Updates DNS A records automatically
5. ✅ Waits for droplet to be ready
6. ✅ Clones repository to droplet

**After deployment completes:**

```bash
# SSH into your new droplet
ssh -i ~/.ssh/losricostacos_deploy root@<droplet-ip>

# Navigate to app directory
cd /opt/losricostacos/base2

# Configure environment
cp .env.production .env
nano .env  # Fill in production values

# Validate configuration
node scripts/validate-env.js

# Deploy application
./scripts/deploy-production.sh
```

---

## Option 2: Manual Server Deployment

If you already have a server or prefer manual setup:

### 1. Server Requirements
- Ubuntu 22.04 or later
- Docker & Docker Compose installed
- Ports 80, 443, 22 open
- At least 2GB RAM, 2 vCPU

### 2. Deploy to Server

```bash
# SSH into your server
ssh user@your-server.com

# Install Docker (if needed)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Clone repository
git clone https://github.com/9KaelirAmaya9/Woodable1.git
cd Woodable1/base2
git checkout production-deploy

# Configure environment
cp .env.production .env
nano .env  # Fill in ALL production values

# Validate configuration
node scripts/validate-env.js

# Deploy
./scripts/deploy-production.sh
```

---

## Post-Deployment Configuration

### 1. Configure DNS (If not using DO automation)

Point your domain to the server IP:

```
Type: A
Name: @
Value: <your-server-ip>
TTL: 3600

Type: A
Name: www
Value: <your-server-ip>
TTL: 3600
```

### 2. Wait for SSL Certificate

Traefik will automatically obtain SSL certificates from Let's Encrypt.
This requires:
- DNS pointing to your server
- Ports 80 and 443 accessible
- `TRAEFIK_CERT_EMAIL` set in .env

Check certificate status:
```bash
docker logs base2_traefik | grep -i certificate
```

### 3. Verify Deployment

```bash
# Check service health
docker ps

# View logs
docker-compose -f local.docker.yml logs -f

# Test backend
curl http://localhost:5000/api/health

# Test frontend
curl http://localhost:3000
```

### 4. Change Admin Passwords

The setup script creates admins with temporary passwords.

**CRITICAL**: Have admins change their passwords immediately:
1. Login at https://losricostacos.com
2. Go to User Settings
3. Change password

---

## Monitoring & Maintenance

### View Logs
```bash
# All services
docker-compose -f local.docker.yml logs -f

# Specific service
docker logs base2_backend -f
```

### Restart Services
```bash
docker-compose -f local.docker.yml restart
```

### Update Application
```bash
cd /opt/losricostacos/base2
git pull origin main
./scripts/deploy-production.sh
```

### Database Backup
```bash
# Create backup
docker exec base2_postgres pg_dump -U losricostacos_user losricostacos_db > backup_$(date +%Y%m%d).sql

# Restore backup
cat backup_20231212.sql | docker exec -i base2_postgres psql -U losricostacos_user losricostacos_db
```

---

## Troubleshooting

### Droplet Creation Fails
```bash
# Check Digital Ocean API token
echo $DO_API_TOKEN

# Verify account has available droplets
# Check Digital Ocean dashboard
```

### DNS Not Updating
- Verify domain is added to Digital Ocean
- Check DNS propagation: https://dnschecker.org
- Manual update: Digital Ocean → Networking → Domains

### SSL Certificate Not Obtained
```bash
# Check Traefik logs
docker logs base2_traefik

# Verify DNS is pointing to server
dig losricostacos.com

# Verify ports are open
sudo ufw status
```

### Services Not Starting
```bash
# Check Docker logs
docker-compose -f local.docker.yml logs

# Restart all services
docker-compose -f local.docker.yml down
docker-compose -f local.docker.yml up -d --build
```

---

## Cost Estimate (Digital Ocean)

**Recommended Droplet**: `s-2vcpu-4gb`
- 2 vCPUs
- 4GB RAM
- 80GB SSD
- **Cost**: ~$24/month

**Alternative (Smaller)**: `s-1vcpu-2gb`
- 1 vCPU
- 2GB RAM
- 50GB SSD
- **Cost**: ~$12/month
- ⚠️ May be slower under load

---

## Security Checklist

After deployment:

- [ ] Changed all admin passwords from temporary
- [ ] Configured strong JWT secret
- [ ] Using production Stripe keys
- [ ] SSL certificates obtained and valid
- [ ] Firewall configured (ports 22, 80, 443 only)
- [ ] Database backups scheduled
- [ ] Monitoring alerts configured
- [ ] `.env` file secured (not in git)

---

## Support

### Access Points
- Frontend: https://losricostacos.com
- Admin: https://losricostacos.com/admin
- pgAdmin: http://<server-ip>:5050
- Traefik: http://<server-ip>:8082/dashboard/

### Emergency Access
```bash
# SSH into droplet
ssh -i ~/.ssh/losricostacos_deploy root@<droplet-ip>

# View all logs
cd /opt/losricostacos/base2
docker-compose -f local.docker.yml logs --tail=100
```
