# Rico's Tacos - Quick Start Guide

## You Have Everything Ready!

✅ **Templates created**:
- `.env.staging.template` - For staging environment
- `.env.production.template` - For production environment

✅ **Deployment guides**:
- `implementation_plan.md` - Complete deployment guide
- `task.md` - Step-by-step checklist
- `THIRD_PARTY_SETUP.md` - Service setup details

---

## What You Need to Do Now

### Step 1: Get Credentials (~1 hour)

**Digital Ocean**:
1. Go to https://cloud.digitalocean.com/account/api/tokens
2. Generate token → Copy it
3. Go to https://cloud.digitalocean.com/account/security
4. Add your SSH key → Get the ID

**Stripe Test** (for staging):
1. https://dashboard.stripe.com (stay in Test mode)
2. Developers → API keys
3. Copy test keys

**Stripe Production**:
1. Complete business verification
2. Switch to Production mode
3. Copy production keys

**SendGrid**:
1. https://sendgrid.com
2. Create account
3. Get API key

**Domain**:
1. Register ricostacos.com

**Generate Secrets**:
```bash
# Run these 4 times (staging JWT, staging DB, production JWT, production DB)
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

---

### Step 2: Create Environment Files (~15 min)

```bash
# Create staging config
cp .env.staging.template .env.staging
nano .env.staging
# Fill in all CHANGE_ME values

# Create production config
cp .env.production.template .env.production
nano .env.production
# Fill in all CHANGE_ME values
```

---

### Step 3: Deploy Staging (~1.5 hours)

```bash
# Set up Python
python3 -m venv .venv
source .venv/bin/activate
cd digital_ocean && pip install -r requirements.txt && cd ..

# Deploy
cp .env.staging .env
python digital_ocean/deploy.py --dry-run
python digital_ocean/deploy.py
```

Then:
- Configure DNS (staging.ricostacos.com)
- Initialize database
- Test the site

---

### Step 4: Deploy Production (~1.5 hours)

```bash
# Deploy
cp .env.production .env
python digital_ocean/deploy.py --dry-run
python digital_ocean/deploy.py
```

Then:
- Configure DNS (ricostacos.com)
- Initialize database
- Set up Stripe webhook
- Test the site

---

## Total Time: 4-5 hours
## Total Cost: ~$37/month

---

## Need Help?

Check these files:
- `task.md` - Step-by-step checklist
- `implementation_plan.md` - Detailed guide
- `THIRD_PARTY_SETUP.md` - Service setup help

---

## Ready to Start?

**Begin with**: Getting your Digital Ocean API token
https://cloud.digitalocean.com/account/api/tokens
