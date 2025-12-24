import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';
import AdminLogin from '../../components/admin/AdminLogin';
import './AdminDashboard.css';

function AdminDashboard() {
    const [token, setToken] = useState(null);
    const [loading, setLoading] = useState(true);
    const [metrics, setMetrics] = useState(null);
    const [metricsLoading, setMetricsLoading] = useState(false);
    const navigate = useNavigate();
    const { logout: clearAuthContext } = useAuth();

    useEffect(() => {
        // Check for existing token
        const savedToken = localStorage.getItem('token');
        if (savedToken) {
            setToken(savedToken);
        }
        setLoading(false);
    }, []);

    useEffect(() => {
        // Fetch metrics when authenticated
        if (token) {
            fetchMetrics();
        }
    }, [token]);

    const fetchMetrics = async () => {
        setMetricsLoading(true);
        try {
            const response = await fetch('/api/admin/analytics', {
                headers: {
                    'Authorization': `Bearer ${token}`
                }
            });

            if (response.ok) {
                const data = await response.json();
                if (data.success) {
                    // Calculate today's metrics
                    const today = new Date().toISOString().split('T')[0];
                    const todayData = data.data.daily_sales.find(d => d.date === today) || { revenue: 0, orders: 0 };

                    // Get pending orders count (we'll fetch this separately)
                    const activeResponse = await fetch('/api/admin/orders/list/active', {
                        headers: {
                            'Authorization': `Bearer ${token}`
                        }
                    });

                    let pendingCount = 0;
                    if (activeResponse.ok) {
                        const activeData = await activeResponse.json();
                        pendingCount = activeData.data?.length || 0;
                    }

                    setMetrics({
                        todayRevenue: parseFloat(todayData.revenue) || 0,
                        todayOrders: parseInt(todayData.orders) || 0,
                        pendingOrders: pendingCount,
                        avgOrderValue: parseFloat(data.data.stats.avg_order_value) || 0
                    });
                }
            }
        } catch (error) {
            console.error('Error fetching metrics:', error);
        } finally {
            setMetricsLoading(false);
        }
    };

    const handleLogin = (newToken) => {
        setToken(newToken);
    };

    const handleLogout = () => {
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        clearAuthContext();
        setToken(null);
        setMetrics(null);
    };

    const navigateTo = (path) => {
        navigate(path);
    };

    if (loading) {
        return (
            <div className="admin-loading">
                <div className="spinner"></div>
                <p>Loading...</p>
            </div>
        );
    }

    if (!token) {
        return <AdminLogin onLogin={handleLogin} />;
    }

    return (
        <div className="admin-dashboard">
            <header className="admin-header">
                <div className="admin-header-content">
                    <h1>🌮 Rico's Tacos - Admin Dashboard</h1>
                    <button onClick={handleLogout} className="logout-button">
                        Logout
                    </button>
                </div>
            </header>

            <main className="admin-main">
                {/* Metrics Overview Section */}
                <section className="metrics-section">
                    <h2 className="section-title">📊 Today's Overview</h2>
                    {metricsLoading ? (
                        <div className="metrics-loading">
                            <div className="spinner-small"></div>
                            <p>Loading metrics...</p>
                        </div>
                    ) : (
                        <div className="metrics-grid">
                            <div className="metric-card revenue-card">
                                <div className="metric-icon">💰</div>
                                <div className="metric-content">
                                    <h3 className="metric-value">${metrics?.todayRevenue.toFixed(2) || '0.00'}</h3>
                                    <p className="metric-label">Today's Revenue</p>
                                </div>
                            </div>

                            <div className="metric-card orders-card">
                                <div className="metric-icon">📦</div>
                                <div className="metric-content">
                                    <h3 className="metric-value">{metrics?.todayOrders || 0}</h3>
                                    <p className="metric-label">Orders Today</p>
                                </div>
                            </div>

                            <div className="metric-card pending-card">
                                <div className="metric-icon">⏳</div>
                                <div className="metric-content">
                                    <h3 className="metric-value">{metrics?.pendingOrders || 0}</h3>
                                    <p className="metric-label">Pending Orders</p>
                                </div>
                            </div>

                            <div className="metric-card average-card">
                                <div className="metric-icon">📊</div>
                                <div className="metric-content">
                                    <h3 className="metric-value">${metrics?.avgOrderValue.toFixed(2) || '0.00'}</h3>
                                    <p className="metric-label">Avg Order Value</p>
                                </div>
                            </div>
                        </div>
                    )}
                </section>

                {/* Navigation Cards Section */}
                <section className="navigation-section">
                    <h2 className="section-title">🎯 Quick Actions</h2>
                    <div className="navigation-grid">
                        <div className="nav-card" onClick={() => navigateTo('/admin/orders')}>
                            <div className="nav-card-icon">📦</div>
                            <h3 className="nav-card-title">Orders Management</h3>
                            <p className="nav-card-description">View and manage all customer orders</p>
                            <div className="nav-card-arrow">→</div>
                        </div>

                        <div className="nav-card" onClick={() => navigateTo('/admin/menu')}>
                            <div className="nav-card-icon">🍴</div>
                            <h3 className="nav-card-title">Menu Manager</h3>
                            <p className="nav-card-description">Edit menu items and pricing</p>
                            <div className="nav-card-arrow">→</div>
                        </div>

                        <div className="nav-card" onClick={() => navigateTo('/admin/analytics')}>
                            <div className="nav-card-icon">📊</div>
                            <h3 className="nav-card-title">Analytics Dashboard</h3>
                            <p className="nav-card-description">View sales reports and insights</p>
                            <div className="nav-card-arrow">→</div>
                        </div>

                        <div className="nav-card" onClick={() => navigateTo('/admin/workorders')}>
                            <div className="nav-card-icon">🔧</div>
                            <h3 className="nav-card-title">Work Orders</h3>
                            <p className="nav-card-description">Manage kitchen work orders</p>
                            <div className="nav-card-arrow">→</div>
                        </div>
                    </div>
                </section>
            </main>
        </div>
    );
}

export default AdminDashboard;
