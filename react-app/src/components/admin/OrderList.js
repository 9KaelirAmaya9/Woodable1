import React, { useState, useEffect } from 'react';
import './OrderList.css';

function OrderList({ token }) {
    const [orders, setOrders] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');

    useEffect(() => {
        fetchOrders();
        // Auto-refresh every 30 seconds
        const interval = setInterval(fetchOrders, 30000);
        return () => clearInterval(interval);
    }, [token]);

    const fetchOrders = async () => {
        try {
            const apiUrl = process.env.REACT_APP_API_URL || 'http://localhost:5001';
            const response = await fetch(`${apiUrl}/api/admin/orders`, {
                headers: { 'Authorization': `Bearer ${token}` }
            });

            if (!response.ok) {
                throw new Error('Failed to fetch orders');
            }

            const data = await response.json();
            if (data.success) {
                setOrders(data.data || []);
                setError('');
            }
        } catch (err) {
            console.error('Error fetching orders:', err);
            setError('Failed to load orders');
        } finally {
            setLoading(false);
        }
    };

    const updateStatus = async (orderId, newStatus) => {
        try {
            const apiUrl = process.env.REACT_APP_API_URL || 'http://localhost:5001';
            const response = await fetch(
                `${apiUrl}/api/admin/orders/${orderId}/status`,
                {
                    method: 'PUT',
                    headers: {
                        'Authorization': `Bearer ${token}`,
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({ status: newStatus })
                }
            );

            if (response.ok) {
                fetchOrders(); // Refresh list
            } else {
                alert('Failed to update status');
            }
        } catch (err) {
            console.error('Error updating status:', err);
            alert('Failed to update status');
        }
    };

    const getStatusColor = (status) => {
        const colors = {
            pending: '#fbbf24',
            NEW: '#fbbf24',
            IN_PROGRESS: '#3b82f6',
            preparing: '#3b82f6',
            READY: '#10b981',
            ready: '#10b981',
            COMPLETED: '#6b7280',
            completed: '#6b7280',
            CANCELLED: '#ef4444',
            cancelled: '#ef4444'
        };
        return colors[status] || '#6b7280';
    };

    const formatDate = (dateString) => {
        const date = new Date(dateString);
        return date.toLocaleString('en-US', {
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    };

    const getItemCount = (order) => {
        if (order.items && Array.isArray(order.items)) {
            return order.items.reduce((sum, item) => sum + (item.quantity || 0), 0);
        }
        return 0;
    };

    if (loading) {
        return (
            <div className="order-list-loading">
                <div className="spinner"></div>
                <p>Loading orders...</p>
            </div>
        );
    }

    if (error) {
        return (
            <div className="order-list-error">
                <p>⚠️ {error}</p>
                <button onClick={fetchOrders} className="retry-button">
                    Retry
                </button>
            </div>
        );
    }

    // Calculate statistics
    const stats = {
        total: orders.length,
        new: orders.filter(o => o.status === 'NEW' || o.status === 'pending').length,
        inProgress: orders.filter(o => o.status === 'IN_PROGRESS' || o.status === 'preparing').length,
        ready: orders.filter(o => o.status === 'READY' || o.status === 'ready').length
    };

    return (
        <div className="order-list-container">
            {/* Statistics Cards */}
            <div className="order-stats">
                <div className="stat-card">
                    <div className="stat-icon">📦</div>
                    <div className="stat-content">
                        <h3>Total Orders</h3>
                        <p className="stat-number">{stats.total}</p>
                    </div>
                </div>
                <div className="stat-card stat-new">
                    <div className="stat-icon">🆕</div>
                    <div className="stat-content">
                        <h3>New Orders</h3>
                        <p className="stat-number">{stats.new}</p>
                    </div>
                </div>
                <div className="stat-card stat-progress">
                    <div className="stat-icon">👨‍🍳</div>
                    <div className="stat-content">
                        <h3>In Progress</h3>
                        <p className="stat-number">{stats.inProgress}</p>
                    </div>
                </div>
                <div className="stat-card stat-ready">
                    <div className="stat-icon">✅</div>
                    <div className="stat-content">
                        <h3>Ready</h3>
                        <p className="stat-number">{stats.ready}</p>
                    </div>
                </div>
            </div>

            {/* Orders Table */}
            <div className="orders-table-container">
                <div className="table-header">
                    <h2>Recent Orders</h2>
                    <button onClick={fetchOrders} className="refresh-button">
                        🔄 Refresh
                    </button>
                </div>

                {orders.length === 0 ? (
                    <div className="no-orders">
                        <div className="no-orders-icon">🌮</div>
                        <p>No orders yet</p>
                        <small>Orders will appear here when customers place them</small>
                    </div>
                ) : (
                    <table className="orders-table">
                        <thead>
                            <tr>
                                <th>Order #</th>
                                <th>Customer</th>
                                <th>Type</th>
                                <th>Items</th>
                                <th>Total</th>
                                <th>Status</th>
                                <th>Time</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {orders.map(order => (
                                <tr key={order.id} className="order-row">
                                    <td className="order-id">#{order.id}</td>
                                    <td className="customer-info">
                                        <div className="customer-name">{order.customer_name}</div>
                                        {order.customer_email && (
                                            <div className="customer-email">{order.customer_email}</div>
                                        )}
                                        {order.customer_phone && (
                                            <div className="customer-phone">{order.customer_phone}</div>
                                        )}
                                    </td>
                                    <td className="order-type">
                                        {order.order_type === 'delivery' ? '🚗 Delivery' : '🏪 Pickup'}
                                    </td>
                                    <td className="item-count">{getItemCount(order)} items</td>
                                    <td className="order-total">
                                        ${parseFloat(order.total_amount || order.total_price || 0).toFixed(2)}
                                    </td>
                                    <td className="order-status">
                                        <span
                                            className="status-badge"
                                            style={{ backgroundColor: getStatusColor(order.status) }}
                                        >
                                            {order.status}
                                        </span>
                                    </td>
                                    <td className="order-time">{formatDate(order.created_at)}</td>
                                    <td className="order-actions">
                                        <select
                                            value={order.status}
                                            onChange={(e) => updateStatus(order.id, e.target.value)}
                                            className="status-select"
                                        >
                                            <option value="NEW">New</option>
                                            <option value="IN_PROGRESS">In Progress</option>
                                            <option value="READY">Ready</option>
                                            <option value="COMPLETED">Completed</option>
                                            <option value="CANCELLED">Cancelled</option>
                                        </select>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                )}
            </div>
        </div>
    );
}

export default OrderList;
