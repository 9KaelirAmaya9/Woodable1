# Staging Environment - Quick Start

This is a condensed guide for deploying to staging. For detailed instructions, see [STAGING_DEPLOYMENT.md](file:///Users/jancarlosinc/Desktop/Coding/Axonic/Woodable1/STAGING_DEPLOYMENT.md).

## Prerequisites

- Digital Ocean account with API token
- Stripe account (test mode keys)
- SendGrid account with API key
- Google Maps API key

## Quick Setup (5 Steps)

### 1. Generate Secrets

```bash
./scripts/generate-secrets.sh
```

Copy the output for use in step 2.

### 2. Create Environment File

```bash
# Copy template
cp .env.staging.template .env.staging

# Edit with your credentials
nano .env.staging
```

**Required changes:**
- `DO_API_TOKEN` - Your Digital Ocean API token
- `DO_SSH_KEY_ID` - Your SSH key ID from Digital Ocean
- `STRIPE_SECRET_KEY` - Stripe test key (`sk_test_...`)
- `STRIPE_PUBLISHABLE_KEY` - Stripe test key (`pk_test_...`)
- `EMAIL_PASSWORD` - SendGrid API key
- `GOOGLE_MAPS_API_KEY` - Google Maps API key
- `JWT_SECRET` - From step 1
- `POSTGRES_PASSWORD` - From step 1
- `DB_PASS` - Same as POSTGRES_PASSWORD
- `SESSION_SECRET` - From step 1

### 3. Validate Configuration

```bash
./scripts/staging-preflight.sh
```

Fix any errors before proceeding.

### 4. Deploy

```bash
./scripts/deploy-staging.sh
```

Wait 5-10 minutes for deployment to complete.

### 5. Test

```bash
# Get IP from deployment output, then:
./scripts/test-staging.sh <DROPLET_IP>

# Or if using domain:
./scripts/test-staging.sh
```

## Post-Deployment

### Access Staging

**Via IP**: `http://<DROPLET_IP>`  
**Via Domain**: `https://staging.ricostacos.com` (after DNS setup)

### Test Stripe Checkout

Use test card: `4242 4242 4242 4242`

### View Logs

```bash
ssh root@<DROPLET_IP>
docker logs -f $(docker ps -q -f name=backend)
```

## Troubleshooting

**Deployment fails?**
- Check preflight errors: `./scripts/staging-preflight.sh`
- Verify API tokens are correct
- Ensure SSH key is added to Digital Ocean

**Services not starting?**
```bash
ssh root@<DROPLET_IP>
docker ps -a
docker logs <container_name>
```

**Need to redeploy?**
```bash
# Fix .env.staging, then:
./scripts/deploy-staging.sh
```

## Scripts Reference

| Script | Purpose |
|--------|---------|
| `generate-secrets.sh` | Generate secure random secrets |
| `staging-preflight.sh` | Validate environment configuration |
| `deploy-staging.sh` | Deploy to Digital Ocean |
| `test-staging.sh` | Run automated tests |

## Next Steps

1. ✓ Deploy to staging
2. Test thoroughly
3. Fix any issues
4. Prepare production environment
5. Deploy to production

---

**Need help?** See [STAGING_DEPLOYMENT.md](file:///Users/jancarlosinc/Desktop/Coding/Axonic/Woodable1/STAGING_DEPLOYMENT.md) for detailed documentation.
