const express = require('express');
const { check } = require('express-validator');
const router = express.Router();
const {
    createOrder,
    getAllOrders,
    updateOrderStatus,
    getAnalytics,
    getActiveOrders,
    getOrder,
    updateOrder,
    deleteOrder,
} = require('../controllers/orderController');
const { protect, optionalProtect, restrictTo } = require('../middleware/auth');

// Public (with optional auth)
router.post(
    '/',
    optionalProtect,
    [
        check('items', 'Items are required').isArray({ min: 1 }),
        check('customer_name', 'Customer name is required').not().isEmpty(),
        check('customer_phone', 'Customer phone is required').not().isEmpty(),
    ],
    createOrder
);

// Kitchen Routes
router.get('/list/active', protect, restrictTo('admin', 'kitchen'), getActiveOrders);

// Admin Routes
router.get('/analytics', protect, restrictTo('admin'), getAnalytics);
router.get('/', protect, restrictTo('admin'), getAllOrders);

// Order Management
router.put(
    '/:id/status',
    protect,
    restrictTo('admin', 'kitchen'),
    [
        check('status', 'Status is required').isIn(['NEW', 'IN_PROGRESS', 'READY', 'COMPLETED', 'CANCELLED']),
    ],
    updateOrderStatus
);

router.put('/:id', protect, restrictTo('admin'), updateOrder);
router.delete('/:id', protect, restrictTo('admin'), deleteOrder);

// Public Order Status Check (Must be last to avoid matching 'analytics' or 'list')
router.get('/:id', getOrder);

module.exports = router;
