const http = require('http');

// Configuration
const BASE_URL = 'http://localhost:5000/api';
const ADMIN_EMAIL = 'albertijan@gmail.com';
const ADMIN_PASSWORD = 'password123';
const TEST_USER_EMAIL = `test_${Date.now()}@example.com`;
const TEST_USER_PASSWORD = 'Password123';

// Helper for making requests
function request(method, path, data = null, token = null) {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: 'localhost',
            port: 5000,
            path: `/api${path}`,
            method: method,
            headers: {
                'Content-Type': 'application/json',
            },
        };

        if (token) {
            options.headers['Authorization'] = `Bearer ${token}`;
        }

        const req = http.request(options, (res) => {
            let body = '';
            res.on('data', (chunk) => body += chunk);
            res.on('end', () => {
                try {
                    const parsed = JSON.parse(body);
                    if (res.statusCode >= 200 && res.statusCode < 300) {
                        resolve({ status: res.statusCode, data: parsed });
                    } else {
                        resolve({ status: res.statusCode, error: parsed }); // Don't reject, just return error status
                    }
                } catch (e) {
                    console.error('Failed to parse response:', body);
                    reject(e);
                }
            });
        });

        req.on('error', (e) => reject(e));
        if (data) req.write(JSON.stringify(data));
        req.end();
    });
}

// Logging
function log(step, msg, success = true) {
    const icon = success ? '✅' : '❌';
    console.log(`${icon} [${step}] ${msg}`);
}

async function runTests() {
    console.log('🚀 Starting Vigorous System Test...');
    let adminToken, userToken, newCategoryId, newItemId, orderId;

    try {
        // 1. Authenticate Admin
        const adminLogin = await request('POST', '/auth/login', { email: ADMIN_EMAIL, password: ADMIN_PASSWORD });
        if (adminLogin.status === 200) {
            adminToken = adminLogin.data.token;
            log('AUTH', `Admin logged in (${ADMIN_EMAIL})`);
        } else {
            throw new Error(`Admin login failed: ${JSON.stringify(adminLogin.error)}`);
        }

        // 2. Fetch existing menu items
        const itemsRes = await request('GET', '/menu/items');
        if (itemsRes.status === 200 && itemsRes.data.data.length > 0) {
            newItemId = itemsRes.data.data[0].id;
            log('MENU', `Using existing menu item (ID: ${newItemId}, Name: ${itemsRes.data.data[0].name})`);
        } else {
            throw new Error('No menu items found in database');
        }

        // Verify categories endpoint
        const catsRes = await request('GET', '/menu/categories');
        if (catsRes.status === 200) {
            log('MENU', `Categories endpoint working (${catsRes.data.data.length} categories found)`);
        } else {
            log('MENU', 'Categories endpoint failed', false);
        }

        // 3. User Registration & Flow
        const regRes = await request('POST', '/auth/register', {
            email: TEST_USER_EMAIL,
            password: TEST_USER_PASSWORD,
            name: 'Testy McTester'
        });

        if (regRes.status === 201 || regRes.status === 200) {
            userToken = regRes.data.token;
            log('AUTH', `New user registered (${TEST_USER_EMAIL})`);
        } else {
            throw new Error(`Registration failed: ${JSON.stringify(regRes.error)}`);
        }

        // 4. Create Order - As User
        const orderPayload = {
            items: [{ id: newItemId, quantity: 2 }],
            customer_name: 'Test User',
            customer_phone: '555-1234',
            notes: 'Extra vigorous sauce'
        };

        const orderRes = await request('POST', '/orders', orderPayload, userToken);
        if (orderRes.status === 201) {
            orderId = orderRes.data.data.id;
            log('ORDER', `Order placed successfully (ID: ${orderId})`);
        } else {
            throw new Error(`Order placement failed: ${JSON.stringify(orderRes.error)}`);
        }

        // 5. Order Management - As Admin
        // List Orders
        const listRes = await request('GET', '/orders', null, adminToken);
        const foundOrder = listRes.data.data.find(o => o.id === orderId);
        if (foundOrder) {
            log('ADMIN', `Admin can see new order ID ${orderId}`);
            if (foundOrder.status === 'NEW') log('ADMIN', 'Order status is NEW');
            else log('ADMIN', `Unexpected status: ${foundOrder.status}`, false);
        } else {
            throw new Error('Admin cannot find the new order');
        }

        // Update Status -> IN_PROGRESS
        const update1 = await request('PUT', `/orders/${orderId}/status`, { status: 'IN_PROGRESS' }, adminToken);
        if (update1.status === 200 && update1.data.data.status === 'IN_PROGRESS') {
            log('ADMIN', 'Order status updated to IN_PROGRESS');
        } else {
            log('ADMIN', `Failed to update status to IN_PROGRESS: ${JSON.stringify(update1.error)}`, false);
        }

        // Update Status -> COMPLETED
        const update2 = await request('PUT', `/orders/${orderId}/status`, { status: 'COMPLETED' }, adminToken);
        if (update2.status === 200 && update2.data.data.status === 'COMPLETED') {
            log('ADMIN', 'Order status updated to COMPLETED');
        }

        // 6. Analytics Verification - As Admin
        const analyticsRes = await request('GET', '/orders/analytics', null, adminToken);
        if (analyticsRes.status === 200) {
            const stats = analyticsRes.data.data.stats;
            log('ANALYTICS', `Data retrieved. Total Revenue: ${stats.total_revenue}, Total Orders: ${stats.total_orders}`);
            if (parseInt(stats.total_orders) > 0) log('ANALYTICS', 'Analytics reflects orders');
        } else {
            log('ANALYTICS', `Failed to retrieve analytics: ${JSON.stringify(analyticsRes.error)}`, false);
        }

        console.log('\n✨ Test Complete!');

    } catch (error) {
        console.error('\n❌ Test Failed with Critical Error:');
        console.error(error);
        process.exit(1);
    }
}

runTests();
