import React, { useState, useContext } from 'react';
import { Elements } from '@stripe/react-stripe-js';
import { loadStripe } from '@stripe/stripe-js';
import { CartContext } from '../contexts/CartContext';
import PaymentForm from './PaymentForm';
import './CheckoutModal.css';

const stripePromise = loadStripe(process.env.REACT_APP_STRIPE_PUBLISHABLE_KEY);

const CheckoutModal = ({ isOpen, onClose }) => {
    const { cart, clearCart, getCartTotal } = useContext(CartContext);
    const [step, setStep] = useState(1); // 1: Order Type, 2: Customer Info, 3: Delivery/Payment, 4: Confirmation
    const [orderType, setOrderType] = useState('pickup'); // 'pickup' or 'delivery'
    const [customerInfo, setCustomerInfo] = useState({
        name: '',
        phone: '',
        email: ''
    });
    const [deliveryAddress, setDeliveryAddress] = useState('');
    const [deliveryFee, setDeliveryFee] = useState(0);
    const [deliveryInfo, setDeliveryInfo] = useState(null);
    const [validatingAddress, setValidatingAddress] = useState(false);
    const [addressError, setAddressError] = useState('');
    const [processing, setProcessing] = useState(false);
    const [orderConfirmation, setOrderConfirmation] = useState(null);

    const subtotal = getCartTotal();
    const total = subtotal + (orderType === 'delivery' ? deliveryFee : 0);

    if (!isOpen) return null;

    const handleClose = () => {
        if (!processing) {
            setStep(1);
            setOrderType('pickup');
            setCustomerInfo({ name: '', phone: '', email: '' });
            setDeliveryAddress('');
            setDeliveryFee(0);
            setDeliveryInfo(null);
            setAddressError('');
            setOrderConfirmation(null);
            onClose();
        }
    };

    const validateCustomerInfo = () => {
        if (!customerInfo.name.trim()) {
            alert('Please enter your name');
            return false;
        }
        if (!customerInfo.phone.trim()) {
            alert('Please enter your phone number');
            return false;
        }
        if (!customerInfo.email.trim() || !customerInfo.email.includes('@')) {
            alert('Please enter a valid email');
            return false;
        }
        return true;
    };

    const validateDeliveryAddress = async () => {
        if (orderType !== 'delivery') return true;

        if (!deliveryAddress.trim()) {
            setAddressError('Please enter a delivery address');
            return false;
        }

        setValidatingAddress(true);
        setAddressError('');

        try {
            const response = await fetch(`${process.env.REACT_APP_API_URL}/payments/validate-address`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ address: deliveryAddress })
            });

            const data = await response.json();

            if (!data.success) {
                setAddressError(data.message || 'Invalid delivery address');
                setValidatingAddress(false);
                return false;
            }

            setDeliveryInfo(data);
            setDeliveryFee(parseFloat(data.deliveryFee));
            setValidatingAddress(false);
            return true;
        } catch (error) {
            setAddressError('Failed to validate address. Please try again.');
            setValidatingAddress(false);
            return false;
        }
    };

    const handleNext = async () => {
        if (step === 1) {
            // Check minimum order for delivery
            if (orderType === 'delivery' && subtotal < parseFloat(process.env.REACT_APP_MINIMUM_DELIVERY_ORDER || 15)) {
                alert(`Minimum order for delivery is $${process.env.REACT_APP_MINIMUM_DELIVERY_ORDER || 15}`);
                return;
            }
            setStep(2);
        } else if (step === 2) {
            if (validateCustomerInfo()) {
                if (orderType === 'delivery') {
                    setStep(3);
                } else {
                    setStep(4); // Skip to payment for pickup
                }
            }
        } else if (step === 3) {
            const isValid = await validateDeliveryAddress();
            if (isValid) {
                setStep(4);
            }
        }
    };

    const handlePaymentSuccess = async (paymentIntentId) => {
        setProcessing(true);

        try {
            // Create order
            console.log('Cart items:', cart);
            const orderData = {
                items: cart.map(item => ({
                    id: item.id,
                    quantity: item.quantity,
                    price: item.price
                })),
                customer_name: customerInfo.name,
                customer_phone: customerInfo.phone,
                customer_email: customerInfo.email,
                order_type: orderType,
                delivery_address: orderType === 'delivery' ? deliveryAddress : null,
                delivery_fee: orderType === 'delivery' ? deliveryFee : 0,
                subtotal: subtotal,
                total: total,
                payment_intent_id: paymentIntentId,
                payment_status: 'paid'
            };
            console.log('Order data being sent:', orderData);

            const response = await fetch(`${process.env.REACT_APP_API_URL}/orders`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${localStorage.getItem('token')}`
                },
                body: JSON.stringify(orderData)
            });

            const data = await response.json();

            if (data.success) {
                setOrderConfirmation(data.data); // Changed from data.order to data.data
                clearCart();
                setStep(5); // Confirmation step
            } else {
                alert('Order creation failed: ' + data.message);
            }
        } catch (error) {
            alert('Failed to create order. Please contact support.');
            console.error('Order creation error:', error);
        } finally {
            setProcessing(false);
        }
    };

    return (
        <div className="checkout-modal-overlay" onClick={handleClose}>
            <div className="checkout-modal" onClick={(e) => e.stopPropagation()}>
                <button className="modal-close" onClick={handleClose}>×</button>

                <h2>Checkout</h2>

                {/* Step 1: Order Type */}
                {step === 1 && (
                    <div className="checkout-step">
                        <h3>Select Order Type</h3>
                        <div className="order-type-options">
                            <button
                                className={`order-type-btn ${orderType === 'pickup' ? 'active' : ''}`}
                                onClick={() => setOrderType('pickup')}
                            >
                                🏪 Pickup
                            </button>
                            <button
                                className={`order-type-btn ${orderType === 'delivery' ? 'active' : ''}`}
                                onClick={() => setOrderType('delivery')}
                            >
                                🚗 Delivery
                            </button>
                        </div>
                        <div className="order-summary">
                            <p>Subtotal: ${subtotal.toFixed(2)}</p>
                            {orderType === 'delivery' && (
                                <p className="delivery-note">Minimum order: $15.00</p>
                            )}
                        </div>
                        <button className="next-btn" onClick={handleNext}>
                            Next
                        </button>
                    </div>
                )}

                {/* Step 2: Customer Info */}
                {step === 2 && (
                    <div className="checkout-step">
                        <h3>Customer Information</h3>
                        <div className="form-group">
                            <label>Name *</label>
                            <input
                                type="text"
                                value={customerInfo.name}
                                onChange={(e) => setCustomerInfo({ ...customerInfo, name: e.target.value })}
                                placeholder="John Doe"
                            />
                        </div>
                        <div className="form-group">
                            <label>Phone *</label>
                            <input
                                type="tel"
                                value={customerInfo.phone}
                                onChange={(e) => setCustomerInfo({ ...customerInfo, phone: e.target.value })}
                                placeholder="(555) 123-4567"
                            />
                        </div>
                        <div className="form-group">
                            <label>Email *</label>
                            <input
                                type="email"
                                value={customerInfo.email}
                                onChange={(e) => setCustomerInfo({ ...customerInfo, email: e.target.value })}
                                placeholder="john@example.com"
                            />
                        </div>
                        <div className="button-group">
                            <button className="back-btn" onClick={() => setStep(1)}>Back</button>
                            <button className="next-btn" onClick={handleNext}>Next</button>
                        </div>
                    </div>
                )}

                {/* Step 3: Delivery Address */}
                {step === 3 && orderType === 'delivery' && (
                    <div className="checkout-step">
                        <h3>Delivery Address</h3>
                        <div className="form-group">
                            <label>Address *</label>
                            <input
                                type="text"
                                value={deliveryAddress}
                                onChange={(e) => setDeliveryAddress(e.target.value)}
                                placeholder="123 Main St, Dallas, TX 75201"
                            />
                        </div>
                        {addressError && (
                            <div className="error-message">{addressError}</div>
                        )}
                        {deliveryInfo && (
                            <div className="delivery-info">
                                <p>✓ Address validated</p>
                                <p>Distance: {deliveryInfo.distance} miles</p>
                                <p>Estimated time: {deliveryInfo.duration} minutes</p>
                                <p>Delivery fee: ${deliveryInfo.deliveryFee}</p>
                            </div>
                        )}
                        <div className="button-group">
                            <button className="back-btn" onClick={() => setStep(2)}>Back</button>
                            <button
                                className="next-btn"
                                onClick={handleNext}
                                disabled={validatingAddress}
                            >
                                {validatingAddress ? 'Validating...' : 'Next'}
                            </button>
                        </div>
                    </div>
                )}

                {/* Step 4: Payment */}
                {step === 4 && (
                    <div className="checkout-step">
                        <h3>Payment</h3>
                        <div className="order-summary-final">
                            <p>Subtotal: ${subtotal.toFixed(2)}</p>
                            {orderType === 'delivery' && (
                                <p>Delivery Fee: ${deliveryFee.toFixed(2)}</p>
                            )}
                            <p className="total">Total: ${total.toFixed(2)}</p>
                        </div>
                        <Elements stripe={stripePromise}>
                            <PaymentForm
                                amount={total}
                                onSuccess={handlePaymentSuccess}
                                processing={processing}
                            />
                        </Elements>
                        <button className="back-btn" onClick={() => setStep(orderType === 'delivery' ? 3 : 2)}>
                            Back
                        </button>
                    </div>
                )}

                {/* Step 5: Confirmation */}
                {step === 5 && orderConfirmation && (
                    <div className="checkout-step confirmation">
                        <div className="success-icon">✓</div>
                        <h3>Order Confirmed!</h3>
                        <p>Order #{orderConfirmation.id}</p>
                        <p>Total: ${total.toFixed(2)}</p>
                        <p className="confirmation-message">
                            {orderType === 'pickup'
                                ? 'Your order will be ready for pickup in 15-20 minutes.'
                                : `Your order will be delivered in ${deliveryInfo?.duration || 30} minutes.`
                            }
                        </p>
                        <button className="done-btn" onClick={handleClose}>Done</button>
                    </div>
                )}
            </div>
        </div>
    );
};

export default CheckoutModal;
