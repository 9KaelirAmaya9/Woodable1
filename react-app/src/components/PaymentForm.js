import React, { useState } from 'react';
import { CardElement, useStripe, useElements } from '@stripe/react-stripe-js';
import './PaymentForm.css';

const PaymentForm = ({ amount, onSuccess, onError, processing: externalProcessing }) => {
    const stripe = useStripe();
    const elements = useElements();
    const [processing, setProcessing] = useState(false);
    const [error, setError] = useState(null);

    const isProcessing = processing || externalProcessing;

    const handleSubmit = async (e) => {
        e.preventDefault();

        if (!stripe || !elements) {
            return;
        }

        setProcessing(true);
        setError(null);

        try {
            // Create payment intent
            const response = await fetch(`${process.env.REACT_APP_API_URL}/payments/create-intent`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ amount })
            });

            const data = await response.json();

            if (!data.success) {
                throw new Error(data.message || 'Failed to create payment intent');
            }

            const { clientSecret, paymentIntentId } = data;

            // Confirm payment
            const { error: stripeError, paymentIntent } = await stripe.confirmCardPayment(clientSecret, {
                payment_method: {
                    card: elements.getElement(CardElement)
                }
            });

            if (stripeError) {
                setError(stripeError.message);
                if (onError) onError(stripeError);
            } else if (paymentIntent.status === 'succeeded') {
                onSuccess(paymentIntent.id);
            }
        } catch (err) {
            setError(err.message);
            if (onError) onError(err);
        } finally {
            setProcessing(false);
        }
    };

    const cardElementOptions = {
        style: {
            base: {
                fontSize: '16px',
                color: '#424770',
                '::placeholder': {
                    color: '#aab7c4',
                },
            },
            invalid: {
                color: '#9e2146',
            },
        },
    };

    return (
        <form onSubmit={handleSubmit} className="payment-form">
            <div className="card-element-container">
                <CardElement options={cardElementOptions} />
            </div>

            {error && (
                <div className="payment-error">
                    {error}
                </div>
            )}

            <button
                type="submit"
                disabled={!stripe || isProcessing}
                className="payment-submit-btn"
            >
                {isProcessing ? 'Processing...' : `Pay $${amount.toFixed(2)}`}
            </button>

            <p className="test-card-info">
                Test card: 4242 4242 4242 4242 | Any future date | Any 3 digits
            </p>
        </form>
    );
};

export default PaymentForm;
