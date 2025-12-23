#!/bin/bash
# Helper script to copy existing credentials from .env to .env.staging

set -e

echo "Copying existing credentials from .env to .env.staging..."
echo ""

# Copy Stripe keys
STRIPE_SECRET=$(grep "^STRIPE_SECRET_KEY=" .env | cut -d'=' -f2-)
STRIPE_PUB=$(grep "^STRIPE_PUBLISHABLE_KEY=" .env | cut -d'=' -f2-)

if [ -n "$STRIPE_SECRET" ]; then
    sed -i.bak "s|^STRIPE_SECRET_KEY=.*|STRIPE_SECRET_KEY=$STRIPE_SECRET|" .env.staging
    echo "✓ Copied STRIPE_SECRET_KEY"
fi

if [ -n "$STRIPE_PUB" ]; then
    sed -i.bak "s|^STRIPE_PUBLISHABLE_KEY=.*|STRIPE_PUBLISHABLE_KEY=$STRIPE_PUB|" .env.staging
    sed -i.bak "s|^REACT_APP_STRIPE_PUBLISHABLE_KEY=.*|REACT_APP_STRIPE_PUBLISHABLE_KEY=$STRIPE_PUB|" .env.staging
    echo "✓ Copied STRIPE_PUBLISHABLE_KEY"
fi

# Copy generated secrets
JWT_SECRET="d6385b751658c30a61d6233f2f2bcb61731754337a431f8f16b0fb096e98aeec75c996d8bbc8da854f567a62ac9d3cdf9cfa4053e50d71096bafc5ba0d8b0b45"
DB_PASS="8a52bcffb1d96d8e1bd452e722be656888ed706e3dbd9f2c2d38276a2e0ebd7f"
SESSION_SECRET="522291e038ba371e68d8406762c751d69ef502d8b4b677429fbe56673ba9d28140a1c1eebf951d03d04db97768e19b27feb1f4ec3c2e92d4ab8e40dab016199c"

sed -i.bak "s|^JWT_SECRET=.*|JWT_SECRET=$JWT_SECRET|" .env.staging
sed -i.bak "s|^POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=$DB_PASS|" .env.staging
sed -i.bak "s|^DB_PASS=.*|DB_PASS=$DB_PASS|" .env.staging
sed -i.bak "s|^SESSION_SECRET=.*|SESSION_SECRET=$SESSION_SECRET|" .env.staging

echo "✓ Added generated JWT_SECRET"
echo "✓ Added generated POSTGRES_PASSWORD"
echo "✓ Added generated SESSION_SECRET"

# Clean up backup files
rm -f .env.staging.bak

echo ""
echo "✅ Credentials copied successfully!"
echo ""
