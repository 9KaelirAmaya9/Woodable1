const jwt = require('jsonwebtoken');

// Admin login
const login = async (req, res) => {
    try {
        const { username, password } = req.body;

        if (!username || !password) {
            return res.status(400).json({
                success: false,
                error: 'Username and password required'
            });
        }

        // Simple plaintext comparison for admin login
        if (username === process.env.ADMIN_USERNAME &&
            password === process.env.ADMIN_PASSWORD) {

            const token = jwt.sign(
                {
                    id: 1,
                    username,
                    role: 'admin',
                    loginTime: new Date().toISOString()
                },
                process.env.JWT_SECRET,
                { expiresIn: '24h' }
            );

            return res.json({
                success: true,
                token,
                admin: {
                    username,
                    role: 'admin'
                }
            });
        }

        res.status(401).json({
            success: false,
            error: 'Invalid credentials'
        });
    } catch (error) {
        console.error('Admin login error:', error);
        res.status(500).json({
            success: false,
            error: 'Login failed'
        });
    }
};

module.exports = { login };
