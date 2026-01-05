const jwt = require('jsonwebtoken');
const pool = require('../config/database');

// Generate JWT token
const generateToken = (userId, role) => {
  return jwt.sign(
    { id: userId, role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRY || '24h' }
  );
};

// Format response
const formatResponse = (success, message, data = null, error = null) => {
  return {
    success,
    message,
    ...(data && { data }),
    ...(error && { error })
  };
};

// Validate email
const validateEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

// Validate phone
const validatePhone = (phone) => {
  const phoneRegex = /^[0-9\s\-\+\(\)]+$/;
  return phoneRegex.test(phone) && phone.replace(/\D/g, '').length >= 10;
};

/**
 * Sync employee authentication data from employee_onboarding to user_as_employees
 * This ensures user_as_employees table is up-to-date with authentication credentials
 * @param {number} employeeId - The employee ID (from employee_onboarding.id)
 * @param {string} hashedPassword - The hashed password to sync
 * @param {number} requestPasswordChange - Whether to request password change (1 or 0)
 * @param {object} connection - Optional database connection (uses pool if not provided)
 * @returns {Promise<boolean>} - Returns true if sync successful
 */
const syncEmployeeAuthData = async (employeeId, hashedPassword, requestPasswordChange = 1, connection = null) => {
  const conn = connection || await pool.getConnection();
  
  try {
    // Check if user exists in user_as_employees
    const [existingUser] = await conn.query(
      `SELECT id FROM user_as_employees WHERE employee_id = ?`,
      [employeeId]
    );

    if (existingUser.length > 0) {
      // Update existing user
      await conn.query(
        `UPDATE user_as_employees 
         SET original_password = ?,
             request_password_change = ?
         WHERE employee_id = ?`,
        [hashedPassword, requestPasswordChange, employeeId]
      );
      console.log(`✅ Synced auth data for employee ${employeeId} (updated)`);
    } else {
      // Insert new user
      await conn.query(
        `INSERT INTO user_as_employees 
        (employee_id, original_password, request_password_change, is_active)
        VALUES (?, ?, ?, ?)`,
        [employeeId, hashedPassword, requestPasswordChange, 1]
      );
      console.log(`✅ Synced auth data for employee ${employeeId} (inserted)`);
    }

    return true;
  } catch (error) {
    console.error('❌ Error syncing employee auth data:', error);
    throw error;
  } finally {
    // Only release if we created the connection
    if (!connection && conn) {
      conn.release();
    }
  }
};

module.exports = {
  generateToken,
  formatResponse,
  validateEmail,
  validatePhone,
  syncEmployeeAuthData
};
