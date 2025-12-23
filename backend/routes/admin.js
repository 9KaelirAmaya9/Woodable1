const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const adminAuth = require('../middleware/adminAuth');
const orderController = require('../controllers/orderController');

// Public routes
router.post('/login', adminController.login);

// Protected routes - reuse existing order controller functions
router.get('/orders', adminAuth, orderController.getAllOrders);
router.get('/orders/:id', adminAuth, orderController.getOrder);
router.put('/orders/:id/status', adminAuth, orderController.updateOrderStatus);
router.put('/orders/:id', adminAuth, orderController.updateOrder);
router.delete('/orders/:id', adminAuth, orderController.deleteOrder);
router.get('/analytics', adminAuth, orderController.getAnalytics);
router.get('/orders/list/active', adminAuth, orderController.getActiveOrders);

module.exports = router;
