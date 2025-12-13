#!/usr/bin/env node

/**
 * Environment Validation Script
 * Validates that all required environment variables are set before deployment
 */

require('dotenv').config();

const REQUIRED_VARS = {
    // Security
    JWT_SECRET: { pattern: /^[a-f0-9]{128}$/, message: 'Must be 64-byte hex string (128 chars)' },

    // Database
    POSTGRES_PASSWORD: { minLength: 16, message: 'Must be at least 16 characters' },
    DB_PASSWORD: { minLength: 16, message: 'Must be at least 16 characters' },

    // Email
    EMAIL_USER: { pattern: /^.+@.+\..+$/, message: 'Must be valid email' },
    EMAIL_PASSWORD: { minLength: 8, message: 'Must be set' },

    // Stripe
    STRIPE_SECRET_KEY: { pattern: /^sk_live_/, message: 'Must be production key (sk_live_)' },
    STRIPE_PUBLISHABLE_KEY: { pattern: /^pk_live_/, message: 'Must be production key (pk_live_)' },

    // Maps
    REACT_APP_GOOGLE_MAPS_API_KEY: { minLength: 20, message: 'Must be valid API key' },

    // Domain
    WEBSITE_DOMAIN: { required: true },
    TRAEFIK_CERT_EMAIL: { pattern: /^.+@.+\..+$/, message: 'Must be valid email' },
};

const WARNINGS = {
    // Check for default/example values
    JWT_SECRET: /CHANGE_ME/,
    POSTGRES_PASSWORD: /CHANGE_ME|mypassword/,
    EMAIL_PASSWORD: /CHANGE_ME/,
    STRIPE_SECRET_KEY: /CHANGE_ME/,
};

let errors = [];
let warnings = [];

console.log('🔍 Validating environment configuration...\n');

// Check required variables
for (const [varName, rules] of Object.entries(REQUIRED_VARS)) {
    const value = process.env[varName];

    if (!value) {
        errors.push(`❌ ${varName} is not set`);
        continue;
    }

    // Check pattern
    if (rules.pattern && !rules.pattern.test(value)) {
        errors.push(`❌ ${varName}: ${rules.message}`);
    }

    // Check min length
    if (rules.minLength && value.length < rules.minLength) {
        errors.push(`❌ ${varName}: ${rules.message}`);
    }
}

// Check for default values
for (const [varName, pattern] of Object.entries(WARNINGS)) {
    const value = process.env[varName];
    if (value && pattern.test(value)) {
        warnings.push(`⚠️  ${varName} appears to contain default/placeholder value`);
    }
}

// Check password match
if (process.env.POSTGRES_PASSWORD !== process.env.DB_PASSWORD) {
    errors.push('❌ POSTGRES_PASSWORD and DB_PASSWORD must match');
}

// Check NODE_ENV
if (process.env.NODE_ENV !== 'production') {
    warnings.push('⚠️  NODE_ENV is not set to "production"');
}

// Report results
console.log('📋 Validation Results:\n');

if (errors.length === 0 && warnings.length === 0) {
    console.log('✅ All environment variables are properly configured!\n');
    process.exit(0);
}

if (warnings.length > 0) {
    console.log('⚠️  WARNINGS:\n');
    warnings.forEach(w => console.log(`   ${w}`));
    console.log('');
}

if (errors.length > 0) {
    console.log('❌ ERRORS:\n');
    errors.forEach(e => console.log(`   ${e}`));
    console.log('\n💡 Fix these errors before deploying to production!\n');
    process.exit(1);
}

console.log('⚠️  Please review warnings before deploying.\n');
process.exit(0);
