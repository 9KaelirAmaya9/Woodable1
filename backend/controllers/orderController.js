const { validationResult } = require('express-validator');
const { query, pool } = require('../config/database');

// @desc    Create new order
// @route   POST /api/orders
// @access  Public
const createOrder = async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array() });
    }

    const { items, customer_name, customer_phone, notes } = req.body;
    // items: [{ id, quantity }]

    if (!items || items.length === 0) {
        return res.status(400).json({ success: false, message: 'No items in order' });
    }

    const client = await pool.connect();

    try {
        await client.query('BEGIN');

        // 1. Calculate Total and Verify Items
        let totalPrice = 0;
        const orderItemsData = [];

        for (const item of items) {
            const { rows } = await client.query('SELECT * FROM menu_items WHERE id = $1', [item.id]);
            if (rows.length === 0) {
                throw new Error(`Item ${item.id} not found`);
            }
            const menuItem = rows[0];
            if (!menuItem.is_available) {
                throw new Error(`Item ${menuItem.name} is not available`);
            }

            const price = parseFloat(menuItem.price);
            const quantity = parseInt(item.quantity) || 1;

            totalPrice += price * quantity;
            orderItemsData.push({
                menu_item_id: menuItem.id,
                quantity,
                price_at_time: price,
                item_name: menuItem.name
            });
        }

        // 2. Create Order with payment and delivery info
        const orderResult = await client.query(
            `INSERT INTO orders (
                total_price, total_amount, subtotal, delivery_fee,
                customer_name, customer_phone, customer_email,
                notes, order_type, delivery_address,
                payment_status, stripe_payment_intent_id,
                status
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, 'pending')
            RETURNING id, created_at`,
            [
                totalPrice, // total_price (for backward compatibility)
                req.body.total || totalPrice, // total_amount
                req.body.subtotal || totalPrice, // subtotal
                req.body.delivery_fee || 0, // delivery_fee
                customer_name,
                customer_phone,
                req.body.customer_email || null, // customer_email
                notes,
                req.body.order_type || 'pickup', // order_type
                req.body.delivery_address || null, // delivery_address
                req.body.payment_status || 'pending', // payment_status
                req.body.payment_intent_id || null // stripe_payment_intent_id
            ]
        );

        const orderId = orderResult.rows[0].id;

        // 3. Create Order Items
        for (const item of orderItemsData) {
            await client.query(
                `INSERT INTO order_items (order_id, menu_item_id, quantity, price_at_time, item_name)
         VALUES ($1, $2, $3, $4, $5)`,
                [orderId, item.menu_item_id, item.quantity, item.price_at_time, item.item_name]
            );
        }

        await client.query('COMMIT');

        res.status(201).json({
            success: true,
            message: 'Order placed successfully',
            data: {
                id: orderId,
                total_amount: totalPrice,
                status: 'NEW'
            }
        });

    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Create order error:', error);
        res.status(400).json({ success: false, message: error.message || 'Error creating order' });
    } finally {
        client.release();
    }
};

