# 📋 Staging Credentials Checklist

Use this checklist to gather all credentials needed for staging deployment.

## ✅ Credential Gathering Progress

### 1. Digital Ocean (Required)

- [ ] **Account Created**: https://www.digitalocean.com
- [ ] **API Token**: 
  - Go to: https://cloud.digitalocean.com/account/api/tokens
  - Click "Generate New Token"
  - Name: `Rico's Tacos Staging`
  - Scopes: Read + Write
  - Copy token: `dop_v1_...`
  - **Save it here temporarily**: `_______________________`

- [ ] **SSH Key Added**:
  - Generate key: `ssh-keygen -t ed25519 -C "ricostacos-staging"`
  - Copy public key: `cat ~/.ssh/id_ed25519.pub`
  - Add to DO: https://cloud.digitalocean.com/account/security
  - Get SSH Key ID from URL or fingerprint
  - **Save it here temporarily**: `_______________________`

### 2. Stripe (Required - TEST MODE)

- [ ] **Account Created**: https://stripe.com
- [ ] **Test Mode Keys**:
  - Go to: https://dashboard.stripe.com/test/apikeys
  - Ensure you're in **TEST mode** (toggle top-right)
  - Copy **Secret Key**: `sk_test_...`
  - **Save it here**: `_______________________`
  - Copy **Publishable Key**: `pk_test_...`
  - **Save it here**: `_______________________`

> ⚠️ **CRITICAL**: Must use `sk_test_` and `pk_test_` for staging!

### 3. SendGrid (Required)

- [ ] **Account Created**: https://sendgrid.com (Free tier: 100 emails/day)
- [ ] **Sender Verified**:
  - Go to: Settings → Sender Authentication
  - Verify sender email (e.g., `staging@ricostacos.com` or your email)
  - Check email and click verification link

- [ ] **API Key Created**:
  - Go to: https://app.sendgrid.com/settings/api_keys
  - Click "Create API Key"
  - Name: `Rico's Tacos Staging`
  - Permissions: Full Access (or Mail Send only)
  - Copy API Key: `SG.`...
  - **Save it here**: `_______________________`

### 4. Google Maps (Required)

- [ ] **Google Cloud Project Created**: https://console.cloud.google.com
  - Project name: `Rico's Tacos`

- [ ] **APIs Enabled**:
  - [ ] Maps JavaScript API
  - [ ] Geocoding API
  - [ ] Distance Matrix API
  - [ ] Places API (optional)

- [ ] **API Key Created**:
  - Go to: APIs & Services → Credentials
  - Create Credentials → API Key
  - Copy key: `AIza...`
  - **Save it here**: `_______________________`

- [ ] **API Key Restricted** (Important!):
  - Click on your API key
  - Application restrictions: HTTP referrers
  - Add: `https://staging.ricostacos.com/*`
  - API restrictions: Select the APIs enabled above
  - Save

- [ ] **Billing Enabled**: Required for production use ($200/month free credit)

### 5. Domain (Optional)

- [ ] **Domain Registered**: (e.g., `ricostacos.com`)
  - Registrar: Namecheap, GoDaddy, Google Domains, etc.
  - **Domain**: `_______________________`

> 💡 **Note**: You can deploy without a domain and use the droplet IP address initially.

---

## 🔐 Next Steps After Gathering Credentials

Once you have all credentials above, run:

```bash
# 1. Generate secure secrets
./scripts/generate-secrets.sh

# 2. Create staging environment file
cp .env.staging.template .env.staging

# 3. Edit with your credentials
nano .env.staging
# (or use: code .env.staging, vim .env.staging, etc.)
```

Then fill in these values in `.env.staging`:

```bash
# Digital Ocean
DO_API_TOKEN=<YOUR_DO_TOKEN>
DO_SSH_KEY_ID=<YOUR_SSH_KEY_ID>

# Stripe (TEST MODE)
STRIPE_SECRET_KEY=<YOUR_SK_TEST_KEY>
STRIPE_PUBLISHABLE_KEY=<YOUR_PK_TEST_KEY>
REACT_APP_STRIPE_PUBLISHABLE_KEY=<SAME_AS_ABOVE>

# SendGrid
EMAIL_PASSWORD=<YOUR_SENDGRID_API_KEY>

# Google Maps
GOOGLE_MAPS_API_KEY=<YOUR_GOOGLE_MAPS_KEY>
REACT_APP_GOOGLE_MAPS_API_KEY=<SAME_AS_ABOVE>

# Secrets (from generate-secrets.sh)
JWT_SECRET=<GENERATED_SECRET>
POSTGRES_PASSWORD=<GENERATED_PASSWORD>
DB_PASS=<SAME_AS_POSTGRES_PASSWORD>
SESSION_SECRET=<GENERATED_SECRET>
```

---

## 📚 Detailed Setup Instructions

For step-by-step instructions on setting up each service, see:
- **[THIRD_PARTY_SETUP.md](file:///Users/jancarlosinc/Desktop/Coding/Axonic/Woodable1/THIRD_PARTY_SETUP.md)** - Detailed guide with screenshots

---

## ⏱️ Estimated Time

- **Digital Ocean**: 10 minutes
- **Stripe**: 15 minutes (+ verification time)
- **SendGrid**: 10 minutes
- **Google Maps**: 15 minutes
- **Domain** (optional): 5 minutes

**Total**: ~1 hour

---

## 🆘 Need Help?

If you get stuck on any service:
1. Check [THIRD_PARTY_SETUP.md](file:///Users/jancarlosinc/Desktop/Coding/Axonic/Woodable1/THIRD_PARTY_SETUP.md) for detailed instructions
2. Ask me for help with specific services
3. Most services have free tiers for testing

---

**Ready to start?** Begin with Digital Ocean (easiest) and work your way down! 🚀
