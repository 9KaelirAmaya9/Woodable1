# Deployment Scripts

This directory contains scripts for deploying and managing the Rico's Tacos application.

## Staging Environment Scripts

### generate-secrets.sh

Generates cryptographically secure random secrets for JWT, database passwords, and session secrets.

**Usage:**
```bash
./scripts/generate-secrets.sh
```

**Output:**
- JWT_SECRET (128 characters)
- POSTGRES_PASSWORD (64 characters)
- SESSION_SECRET (128 characters)

Copy the output directly into your `.env.staging` file.

---

### staging-preflight.sh

Validates staging environment configuration before deployment.

**Usage:**
```bash
./scripts/staging-preflight.sh
```

**Checks:**
- ✓ No CHANGE_ME placeholders
- ✓ Digital Ocean credentials present
- ✓ Stripe in TEST mode
- ✓ Email configuration valid
- ✓ Secrets meet minimum length
- ✓ Environment variables consistent

**Exit codes:**
- `0` - All checks passed
- `1` - Critical errors found

---

### deploy-staging.sh

Deploys the application to Digital Ocean staging environment.

**Usage:**
```bash
./scripts/deploy-staging.sh [--dry-run]
```

**Process:**
1. Runs preflight checks
2. Loads `.env.staging`
3. Deploys to Digital Ocean
4. Outputs deployment summary

**Requirements:**
- `.env.staging` file configured
- Python 3.10+ installed
- Digital Ocean API token valid

**Deployment time:** 5-10 minutes

---

### test-staging.sh

Runs comprehensive tests on staging environment.

**Usage:**
```bash
# Auto-detect IP from DO_userdata.json
./scripts/test-staging.sh

# Or specify IP manually
./scripts/test-staging.sh 159.89.123.45
```

**Tests:**
- Network connectivity
- SSH access
- HTTP/HTTPS endpoints
- API functionality
- Docker services
- Database connectivity
- Environment configuration

**Exit codes:**
- `0` - All tests passed
- `1` - Some tests failed

---

## Other Scripts

### test-local.sh

Tests the local development environment.

**Usage:**
```bash
./scripts/test-local.sh
```

---

### start.sh / stop.sh / restart.sh

Manage local Docker containers.

**Usage:**
```bash
./scripts/start.sh    # Start all services
./scripts/stop.sh     # Stop all services
./scripts/restart.sh  # Restart all services
```

---

### logs.sh

View logs from Docker containers.

**Usage:**
```bash
./scripts/logs.sh [service]
```

---

### health.sh

Check health status of all services.

**Usage:**
```bash
./scripts/health.sh
```

---

## Workflow

### First-Time Staging Deployment

```bash
# 1. Generate secrets
./scripts/generate-secrets.sh

# 2. Create and edit .env.staging
cp .env.staging.template .env.staging
nano .env.staging

# 3. Validate configuration
./scripts/staging-preflight.sh

# 4. Deploy
./scripts/deploy-staging.sh

# 5. Test
./scripts/test-staging.sh
```

### Subsequent Deployments

```bash
# Update .env.staging if needed
nano .env.staging

# Validate and deploy
./scripts/staging-preflight.sh && ./scripts/deploy-staging.sh
```

### Troubleshooting

```bash
# Check configuration
./scripts/staging-preflight.sh

# View deployment logs
# (shown during deployment)

# Test specific components
./scripts/test-staging.sh <IP>

# SSH into droplet
ssh root@<IP>
docker ps -a
docker logs <container>
```

---

## Environment Variables

All scripts respect the `ENV_FILE` environment variable:

```bash
# Use custom environment file
ENV_FILE=.env.custom ./scripts/deploy-staging.sh
```

Default: `.env.staging`

---

## Documentation

- **Quick Start**: [STAGING_QUICKSTART.md](file:///Users/jancarlosinc/Desktop/Coding/Axonic/Woodable1/STAGING_QUICKSTART.md)
- **Full Guide**: [STAGING_DEPLOYMENT.md](file:///Users/jancarlosinc/Desktop/Coding/Axonic/Woodable1/STAGING_DEPLOYMENT.md)
- **Third-Party Setup**: [THIRD_PARTY_SETUP.md](file:///Users/jancarlosinc/Desktop/Coding/Axonic/Woodable1/THIRD_PARTY_SETUP.md)

---

## Script Permissions

All scripts should be executable:

```bash
chmod +x scripts/*.sh
```

This is done automatically when scripts are created.
