const jwt = require('jsonwebtoken');
const pool = require('../config/database');

// Async auth middleware that verifies JWT and ensures the session token is active
const authMiddleware = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'No token provided'
      });
    }

    // Verify JWT signature & expiry
    let decoded;
    try {
      decoded = jwt.verify(token, process.env.JWT_SECRET);
    } catch (err) {
      return res.status(401).json({ success: false, message: 'Invalid or expired token' });
    }

    // Ensure session token is still active in the DB (prevents use after logout)
    try {
      const [rows] = await pool.query(
        `SELECT id, session_token, is_active FROM user_system_info WHERE session_token = ? LIMIT 1`,
        [token]
      );

      if (rows.length === 0 || rows[0].is_active !== 1) {
        return res.status(401).json({ success: false, message: 'Session is inactive. Please login again.' });
      }
    } catch (dbErr) {
      console.warn('Auth middleware DB check failed:', dbErr.message);
      // If DB check fails, safer to reject the request
      return res.status(401).json({ success: false, message: 'Authentication failed' });
    }

    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({
      success: false,
      message: 'Invalid or expired token'
    });
  }
};

module.exports = authMiddleware;
