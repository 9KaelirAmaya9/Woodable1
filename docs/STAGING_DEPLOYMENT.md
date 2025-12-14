# Staging Deployment Guide

## Purpose

Deploy to a staging environment BEFORE production to:
- Test with production-like setup
- Verify SSL/HTTPS configuration
- Test with real domain
- Validate CI/CD pipeline
- Catch environment-specific issues

---

## Option 1: Digital Ocean Staging Droplet

### 1. Create Staging Droplet

```bash
# Use Digital Ocean CLI or web interface
doctl compute droplet create staging-base2 \
  --image ubuntu-24-04-x64 \
  --size s-1vcpu-1gb \
  --region nyc1 \
  --ssh-keys your-ssh-key-id \
  --tag staging

# Get droplet IP
doctl compute droplet list | grep staging-base2
```

### 2. Configure DNS

Add A record:
```
staging.losricostacos.com → [STAGING_DROPLET_IP]
```

### 3. Deploy to Staging

**SSH into staging droplet:**
```bash
ssh root@staging.losricostacos.com

# Clone repo
git clone https://github.com/9KaelirAmaya9/Woodable1.git
cd Woodable1

# Checkout your branch
git checkout claude/audit-repo-robustness-01GpYpfRn8MTrjcC12JAqjoU

# Create staging .env
cp .env.example .env
nano .env
```

**Update .env for staging:**
```env
NODE_ENV=staging
FRONTEND_URL=https://staging.losricostacos.com
WEBSITE_DOMAIN=staging.losricostacos.com

# Strong secrets
JWT_SECRET=[generate-new-random-64-char-string]
POSTGRES_PASSWORD=[strong-password]
DB_PASS=[strong-password]

# Email (use real credentials for testing)
EMAIL_HOST=smtp.gmail.com
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-app-password

# Sentry (use staging DSN)
SENTRY_DSN=https://staging-dsn@sentry.io/project-id
SENTRY_ENVIRONMENT=staging
```

**Start services:**
```bash
./scripts/start.sh --build

# Wait for services to be healthy
./scripts/health.sh
```

### 4. Configure SSL

Traefik will auto-provision Let's Encrypt certificate for:
- `staging.losricostacos.com`

Verify SSL:
```bash
curl -I https://staging.losricostacos.com
```

### 5. Run Database Migrations

```bash
docker compose -f local.docker.yml exec postgres psql -U myuser -d mydatabase -f /docker-entrypoint-initdb.d/schema.sql
docker compose -f local.docker.yml exec postgres psql -U myuser -d mydatabase -f /docker-entrypoint-initdb.d/migration_v2.sql
docker compose -f local.docker.yml exec postgres psql -U myuser -d mydatabase -f /docker-entrypoint-initdb.d/migration_v3_orders.sql
```

### 6. Seed Staging Data

```bash
# Add sample menu items for testing
docker compose -f local.docker.yml exec backend node scripts/seed-menu.js
```

---

## Option 2: GitHub Actions Staging Workflow

### Create `.github/workflows/staging.yml`:

```yaml
name: Deploy to Staging

on:
  push:
    branches:
      - develop
      - 'claude/**'
  workflow_dispatch:

jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    environment: staging

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Deploy to Staging Server
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.STAGING_HOST }}
          username: root
          key: ${{ secrets.STAGING_SSH_KEY }}
          script: |
            cd /opt/apps/Woodable1
            git pull origin ${{ github.ref_name }}
            docker compose -f local.docker.yml down
            docker compose -f local.docker.yml up -d --build
            sleep 10

      - name: Health Check
        run: |
          max_attempts=5
          attempt=0
          while [ $attempt -lt $max_attempts ]; do
            if curl -sf https://staging.losricostacos.com/api/health; then
              echo "✅ Staging deployment successful!"
              exit 0
            fi
            attempt=$((attempt + 1))
            echo "Attempt $attempt/$max_attempts failed, retrying..."
            sleep 5
          done
          echo "❌ Staging deployment health check failed"
          exit 1

      - name: Notify Deployment
        if: always()
        run: |
          if [ $? -eq 0 ]; then
            echo "✅ Staging deployed: https://staging.losricostacos.com"
          else
            echo "❌ Staging deployment failed"
          fi
```

**Add secrets to GitHub:**
- `STAGING_HOST`: staging.losricostacos.com
- `STAGING_SSH_KEY`: SSH private key

---

## Option 3: Docker Compose Staging Profile

### Update `local.docker.yml`:

Add staging-specific overrides:
```yaml
# At bottom of file
x-staging:
  &staging-env
  NODE_ENV: staging
  SENTRY_ENVIRONMENT: staging
```

---

## Staging Testing Checklist

Once deployed to staging, test:

### Functional Tests
- [ ] Run E2E tests: `./scripts/e2e-test.sh`
- [ ] Manual user registration
- [ ] Manual order placement
- [ ] Admin dashboard access
- [ ] Menu management

### Infrastructure Tests
- [ ] SSL certificate valid (https://)
- [ ] Health endpoint responds
- [ ] Database migrations applied
- [ ] Email sending works
- [ ] Google OAuth works

### Security Tests
- [ ] No default passwords in .env
- [ ] CORS allows only staging domain
- [ ] Rate limiting active
- [ ] JWT tokens expire correctly

### Performance Tests
- [ ] Run load test: `./scripts/load-test.sh`
- [ ] Check response times < 1s
- [ ] Monitor memory usage
- [ ] Test concurrent orders

### Monitoring Tests
- [ ] Sentry captures errors
- [ ] Uptime monitor pinging
- [ ] Logs writing to files
- [ ] Alerts triggered when service down

---

## Rollback Procedure

If staging deployment fails:

```bash
ssh root@staging.losricostacos.com

cd /opt/apps/Woodable1

# Rollback to previous commit
git log --oneline -5  # Find previous good commit
git checkout [previous-commit-sha]

# Restart services
docker compose -f local.docker.yml down
docker compose -f local.docker.yml up -d --build

# Verify health
curl https://staging.losricostacos.com/api/health
```

---

## Promotion to Production

Once staging is stable:

1. **Merge to main:**
   ```bash
   git checkout main
   git merge claude/audit-repo-robustness-01GpYpfRn8MTrjcC12JAqjoU
   git push origin main
   ```

2. **Auto-deploy to production:**
   - GitHub Actions workflow triggers
   - Deploys to losricostacos.com

3. **Verify production:**
   ```bash
   curl https://losricostacos.com/api/health
   ```

4. **Monitor for 24 hours:**
   - Watch error rates in Sentry
   - Check uptime monitors
   - Review logs for issues

---

## Costs

**Staging Droplet:**
- $6/month (1vCPU, 1GB RAM, 25GB SSD)
- Can destroy when not in use to save costs

**Alternatives:**
- Use production with feature flags
- Test locally with production-like config
- Use preview deployments (Vercel, Netlify for frontend)
