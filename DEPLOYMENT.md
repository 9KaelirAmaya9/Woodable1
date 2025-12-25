# Production Deployment Guide

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose installed
- Domain name configured (DNS pointing to server)
- Required API keys (Stripe, Google Maps, Email service)

### Deployment Steps

1. **Configure Environment**
   ```bash
   cp .env.production .env
   # Edit .env and fill in ALL required values
   ```

2. **Validate Configuration**
   ```bash
   node scripts/validate-env.js
   ```

3. **Deploy**
   ```bash
   ./scripts/deploy-production.sh
   ```

4. **Access Application**
   - Frontend: `https://losricostacos.com`
   - Admin: Login with credentials from setup-admins output

---

## 📋 Detailed Configuration

### Required Environment Variables

#### Security (CRITICAL)
```env
JWT_SECRET=<64-byte-hex-string>
POSTGRES_PASSWORD=<strong-password>
```

Generate JWT secret:
```bash
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

#### Email Service
Choose one:

**Gmail:**
```env
EMAIL_USER=your_email@gmail.com
EMAIL_PASSWORD=<gmail-app-password>
```

**SendGrid:**
```env
SENDGRID_API_KEY=<your-key>
```

#### Payment (Stripe)
```env
STRIPE_SECRET_KEY=sk_live_...
STRIPE_PUBLISHABLE_KEY=pk_live_...
```

#### Maps API
```env
REACT_APP_GOOGLE_MAPS_API_KEY=<your-key>
```

#### Domain & SSL
```env
WEBSITE_DOMAIN=losricostacos.com
TRAEFIK_CERT_EMAIL=<your-email>
```

---

## 🗄️ Database Management

### Initialize Database
```bash
docker exec base2_backend node /app/scripts/init-database.js
```

### Setup Admin Users
```bash
docker exec base2_backend node /app/scripts/setup-admins.js
```

### Seed Menu Data
```bash
docker exec base2_backend node /app/scripts/seed-menu.js
```

### Backup Database
```bash
docker exec base2_postgres pg_dump -U losricostacos_user losricostacos_db > backup_$(date +%Y%m%d).sql
```

### Restore Database
```bash
cat backup_20231212.sql | docker exec -i base2_postgres psql -U losricostacos_user losricostacos_db
```

---

## 🔍 Monitoring & Troubleshooting

### View Logs
```bash
# All services
docker-compose -f local.docker.yml logs -f

# Specific service
docker logs base2_backend -f
docker logs base2_postgres -f
docker logs base2_nginx -f
```

### Check Service Health
```bash
docker ps
docker inspect --format='{{.State.Health.Status}}' base2_backend
```

### Access Services
- **pgAdmin**: `http://localhost:5050`
- **Traefik Dashboard**: `http://localhost:8082/dashboard/`
- **Backend Health**: `http://localhost:5000/api/health`

### Common Issues

**Services not starting:**
```bash
docker-compose -f local.docker.yml down
docker-compose -f local.docker.yml up -d --build
```

**Database connection errors:**
- Check `DB_PASSWORD` matches `POSTGRES_PASSWORD`
- Verify postgres container is healthy
- Check logs: `docker logs base2_postgres`

**SSL certificate not obtained:**
- Verify DNS is pointing to server
- Check ports 80 and 443 are open
- Verify `TRAEFIK_CERT_EMAIL` is set
- Check Traefik logs: `docker logs base2_traefik`

---

## 🔄 Updates & Maintenance

### Deploy Updates
```bash
git pull origin main
./scripts/deploy-production.sh
```

### Rollback
```bash
git checkout <previous-commit>
./scripts/deploy-production.sh
```

### Scale Services
Edit `local.docker.yml` and adjust:
```yaml
deploy:
  replicas: 3
```

---

## 🔐 Security Checklist

- [ ] Changed all default passwords
- [ ] JWT secret is 64-byte random hex
- [ ] Using production Stripe keys (sk_live_)
- [ ] SSL certificates obtained and valid
- [ ] Database backups configured
- [ ] Admin passwords changed from temporary
- [ ] Email service configured and tested
- [ ] Rate limiting enabled
- [ ] CORS configured for production domain only

---

## 📊 Performance Optimization

### Database
- Enable connection pooling (already configured)
- Regular VACUUM and ANALYZE
- Monitor slow queries

### Backend
- Enable caching for menu items
- Optimize image delivery
- Monitor memory usage

### Frontend
- Enable gzip compression (Nginx)
- CDN for static assets
- Lazy load images

---

## 🆘 Support

### Logs Location
- Backend: `/var/log/backend/`
- Nginx: `/var/log/nginx/`
- Traefik: Docker logs

### Health Endpoints
- Backend: `GET /api/health`
- Database: `docker exec base2_postgres pg_isready`

### Emergency Contacts
- Admin 1: albertijan@gmail.com
- Admin 2: fortosopedro148@gmail.com
