const Stripe = require('stripe');
const { Client } = require('@googlemaps/google-maps-services-js');

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
const mapsClient = new Client({});

// Create payment intent
const createPaymentIntent = async (req, res) => {
    try {
        const { amount } = req.body;

        if (!amount || amount <= 0) {
            return res.status(400).json({
                success: false,
                message: 'Invalid amount'
            });
        }

        // Create payment intent with Stripe
        const paymentIntent = await stripe.paymentIntents.create({
            amount: Math.round(amount * 100), // Convert to cents
            currency: 'usd',
            automatic_payment_methods: {
                enabled: true,
            },
        });

        res.json({
            success: true,
            clientSecret: paymentIntent.client_secret,
            paymentIntentId: paymentIntent.id
        });
    } catch (error) {
        console.error('Create payment intent error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to create payment intent',
            error: error.message
        });
    }
};

// Validate delivery address with Google Maps
const validateDeliveryAddress = async (req, res) => {
    try {
        const { address } = req.body;

        if (!address) {
            return res.status(400).json({
                success: false,
                message: 'Address is required'
            });
        }

        // For now, return success without Google Maps (user needs to provide API key)
        // TODO: Implement Google Maps validation when API key is provided
        if (!process.env.GOOGLE_MAPS_API_KEY || process.env.GOOGLE_MAPS_API_KEY === 'YOUR_GOOGLE_MAPS_API_KEY_HERE') {
            return res.json({
                success: true,
                address: address,
                distance: 5, // Mock distance
                duration: 15, // Mock duration in minutes
                deliveryFee: parseFloat(process.env.DELIVERY_BASE_FEE) + (5 * parseFloat(process.env.DELIVERY_PER_MILE_FEE)),
                message: 'Google Maps validation disabled - using mock data'
            });
        }

        // Geocode the delivery address
        const geocodeResponse = await mapsClient.geocode({
            params: {
                address: address,
                key: process.env.GOOGLE_MAPS_API_KEY,
            },
        });

        if (!geocodeResponse.data.results || geocodeResponse.data.results.length === 0) {
            return res.status(400).json({
                success: false,
                message: 'Invalid address - could not geocode'
            });
        }

        const destination = geocodeResponse.data.results[0].formatted_address;

        // Calculate distance and time from restaurant
        const distanceResponse = await mapsClient.distancematrix({
            params: {
                origins: [process.env.RESTAURANT_ADDRESS],
                destinations: [destination],
                key: process.env.GOOGLE_MAPS_API_KEY,
            },
        });

        const element = distanceResponse.data.rows[0].elements[0];

        if (element.status !== 'OK') {
            return res.status(400).json({
                success: false,
                message: 'Could not calculate distance to address'
            });
        }

        const distanceMiles = element.distance.value / 1609.34; // Convert meters to miles
        const durationMinutes = element.duration.value / 60; // Convert seconds to minutes

        // Check if within delivery range
        const maxDistance = parseFloat(process.env.DELIVERY_MAX_DISTANCE_MILES);
        const maxTime = parseFloat(process.env.DELIVERY_MAX_TIME_MINUTES);

        if (distanceMiles > maxDistance) {
            return res.status(400).json({
                success: false,
                message: `Address is too far (${distanceMiles.toFixed(1)} miles). Maximum delivery distance is ${maxDistance} miles.`
            });
        }

        if (durationMinutes > maxTime) {
            return res.status(400).json({
                success: false,
                message: `Delivery time too long (${Math.round(durationMinutes)} minutes). Maximum delivery time is ${maxTime} minutes.`
            });
        }

        // Calculate delivery fee
        const baseFee = parseFloat(process.env.DELIVERY_BASE_FEE);
        const perMileFee = parseFloat(process.env.DELIVERY_PER_MILE_FEE);
        const deliveryFee = baseFee + (distanceMiles * perMileFee);

        res.json({
            success: true,
            address: destination,
            distance: distanceMiles.toFixed(1),
            duration: Math.round(durationMinutes),
            deliveryFee: deliveryFee.toFixed(2)
        });

    } catch (error) {
        console.error('Validate delivery address error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to validate delivery address',
            error: error.message
        });
    }
};

// Calculate delivery fee
const calculateDeliveryFee = async (req, res) => {
    try {
        const { distance } = req.body;

        if (!distance || distance <= 0) {
            return res.status(400).json({
                success: false,
                message: 'Invalid distance'
            });
        }

        const baseFee = parseFloat(process.env.DELIVERY_BASE_FEE);
        const perMileFee = parseFloat(process.env.DELIVERY_PER_MILE_FEE);
        const deliveryFee = baseFee + (distance * perMileFee);

        res.json({
            success: true,
            deliveryFee: deliveryFee.toFixed(2)
        });
    } catch (error) {
        console.error('Calculate delivery fee error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to calculate delivery fee',
            error: error.message
        });
    }
};

module.exports = {
    createPaymentIntent,
    validateDeliveryAddress,
    calculateDeliveryFee
};
