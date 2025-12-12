import React, { useState, useEffect } from 'react';
import { menuAPI, orderAPI } from '../services/api';
import { useCart } from '../contexts/CartContext';
import { useNavigate } from 'react-router-dom';

const Menu = () => {
    const [categories, setCategories] = useState([]);
    const [items, setItems] = useState([]);
    const [loading, setLoading] = useState(true);
    const [activeCategory, setActiveCategory] = useState('all');
    const [showCheckout, setShowCheckout] = useState(false);
    const navigate = useNavigate();

    const { addToCart, cartItems, removeFromCart, cartTotal, clearCart } = useCart();

    // Checkout Form State
    const [checkoutForm, setCheckoutForm] = useState({ name: '', phone: '', instructions: '' });
    const [checkoutLoading, setCheckoutLoading] = useState(false);

    useEffect(() => {
        const fetchData = async () => {
            try {
                const [catRes, itemRes] = await Promise.all([
                    menuAPI.getCategories(),
                    menuAPI.getItems()
                ]);
                setCategories(catRes.data);
                setItems(itemRes.data);
            } catch (err) {
                console.error('Failed to load menu', err);
            } finally {
                setLoading(false);
            }
        };
        fetchData();
    }, []);

    const filteredItems = activeCategory === 'all'
        ? items
        : items.filter(i => i.category_id === parseInt(activeCategory));

    const handleCheckout = async (e) => {
        e.preventDefault();
        setCheckoutLoading(true);
        try {
            const orderData = {
                items: cartItems.map(i => ({ id: i.id, quantity: i.quantity })),
                customer_name: checkoutForm.name,
                customer_phone: checkoutForm.phone,
                special_instructions: checkoutForm.instructions
            };
            const res = await orderAPI.createOrder(orderData);
            alert(`Order Placed! ID: ${res.data.id}`);
            clearCart();
            setShowCheckout(false);
            setCheckoutForm({ name: '', phone: '', instructions: '' });
        } catch (err) {
            alert('Order failed: ' + (err.response?.data?.message || err.message));
        } finally {
            setCheckoutLoading(false);
        }
    };

    if (loading) return <div style={styles.container}>Loading delicious tacos...</div>;

    return (
        <div style={styles.container}>
            <header style={styles.header}>
                <h1 style={styles.title}>🌮 Los Ricos Tacos</h1>
                <button style={styles.loginBtn} onClick={() => navigate('/')}>Admin Login</button>
            </header>

            <div style={styles.categoryNav}>
                <button
                    style={activeCategory === 'all' ? styles.activeCat : styles.catBtn}
                    onClick={() => setActiveCategory('all')}
                >
                    All
                </button>
                {categories.map(c => (
                    <button
                        key={c.id}
                        style={activeCategory === c.id ? styles.activeCat : styles.catBtn}
                        onClick={() => setActiveCategory(c.id)}
                    >
                        {c.name}
                    </button>
                ))}
            </div>

            <div style={styles.grid}>
                {filteredItems.map(item => (
                    <div key={item.id} style={styles.card}>
                        {item.image_url && <img src={item.image_url} alt={item.name} style={styles.image} />}
                        <div style={styles.cardContent}>
                            <div style={styles.cardHeader}>
                                <h3>{item.name}</h3>
                                <span style={styles.price}>${item.price}</span>
                            </div>
                            <p style={styles.desc}>{item.description}</p>
                            <button onClick={() => addToCart(item)} style={styles.addBtn}>
                                Add to Order 🛒
                            </button>
                        </div>
                    </div>
                ))}
            </div>

            {cartItems.length > 0 && (
                <button style={styles.floatCart} onClick={() => setShowCheckout(true)}>
                    🛒 {cartItems.reduce((a, b) => a + b.quantity, 0)} Items | ${cartTotal.toFixed(2)}
                </button>
            )}

            {showCheckout && (
                <div style={styles.modalOverlay}>
                    <div style={styles.modal}>
                        <h2>Checkout</h2>
                        <div style={styles.cartSummary}>
                            {cartItems.map(i => (
                                <div key={i.id} style={styles.cartItem}>
                                    <span>{i.name} x {i.quantity}</span>
                                    <button onClick={() => removeFromCart(i.id)} style={styles.removeBtn}>x</button>
                                </div>
                            ))}
                            <hr />
                            <div style={{ textAlign: 'right', fontWeight: 'bold' }}>Total: ${cartTotal.toFixed(2)}</div>
                        </div>

                        <form onSubmit={handleCheckout} style={styles.form}>
                            <input
                                placeholder="Your Name"
                                required
                                style={styles.input}
                                value={checkoutForm.name}
                                onChange={e => setCheckoutForm({ ...checkoutForm, name: e.target.value })}
                            />
                            <input
                                placeholder="Phone Number"
                                required
                                style={styles.input}
                                value={checkoutForm.phone}
                                onChange={e => setCheckoutForm({ ...checkoutForm, phone: e.target.value })}
                            />
                            <textarea
                                placeholder="Special Instructions (No onions, etc.)"
                                style={styles.input}
                                value={checkoutForm.instructions}
                                onChange={e => setCheckoutForm({ ...checkoutForm, instructions: e.target.value })}
                            />
                            <div style={styles.modalActions}>
                                <button type="button" onClick={() => setShowCheckout(false)} style={styles.cancelBtn}>Cancel</button>
                                <button type="submit" disabled={checkoutLoading} style={styles.confirmBtn}>
                                    {checkoutLoading ? 'Placing Order...' : 'Place Order'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
};

const styles = {
    container: { maxWidth: '1000px', margin: '0 auto', padding: '20px', fontFamily: 'Inter, sans-serif', paddingBottom: '80px' },
    header: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' },
    title: { fontSize: '2rem', margin: 0 },
    loginBtn: { padding: '8px 16px', background: 'transparent', border: '1px solid #333', borderRadius: '4px', cursor: 'pointer' },
    categoryNav: { display: 'flex', gap: '10px', overflowX: 'auto', paddingBottom: '10px', marginBottom: '20px' },
    catBtn: { padding: '8px 16px', borderRadius: '20px', border: '1px solid #ddd', background: 'white', cursor: 'pointer', whiteSpace: 'nowrap' },
    activeCat: { padding: '8px 16px', borderRadius: '20px', border: 'none', background: '#333', color: 'white', cursor: 'pointer', whiteSpace: 'nowrap' },
    grid: { display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: '20px' },
    card: { border: '1px solid #eee', borderRadius: '8px', overflow: 'hidden', boxShadow: '0 2px 8px rgba(0,0,0,0.05)' },
    image: { width: '100%', height: '150px', objectFit: 'cover', background: '#f5f5f5' },
    cardContent: { padding: '15px' },
    cardHeader: { display: 'flex', justifyContent: 'space-between', marginBottom: '5px' },
    price: { fontWeight: 'bold', color: '#667eea' },
    desc: { color: '#666', fontSize: '0.9rem', marginBottom: '15px' },
    addBtn: { width: '100%', padding: '10px', background: '#667eea', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer' },
    floatCart: { position: 'fixed', bottom: '20px', right: '20px', background: '#333', color: 'white', padding: '15px 25px', borderRadius: '30px', boxShadow: '0 4px 12px rgba(0,0,0,0.2)', fontSize: '1.1rem', cursor: 'pointer', border: 'none', zIndex: 100 },
    modalOverlay: { position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 200 },
    modal: { background: 'white', padding: '30px', borderRadius: '8px', maxWidth: '500px', width: '90%', maxHeight: '90vh', overflowY: 'auto' },
    cartSummary: { marginBottom: '20px', padding: '10px', background: '#f9f9f9', borderRadius: '4px' },
    cartItem: { display: 'flex', justifyContent: 'space-between', marginBottom: '5px' },
    removeBtn: { background: 'none', border: 'none', color: 'red', cursor: 'pointer' },
    form: { display: 'flex', flexDirection: 'column', gap: '10px' },
    input: { padding: '10px', borderRadius: '4px', border: '1px solid #ddd' },
    modalActions: { display: 'flex', gap: '10px', marginTop: '10px' },
    cancelBtn: { flex: 1, padding: '10px', background: '#eee', border: 'none', borderRadius: '4px', cursor: 'pointer' },
    confirmBtn: { flex: 2, padding: '10px', background: '#667eea', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer' }
};

export default Menu;
