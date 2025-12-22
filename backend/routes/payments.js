const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');

// Create payment intent
router.post('/create-intent', paymentController.createPaymentIntent);

// Validate delivery address
router.post('/validate-address', paymentController.validateDeliveryAddress);

// Calculate delivery fee
router.post('/calculate-delivery', paymentController.calculateDeliveryFee);

module.exports = router;
