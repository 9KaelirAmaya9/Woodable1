# Rico's Tacos - Third-Party Services Setup Guide

## Overview

This guide walks you through setting up all required third-party services for production deployment.

---

## 1. Digital Ocean Setup

### Create Account (if needed)
1. Go to https://www.digitalocean.com
2. Sign up for an account
3. Verify your email
4. Add payment method (credit card)

### Get API Token
1. Log in to Digital Ocean
2. Go to **API** → https://cloud.digitalocean.com/account/api/tokens
3. Click **"Generate New Token"**
4. Token Settings:
   - **Name**: `Rico's Tacos Production`
   - **Scopes**: Check both **Read** and **Write**
   - **Expiration**: No expiration (or set to 1 year)
5. Click **"Generate Token"**
6. **IMPORTANT**: Copy the token immediately! You won't see it again.
7. Save it temporarily in a secure note

**Add to .env**:
```bash
DO_API_TOKEN=dop_v1_YOUR_TOKEN_HERE
```

### Add SSH Key
1. Generate SSH key (if you don't have one):
   ```bash
   ssh-keygen -t ed25519 -C "ricostacos-deploy"
   # Press Enter to accept default location
   # Press Enter twice for no passphrase (or set one)
   ```

2. Copy your public key:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   # Or if you used a custom name:
   cat ~/.ssh/ricostacos_deploy.pub
   ```

3. Add to Digital Ocean:
   - Go to **Settings** → **Security** → https://cloud.digitalocean.com/account/security
   - Click **"Add SSH Key"**
   - Paste your public key
   - Name: `Rico's Tacos Deploy`
   - Click **"Add SSH Key"**

4. Get the SSH Key ID:
   - Click on your newly added SSH key
   - Look at the URL: `https://cloud.digitalocean.com/account/security?i=XXXXXXXX`
   - The number after `i=` is your SSH Key ID
   - Or use the fingerprint shown on the page

**Add to .env**:
```bash
DO_SSH_KEY_ID=12345678
# Or use fingerprint:
DO_SSH_KEY_ID=aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99
```

---

## 2. Stripe Setup

### Activate Production Mode
1. Log in to https://dashboard.stripe.com
2. Complete business verification:
   - Go to **Settings** → **Business settings**
   - Fill in business information
   - Add bank account for payouts
   - Verify identity (may require documents)

### Get Production API Keys
1. Go to **Developers** → **API keys** → https://dashboard.stripe.com/apikeys
2. Toggle to **"Production"** mode (top right)
3. Copy your keys:
   - **Publishable key**: `pk_live_...`
   - **Secret key**: Click **"Reveal test key"** → `sk_live_...`

**Add to .env**:
```bash
STRIPE_SECRET_KEY=sk_live_YOUR_SECRET_KEY_HERE
STRIPE_PUBLISHABLE_KEY=pk_live_YOUR_PUBLISHABLE_KEY_HERE
REACT_APP_STRIPE_PUBLISHABLE_KEY=pk_live_YOUR_PUBLISHABLE_KEY_HERE
```

### Set Up Webhook (After Deployment)
You'll need to do this after deploying:
1. Go to **Developers** → **Webhooks**
2. Click **"Add endpoint"**
3. Endpoint URL: `https://ricostacos.com/api/payments/webhook`
4. Events to send: Select `payment_intent.succeeded`, `payment_intent.payment_failed`
5. Click **"Add endpoint"**

---

## 3. SendGrid Setup (Email Service)

### Create Account
1. Go to https://sendgrid.com
2. Sign up for free account (100 emails/day free)
3. Verify your email

### Verify Sender Email
1. Go to **Settings** → **Sender Authentication**
2. Click **"Verify a Single Sender"**
3. Fill in:
   - **From Name**: Rico's Tacos
   - **From Email**: noreply@ricostacos.com (or your email)
   - **Reply To**: Same as From Email
   - **Company Address**: Your restaurant address
4. Click **"Create"**
5. Check your email and click verification link

### Create API Key
1. Go to **Settings** → **API Keys** → https://app.sendgrid.com/settings/api_keys
2. Click **"Create API Key"**
3. Settings:
   - **Name**: `Rico's Tacos Production`
   - **Permissions**: **Full Access** (or **Restricted Access** → Mail Send only)
4. Click **"Create & View"**
5. **IMPORTANT**: Copy the API key immediately!

**Add to .env**:
```bash
EMAIL_HOST=smtp.sendgrid.net
EMAIL_PORT=587
EMAIL_USER=apikey
EMAIL_PASSWORD=SG.YOUR_API_KEY_HERE
EMAIL_FROM=noreply@ricostacos.com
```

### Configure DNS (Optional but Recommended)
For better deliverability:
1. Go to **Settings** → **Sender Authentication**
2. Click **"Authenticate Your Domain"**
3. Follow instructions to add DNS records to your domain

---

## 4. Google Maps API Setup

### Create Project
1. Go to https://console.cloud.google.com
2. Click **"Select a project"** → **"New Project"**
3. Project name: `Rico's Tacos`
4. Click **"Create"**

### Enable APIs
1. Go to **APIs & Services** → **Library**
2. Enable these APIs:
   - **Maps JavaScript API**
   - **Geocoding API**
   - **Distance Matrix API**
   - **Places API** (optional, for address autocomplete)

### Create API Key
1. Go to **APIs & Services** → **Credentials**
2. Click **"Create Credentials"** → **"API key"**
3. Copy the API key

### Restrict API Key (IMPORTANT!)
1. Click on your newly created API key
2. **Application restrictions**:
   - Select **"HTTP referrers (web sites)"**
   - Add: `https://ricostacos.com/*`
   - Add: `https://www.ricostacos.com/*`
3. **API restrictions**:
   - Select **"Restrict key"**
   - Select the APIs you enabled above
4. Click **"Save"**

### Enable Billing
1. Go to **Billing** → https://console.cloud.google.com/billing
2. Link a billing account (required for production use)
3. Google Maps offers $200/month free credit

**Add to .env**:
```bash
GOOGLE_MAPS_API_KEY=AIzaSyYOUR_API_KEY_HERE
REACT_APP_GOOGLE_MAPS_API_KEY=AIzaSyYOUR_API_KEY_HERE
```

---

## 5. Domain Name

### Register Domain
1. Choose a registrar:
   - **Namecheap** (recommended): https://www.namecheap.com
   - **GoDaddy**: https://www.godaddy.com
   - **Google Domains**: https://domains.google
2. Search for `ricostacos.com` (or your preferred domain)
3. Purchase domain (typically $10-15/year)

### DNS Configuration (After Deployment)
You'll configure DNS after getting your droplet IP address.

**Add to .env**:
```bash
WEBSITE_DOMAIN=ricostacos.com
TRAEFIK_WEBSITE_DOMAIN=ricostacos.com
TRAEFIK_CERT_EMAIL=admin@ricostacos.com
FRONTEND_URL=https://ricostacos.com
REACT_APP_API_URL=https://ricostacos.com/api
```

---

## 6. Generate Secure Secrets

### JWT Secret
```bash
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```
Copy the output and add to `.env`:
```bash
JWT_SECRET=YOUR_GENERATED_SECRET_HERE
```

### PostgreSQL Password
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```
Copy the output and add to `.env`:
```bash
POSTGRES_PASSWORD=YOUR_GENERATED_PASSWORD_HERE
DB_PASS=YOUR_GENERATED_PASSWORD_HERE  # Same as above
```

---

## Checklist

### Digital Ocean
- [ ] Account created
- [ ] API token generated
- [ ] SSH key added
- [ ] SSH key ID copied

### Stripe
- [ ] Business verification completed
- [ ] Production mode activated
- [ ] Production API keys copied

### SendGrid
- [ ] Account created
- [ ] Sender email verified
- [ ] API key generated

### Google Maps
- [ ] Project created
- [ ] APIs enabled (Maps, Geocoding, Distance Matrix)
- [ ] API key created
- [ ] API key restricted
- [ ] Billing enabled

### Domain
- [ ] Domain registered
- [ ] Ready for DNS configuration

### Secrets
- [ ] JWT secret generated
- [ ] PostgreSQL password generated

---

## Estimated Time

- **Digital Ocean**: 10 minutes
- **Stripe**: 15 minutes (+ verification time)
- **SendGrid**: 10 minutes
- **Google Maps**: 15 minutes
- **Domain**: 5 minutes
- **Secrets**: 2 minutes

**Total**: ~1 hour (+ Stripe verification wait time)

---

## Next Steps

Once all services are set up:
1. Update `.env` with all credentials
2. Test locally to verify everything works
3. Deploy to Digital Ocean
4. Configure DNS
5. Test production deployment