// @desc    Get all orders (Admin)
// @route   GET /api/orders
// @access  Private (Admin)
const getAllOrders = async (req, res) => {
    try {
        // Fetch orders with user details
        const result = await query(
            `SELECT o.*, 
              json_agg(json_build_object('name', oi.item_name, 'quantity', oi.quantity, 'price', oi.price_at_time)) as items
       FROM orders o
       LEFT JOIN order_items oi ON o.id = oi.order_id
       GROUP BY o.id
       ORDER BY o.created_at DESC`
        );

        res.json({
            success: true,
            data: result.rows,
        });
    } catch (error) {
        console.error('Get all orders error:', error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
};

// @desc    Update order status
// @route   PUT /api/orders/:id/status
// @access  Private (Admin)
const updateOrderStatus = async (req, res) => {
    const { id } = req.params;
    const { status } = req.body;

    const validStatuses = ['NEW', 'IN_PROGRESS', 'READY', 'COMPLETED', 'CANCELLED'];
    if (!validStatuses.includes(status)) {
        return res.status(400).json({ success: false, message: 'Invalid status' });
    }

    try {
        const result = await query(
            'UPDATE orders SET status = $1 WHERE id = $2 RETURNING *',
            [status, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ success: false, message: 'Order not found' });
        }

        res.json({
            success: true,
            data: result.rows[0],
        });
    } catch (error) {
        console.error('Update status error:', error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
};

// @desc    Get analytics data (Admin)
// @route   GET /api/orders/analytics
// @access  Private (Admin)
const getAnalytics = async (req, res) => {
    try {
        const client = await pool.connect();
        try {
            // 1. Daily Sales (Last 30 days)
            const dailySales = await client.query(`
        SELECT TO_CHAR(created_at, 'YYYY-MM-DD') as date, SUM(total_amount) as revenue, COUNT(*) as orders
        FROM orders
        WHERE status != 'CANCELLED' AND created_at > NOW() - INTERVAL '30 days'
        GROUP BY 1
        ORDER BY 1 ASC
      `);

            // 2. Popular Items
            const popularItems = await client.query(`
        SELECT menu_item_name as item_name, SUM(quantity) as count
        FROM order_items
        GROUP BY 1
        ORDER BY 2 DESC
        LIMIT 5
      `);

            // 3. Overall Stats
            const stats = await client.query(`
        SELECT 
          COUNT(*) as total_orders,
          SUM(CASE WHEN status != 'CANCELLED' THEN total_amount ELSE 0 END) as total_revenue,
          AVG(CASE WHEN status != 'CANCELLED' THEN total_amount ELSE 0 END) as avg_order_value
        FROM orders
      `);

            res.json({
                success: true,
                data: {
                    daily_sales: dailySales.rows,
                    popular_items: popularItems.rows,
                    stats: stats.rows[0]
                }
            });
        } finally {
            client.release();
        }
    } catch (error) {
        console.error('Analytics error:', error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
};

// @desc    Get active orders (Kitchen)
// @route   GET /api/orders/list/active
// @access  Private (Kitchen)
const getActiveOrders = async (req, res) => {
    try {
        const result = await query(
            `SELECT * FROM orders
       WHERE status IN ('NEW', 'IN_PROGRESS')
       ORDER BY
         CASE status
           WHEN 'NEW' THEN 1
           WHEN 'IN_PROGRESS' THEN 2
         END,
         created_at ASC`
        );

        // Fetch items for each order
        const ordersWithItems = await Promise.all(
            result.rows.map(async order => {
                const itemsResult = await query(
                    'SELECT * FROM order_items WHERE order_id = $1',
                    [order.id]
                );
                return {
                    ...order,
                    items: itemsResult.rows
                };
            })
        );

        res.json({
            success: true,
            data: ordersWithItems
        });
    } catch (error) {
        console.error('Error fetching active orders:', error);
        res.status(500).json({
            success: false,
            message: 'Error fetching active orders'
        });
    }
};

/**
 * Helper function to get complete order with items
 */
async function getOrderById(orderId) {
    const orderResult = await query('SELECT * FROM orders WHERE id = $1', [orderId]);

    if (orderResult.rows.length === 0) {
        return null;
    }

    const order = orderResult.rows[0];

    const itemsResult = await query(
        'SELECT * FROM order_items WHERE order_id = $1',
        [orderId]
    );

    return {
        ...order,
        items: itemsResult.rows
    };
}

// @desc    Get single order by ID
// @route   GET /api/orders/:id
// @access  Public (customers can check their order)
const getOrder = async (req, res) => {
    try {
        const { id } = req.params;
        const order = await getOrderById(id);

        if (!order) {
            return res.status(404).json({
                success: false,
                message: 'Order not found'
            });
        }

        res.json({
            success: true,
            data: order
        });
    } catch (error) {
        console.error('Error fetching order:', error);
        res.status(500).json({
            success: false,
            message: 'Error fetching order'
        });
    }
};

// @desc    Update order (Full)
// @route   PUT /api/orders/:id
// @access  Private (Admin)
const updateOrder = async (req, res) => {
    try {
        const { id } = req.params;
        const { customer_name, customer_phone, customer_email, notes, status } = req.body;

        const updates = [];
        const params = [];
        let paramCount = 1;

        if (customer_name !== undefined) {
            params.push(customer_name);
            updates.push(`customer_name = $${paramCount++}`);
        }
        if (customer_phone !== undefined) {
            params.push(customer_phone);
            updates.push(`customer_phone = $${paramCount++}`);
        }
        if (customer_email !== undefined) {
            params.push(customer_email);
            updates.push(`customer_email = $${paramCount++}`);
        }
        if (notes !== undefined) {
            params.push(notes);
            updates.push(`notes = $${paramCount++}`);
        }
        if (status !== undefined) {
            params.push(status);
            updates.push(`status = $${paramCount++}`);
        }

        if (updates.length === 0) {
            return res.status(400).json({
                success: false,
                message: 'No fields to update'
            });
        }

        params.push(id);
        const sql = `UPDATE orders SET ${updates.join(', ')} WHERE id = $${paramCount} RETURNING *`;

        const result = await query(sql, params);

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Order not found'
            });
        }

        const order = await getOrderById(id);

        res.json({
            success: true,
            data: order,
            message: 'Order updated successfully'
        });
    } catch (error) {
        console.error('Error updating order:', error);
        res.status(500).json({
            success: false,
            message: 'Error updating order'
        });
    }
};

// @desc    Delete order
// @route   DELETE /api/orders/:id
// @access  Private (Admin)
const deleteOrder = async (req, res) => {
    try {
        const { id } = req.params;

        const result = await query(
            'DELETE FROM orders WHERE id = $1 RETURNING *',
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Order not found'
            });
        }

        res.json({
            success: true,
            message: 'Order deleted successfully'
        });
    } catch (error) {
        console.error('Error deleting order:', error);
        res.status(500).json({
            success: false,
            message: 'Error deleting order'
        });
    }
};

module.exports = {
    createOrder,
    getAllOrders,
    updateOrderStatus,
    getAnalytics,
    getActiveOrders,
    getOrder,
    updateOrder,
    deleteOrder,
};

