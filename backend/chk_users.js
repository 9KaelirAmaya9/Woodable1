require('dotenv').config();
const { pool } = require('./config/database');

console.log('Checking users...');
pool.query('SELECT id, email, role, password_hash, auth_provider FROM users', (err, res) => {
  if (err) {
    console.error('Error executing query', err);
  } else {
    console.log('Users found:', res.rows);
  }
  pool.end();
});
