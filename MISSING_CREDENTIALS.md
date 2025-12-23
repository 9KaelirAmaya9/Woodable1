# 🔑 Missing Credentials for Staging Deployment

Good news! I've already copied your existing credentials to `.env.staging`:

✅ **Already Configured:**
- Stripe Secret Key (from your .env)
- Stripe Publishable Key (from your .env)
- JWT Secret (generated)
- Database Password (generated)
- Session Secret (generated)

---

## ❌ Still Needed (4 credentials)

Please provide these credentials below. Once you fill them in, I'll update your `.env.staging` file automatically.

### 1. Digital Ocean API Token

**Where to get it:** https://cloud.digitalocean.com/account/api/tokens

**Steps:**
1. Click "Generate New Token"
2. Name: `Rico's Tacos Staging`
3. Scopes: Read + Write
4. Copy the token (starts with `dop_v1_`)

**Your token:**
```
DO_API_TOKEN=
```

---

### 2. Digital Ocean SSH Key ID

**Where to get it:** https://cloud.digitalocean.com/account/security

**Steps:**
1. If you don't have an SSH key, generate one:
   ```bash
   ssh-keygen -t ed25519 -C "ricostacos-staging"
   cat ~/.ssh/id_ed25519.pub
   ```
2. Add the public key to Digital Ocean
3. Copy the SSH Key ID (number) or fingerprint

**Your SSH Key ID:**
```
DO_SSH_KEY_ID=
```

---

### 3. SendGrid API Key

**Where to get it:** https://app.sendgrid.com/settings/api_keys

**Steps:**
1. Create account (free tier: 100 emails/day)
2. Verify sender email
3. Create API Key
4. Name: `Rico's Tacos Staging`
5. Permissions: Full Access
6. Copy the key (starts with `SG.`)

**Your SendGrid key:**
```
EMAIL_PASSWORD=
```

---

### 4. Google Maps API Key

**Where to get it:** https://console.cloud.google.com/apis/credentials

**Steps:**
1. Create project: `Rico's Tacos`
2. Enable APIs: Maps JavaScript, Geocoding, Distance Matrix
3. Create API Key
4. Copy the key (starts with `AIza`)

**Your Google Maps key:**
```
GOOGLE_MAPS_API_KEY=
```

---

## 📝 How to Provide These

**Option 1: Fill in this file**
Edit this file and add your credentials above, then tell me "credentials ready"

**Option 2: Tell me directly**
Just paste the values and I'll update `.env.staging` for you:
```
DO_API_TOKEN=your_token_here
DO_SSH_KEY_ID=your_key_id_here
EMAIL_PASSWORD=your_sendgrid_key_here
GOOGLE_MAPS_API_KEY=your_google_key_here
```

**Option 3: Manual edit**
Edit `.env.staging` directly and replace the `CHANGE_ME_*` values

---

## ⏱️ Time Estimate

- Digital Ocean: 10 minutes
- SendGrid: 10 minutes  
- Google Maps: 15 minutes

**Total: ~35 minutes**

---

## 🆘 Need Help?

If you need detailed instructions for any service, see:
- [THIRD_PARTY_SETUP.md](file:///Users/jancarlosinc/Desktop/Coding/Axonic/Woodable1/THIRD_PARTY_SETUP.md)

Or ask me for help with specific services!

---

**Once you have these 4 credentials, we'll:**
1. Update `.env.staging`
2. Run preflight checks
3. Deploy to staging! 🚀
