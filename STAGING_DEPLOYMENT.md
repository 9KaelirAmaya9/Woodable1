# Rico's Tacos - Staging Environment Deployment Guide

Complete guide for deploying the Rico's Tacos application to the Digital Ocean staging environment.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Third-Party Service Setup](#third-party-service-setup)
3. [Environment Configuration](#environment-configuration)
4. [Deployment Process](#deployment-process)
5. [Post-Deployment Setup](#post-deployment-setup)
6. [Testing & Verification](#testing--verification)
7. [Troubleshooting](#troubleshooting)
8. [Rollback & Cleanup](#rollback--cleanup)

---

## Prerequisites

### Required Tools

- **Python 3.10+** - For deployment scripts
- **Node.js 18+** - For local development and testing
- **Git** - For version control
- **SSH** - For server access

### Required Accounts

You'll need accounts for these services:

- [Digital Ocean](https://www.digitalocean.com) - Cloud hosting
- [Stripe](https://stripe.com) - Payment processing
- [SendGrid](https://sendgrid.com) - Email delivery
- [Google Cloud](https://console.cloud.google.com) - Maps API

### Estimated Setup Time

- **First-time setup**: 1-2 hours (including account creation)
- **Subsequent deployments**: 10-15 minutes

---

## Third-Party Service Setup

Follow the detailed guide in [THIRD_PARTY_SETUP.md](file:///Users/jancarlosinc/Desktop/Coding/Axonic/Woodable1/THIRD_PARTY_SETUP.md) to set up all required services.

### Quick Checklist

- [ ] Digital Ocean API token obtained
- [ ] Digital Ocean SSH key added
- [ ] Stripe test mode keys obtained
- [ ] SendGrid API key created and sender verified
- [ ] Google Maps API key created and restricted
- [ ] (Optional) Domain name registered

---

## Environment Configuration

### Step 1: Create Staging Environment File

```bash
# Copy the staging template
cp .env.staging.template .env.staging
```

### Step 2: Generate Secure Secrets

Generate strong random secrets for JWT and database:

```bash
# Generate JWT secret (64+ characters)
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"

# Generate database password (32+ characters)
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# Generate session secret (64+ characters)
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

### Step 3: Edit .env.staging

Open `.env.staging` and replace all `CHANGE_ME_*` placeholders:

#### Digital Ocean Configuration

```bash
DO_API_TOKEN=dop_v1_YOUR_TOKEN_HERE
DO_SSH_KEY_ID=12345678
DO_DROPLET_NAME=ricostacos-staging
DO_API_REGION=nyc3
DO_API_SIZE=s-1vcpu-2gb
```

#### Database Configuration

```bash
POSTGRES_USER=ricostacos_staging
POSTGRES_PASSWORD=<YOUR_GENERATED_PASSWORD>
POSTGRES_DB=ricostacos_staging
DB_USER=ricostacos_staging
DB_PASS=<SAME_AS_POSTGRES_PASSWORD>
```

#### Authentication & Security

```bash
JWT_SECRET=<YOUR_GENERATED_JWT_SECRET>
SESSION_SECRET=<YOUR_GENERATED_SESSION_SECRET>
```

#### Stripe (TEST MODE)

```bash
STRIPE_SECRET_KEY=sk_test_YOUR_TEST_KEY
STRIPE_PUBLISHABLE_KEY=pk_test_YOUR_TEST_KEY
REACT_APP_STRIPE_PUBLISHABLE_KEY=pk_test_YOUR_TEST_KEY
```

> **⚠️ IMPORTANT**: Always use `sk_test_` and `pk_test_` keys for staging!

#### SendGrid Email

```bash
EMAIL_HOST=smtp.sendgrid.net
EMAIL_PORT=587
EMAIL_USER=apikey
EMAIL_PASSWORD=SG.YOUR_SENDGRID_API_KEY
EMAIL_FROM=staging@ricostacos.com
```

#### Google Maps

```bash
GOOGLE_MAPS_API_KEY=AIzaSyYOUR_API_KEY
REACT_APP_GOOGLE_MAPS_API_KEY=AIzaSyYOUR_API_KEY
```

#### Domain Configuration (Optional)

If using a custom staging domain:

```bash
WEBSITE_DOMAIN=staging.ricostacos.com
TRAEFIK_WEBSITE_DOMAIN=staging.ricostacos.com
TRAEFIK_CERT_EMAIL=admin@ricostacos.com
FRONTEND_URL=https://staging.ricostacos.com
REACT_APP_API_URL=https://staging.ricostacos.com/api
```

If using IP address only, leave as:

```bash
WEBSITE_DOMAIN=staging.ricostacos.com  # Placeholder
FRONTEND_URL=http://localhost:3000     # Will use IP after deployment
REACT_APP_API_URL=http://localhost:5001
```

### Step 4: Validate Configuration

Run the preflight check script:

```bash
./scripts/staging-preflight.sh
```

This will validate:
- ✓ No `CHANGE_ME` placeholders remain
- ✓ Digital Ocean credentials are set
- ✓ Stripe is in TEST mode
- ✓ Email configuration is valid
- ✓ Secrets meet minimum length requirements
- ✓ Environment variables are consistent

**Fix any errors before proceeding!**

---

## Deployment Process

### Step 1: Install Python Dependencies

```bash
# Create virtual environment (first time only)
python3 -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install dependencies
pip install -r digital_ocean/requirements.txt
```

### Step 2: Run Deployment Script

```bash
# Deploy to staging
./scripts/deploy-staging.sh
```

**What happens during deployment:**

1. ✓ Runs preflight checks
2. ✓ Loads staging environment variables
3. ✓ Creates Digital Ocean droplet
4. ✓ Installs Docker and dependencies
5. ✓ Clones repository
6. ✓ Builds and starts containers
7. ✓ Initializes database
8. ✓ Configures Traefik reverse proxy
9. ✓ Updates DNS records (if domain configured)

**Deployment time**: 5-10 minutes

### Step 3: Save Deployment Details

The script will output:

```
Deployment Details:
  Droplet ID: 123456789
  IP Address: 159.89.123.45
  Environment: staging
```

**Save this information!** You'll need it for SSH access and testing.

---

## Post-Deployment Setup

### DNS Configuration (If Using Custom Domain)

1. **Log in to your domain registrar** (Namecheap, GoDaddy, etc.)

2. **Add DNS A Record**:
   - **Type**: A
   - **Name**: staging (or @)
   - **Value**: `<YOUR_DROPLET_IP>`
   - **TTL**: 300

3. **Wait for DNS propagation** (5-30 minutes)

4. **Verify DNS**:
   ```bash
   dig staging.ricostacos.com
   # or
   nslookup staging.ricostacos.com
   ```

### SSL Certificate

If using a custom domain, Traefik will automatically:
- Request SSL certificate from Let's Encrypt
- Configure HTTPS
- Redirect HTTP to HTTPS

**Note**: SSL certificate generation requires:
- Valid DNS A record pointing to your droplet
- Port 80 and 443 open (Digital Ocean does this by default)
- Valid email in `TRAEFIK_CERT_EMAIL`

### Stripe Webhook (Optional)

1. Go to [Stripe Dashboard → Webhooks](https://dashboard.stripe.com/test/webhooks)
2. Click "Add endpoint"
3. Endpoint URL: `https://staging.ricostacos.com/api/payments/webhook`
4. Select events: `payment_intent.succeeded`, `payment_intent.payment_failed`
5. Copy webhook signing secret
6. Update `.env.staging`:
   ```bash
   STRIPE_WEBHOOK_SECRET=whsec_YOUR_WEBHOOK_SECRET
   ```
7. Redeploy or update environment variable on server

---

## Testing & Verification

### Automated Tests

Run the comprehensive test suite:

```bash
./scripts/test-staging.sh
```

This validates:
- ✓ Network connectivity
- ✓ SSH access
- ✓ Frontend accessibility
- ✓ API endpoints
- ✓ Docker services
- ✓ Database connectivity
- ✓ Environment configuration

### Manual Testing

#### 1. Access Staging Environment

**Via IP**:
```
http://<YOUR_DROPLET_IP>
```

**Via Domain** (if configured):
```
https://staging.ricostacos.com
```

#### 2. Test User Flows

**Browse Menu**:
- Navigate to menu page
- Verify items load with images
- Check categories

**Add to Cart**:
- Add items to cart
- Modify quantities
- Remove items

**Checkout - Pickup**:
1. Select "Pickup"
2. Enter customer details
3. Use Stripe test card:
   - Card: `4242 4242 4242 4242`
   - Expiry: Any future date
   - CVC: Any 3 digits
4. Complete order
5. Verify order confirmation

**Checkout - Delivery**:
1. Select "Delivery"
2. Enter delivery address
3. Verify delivery fee calculation
4. Complete payment
5. Verify order creation

#### 3. Test Admin Functions

**Login as Admin**:
```
Email: albertijan@gmail.com
Password: <YOUR_ADMIN_PASSWORD>
```

**Verify**:
- View orders dashboard
- Check order details
- Test kitchen dashboard
- Verify role management

#### 4. Test Email Notifications

- Complete an order
- Check email for order confirmation
- Verify email formatting and content

#### 5. Check Logs

**SSH into droplet**:
```bash
ssh root@<YOUR_DROPLET_IP>
```

**View Docker containers**:
```bash
docker ps
```

**View backend logs**:
```bash
docker logs -f $(docker ps -q -f name=backend)
```

**View database logs**:
```bash
docker logs -f $(docker ps -q -f name=postgres)
```

---

## Troubleshooting

### Deployment Fails

**Check preflight errors**:
```bash
./scripts/staging-preflight.sh
```

**Common issues**:
- Missing or invalid API tokens
- SSH key not found
- Stripe keys in wrong mode (live vs test)
- Database password mismatch

### Services Not Starting

**SSH into droplet**:
```bash
ssh root@<YOUR_DROPLET_IP>
```

**Check container status**:
```bash
docker ps -a
```

**Restart services**:
```bash
cd /opt/apps/ricostacos-staging  # or wherever deployed
docker-compose down
docker-compose up -d
```

**View cloud-init logs**:
```bash
cat /var/log/cloud-init-output.log
```

### SSL Certificate Issues

**Check Traefik logs**:
```bash
docker logs $(docker ps -q -f name=traefik)
```

**Common issues**:
- DNS not propagated yet (wait 30 minutes)
- Invalid email in `TRAEFIK_CERT_EMAIL`
- Port 80/443 blocked (check firewall)

### Database Connection Errors

**Check database is running**:
```bash
docker ps | grep postgres
```

**Test database connection**:
```bash
docker exec $(docker ps -q -f name=postgres) pg_isready -U ricostacos_staging
```

**Check database logs**:
```bash
docker logs $(docker ps -q -f name=postgres)
```

### API Errors

**Check backend logs**:
```bash
docker logs -f $(docker ps -q -f name=backend)
```

**Common issues**:
- Database connection failed (check credentials)
- Stripe API error (check test keys)
- CORS issues (check `CORS_ORIGIN` in .env)

---

## Rollback & Cleanup

### Destroy Staging Environment

If you need to start over:

```bash
# SSH into droplet
ssh root@<YOUR_DROPLET_IP>

# Stop all containers
docker-compose down -v

# Exit droplet
exit

# Destroy droplet via Digital Ocean dashboard or CLI
doctl compute droplet delete <DROPLET_ID>
```

Or use the teardown script:

```bash
python digital_ocean/teardown.py
```

### Redeploy

After fixing issues:

```bash
# Update .env.staging with fixes
nano .env.staging

# Run preflight checks
./scripts/staging-preflight.sh

# Redeploy
./scripts/deploy-staging.sh
```

---

## Next Steps

After successful staging deployment:

1. **Test thoroughly** - Verify all functionality works
2. **Document issues** - Note any bugs or problems
3. **Fix and redeploy** - Iterate until stable
4. **Prepare production** - Set up production environment
5. **Deploy to production** - Follow similar process with production credentials

---

## Support & Resources

- **Digital Ocean Docs**: https://docs.digitalocean.com
- **Stripe Test Cards**: https://stripe.com/docs/testing
- **SendGrid Docs**: https://docs.sendgrid.com
- **Google Maps API**: https://developers.google.com/maps

---

## Security Reminders

> **⚠️ CRITICAL**
> 
> - Never commit `.env.staging` to version control
> - Use different secrets for staging and production
> - Always use Stripe TEST keys for staging
> - Rotate secrets every 90 days
> - Use strong passwords (32+ characters)
> - Enable 2FA on all third-party accounts

---

**Last Updated**: 2025-12-22
