const pool = require('../../config/database');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { recordUserLogin } = require('../../utils/systemInfo');

// Login user (employee or admin)
// Uses email and password_temp from employee_onboarding table
// Also checks admin table for admin users
exports.login = async (req, res) => {
  let connection;
  try {
    const { email, password } = req.body;

    // Validate input
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email and password are required'
      });
    }

    connection = await pool.getConnection();

    // First check if user is an admin
    const [adminUsers] = await connection.query(
      `SELECT 
        id,
        email,
        password,
        full_name,
        status
       FROM admin_users
       WHERE email = ? AND status = 'Active'`,
      [email]
    );

    if (adminUsers.length > 0) {
      const admin = adminUsers[0];

      // Check if password matches
      const isPasswordValid = await bcrypt.compare(password, admin.password);

      if (!isPasswordValid) {
        return res.status(401).json({
          success: false,
          message: 'Invalid email or password'
        });
      }

      // Generate JWT token for admin
      const token = jwt.sign(
        {
          userId: admin.id,
          email: admin.email,
          name: admin.full_name,
          role: 'admin'
        },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRY || '24h' }
      );

      console.log(`✅ Admin login successful for ${admin.email}`);

      res.status(200).json({
        success: true,
        message: 'Login successful',
        data: {
          userId: admin.id,
          name: admin.full_name,
          email: admin.email,
          role: 'admin',
          department: 'Administration',
          position: 'Admin',
          token: token,
          requestPasswordChange: false
        }
      });

      return;
    }

    // Query user_as_employees table for authentication (synced via triggers)
    const [users] = await connection.query(
      `SELECT 
        id,
        employee_id,
        name,
        email,
        password,
        department,
        position,
        designation,
        status,
        request_password_change
       FROM user_as_employees
       WHERE email = ? AND status = 'Active'`,
      [email]
    );

    if (users.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    const user = users[0];

    // Check if password matches from user_as_employees table
    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    // Generate JWT token
    const token = jwt.sign(
      {
        userId: user.id,
        employeeId: user.employee_id,
        email: user.email,
        name: user.name,
        role: user.department,
        designation: user.designation
      },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRY || '24h' }
    );

    // Record login in user_system_info table with device info from client
    const deviceInfo = {
      deviceType: req.body.deviceType || 'PC',
      deviceName: req.body.deviceName || 'Unknown Device',
      browser: req.body.browser || 'Unknown Browser',
      os: req.body.os || 'Unknown OS',
      ipAddress: req.body.ipAddress || req.ip,
      hostname: req.body.hostname || 'Unknown Host',
      macAddress: req.body.macAddress || 'N/A',
      userAgent: req.body.userAgent || req.headers['user-agent'],
      country: req.body.country || 'Unknown',
      city: req.body.city || 'Unknown',
      timezone: req.body.timezone || 'Unknown'
    };

    try {
      // Use onboarding employee id (user.employee_id) to satisfy foreign key reference
      await connection.query(
        `INSERT INTO user_system_info 
         (employee_id, email, name, session_token, device_type, device_name, browser, os, 
          ip_address, hostname, mac_address, user_agent, country, city, timezone, login_time, is_active)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), 1)`,
        [user.employee_id, user.email, user.name, token, deviceInfo.deviceType, deviceInfo.deviceName, 
         deviceInfo.browser, deviceInfo.os, deviceInfo.ipAddress, deviceInfo.hostname, 
         deviceInfo.macAddress, deviceInfo.userAgent, deviceInfo.country, deviceInfo.city, 
         deviceInfo.timezone]
      );

      console.log(`✅ Login recorded for ${user.email} - Device: ${deviceInfo.deviceType}`);

      // Update or create concurrent sessions record
      const [existingSession] = await connection.query(
        `SELECT * FROM user_concurrent_sessions WHERE employee_id = ?`,
        [user.employee_id]
      );

      const deviceType = deviceInfo.deviceType;

      if (existingSession.length > 0) {
        const deviceField = deviceType === 'PC' ? 'pc_count' : 
                           deviceType === 'Mobile' ? 'mobile_count' : 
                           deviceType === 'Tablet' ? 'tablet_count' : 'other_count';
        
        await connection.query(
          `UPDATE user_concurrent_sessions SET 
            total_active_sessions = total_active_sessions + 1,
            ${deviceField} = ${deviceField} + 1
           WHERE employee_id = ?`,
          [user.employee_id]
        );
      } else {
        const deviceCounts = {
          PC: deviceType === 'PC' ? 1 : 0,
          Mobile: deviceType === 'Mobile' ? 1 : 0,
          Tablet: deviceType === 'Tablet' ? 1 : 0,
          Other: !['PC', 'Mobile', 'Tablet'].includes(deviceType) ? 1 : 0
        };

        await connection.query(
          `INSERT INTO user_concurrent_sessions 
           (employee_id, email, total_active_sessions, pc_count, mobile_count, tablet_count, other_count)
           VALUES (?, ?, ?, ?, ?, ?, ?)`,
          [user.employee_id, user.email, 1, deviceCounts.PC, deviceCounts.Mobile, deviceCounts.Tablet, deviceCounts.Other]
        );
      }

      console.log(`📱 Session recorded for ${user.email} on ${deviceType} from IP ${deviceInfo.ipAddress}`);
    } catch (sessionError) {
      console.warn('⚠️ Failed to record session info:', sessionError.message);
      // Try a minimal fallback update or insert to ensure the session is recorded
      try {
        // First check if this token already exists
        const [existingToken] = await connection.query(
          `SELECT id FROM user_system_info WHERE session_token = ?`,
          [token]
        );

        if (existingToken.length > 0) {
          // Update existing token record
          await connection.query(
            `UPDATE user_system_info SET 
              employee_id = ?, email = ?, name = ?, ip_address = ?, 
              is_active = 1, login_time = NOW()
             WHERE session_token = ?`,
            [user.employee_id, user.email, user.name, deviceInfo.ipAddress, token]
          );
          console.log(`✅ Fallback session record updated for ${user.email}`);
        } else {
          // Insert new token record
          await connection.query(
            `INSERT INTO user_system_info (employee_id, email, name, session_token, ip_address, login_time, is_active) VALUES (?, ?, ?, ?, ?, NOW(), 1)`,
            [user.employee_id, user.email, user.name, token, deviceInfo.ipAddress]
          );
          console.log(`✅ Fallback session record created for ${user.email}`);
        }
      } catch (fallbackErr) {
        console.warn('⚠️ Fallback session creation failed:', fallbackErr.message);
      }
      // Don't fail the login if session recording fails
    }

    console.log(`✅ Login successful for ${user.email}`);

    res.status(200).json({
      success: true,
      message: 'Login successful',
      data: {
        userId: user.id,
        employeeId: user.employee_id,
        name: user.name,
        email: user.email,
        department: user.department,
        position: user.position,
        role: user.department,
        token: token,
        requestPasswordChange: user.request_password_change === 1
      }
    });

  } catch (error) {
    console.error('❌ Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Login failed',
      error: error.message
    });
  } finally {
    if (connection) {
      connection.release();
    }
  }
};

// Get user session info
exports.getSession = async (req, res) => {
  try {
    const userId = req.user?.userId; // From JWT middleware

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'Unauthorized'
      });
    }

    const connection = await pool.getConnection();

    try {
      const [users] = await connection.query(
        `SELECT 
          id,
          employee_id,
          name,
          email,
          department,
          position,
          designation,
          request_password_change,
          status
         FROM user_as_employees
         WHERE id = ? AND status = 'Active'`,
        [userId]
      );

      if (users.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }

      res.status(200).json({
        success: true,
        data: users[0]
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('❌ Session error:', error);
    res.status(500).json({
      success: false,
      message: 'Session fetch failed',
      error: error.message
    });
  }
};

// Logout user
exports.logout = async (req, res) => {
  try {
    const userId = req.user?.userId;
    const { token } = req.body; // Token from request body

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'Unauthorized'
      });
    }

    const connection = await pool.getConnection();

    try {
      // Record logout if token is provided
      if (token) {
        const [sessionInfo] = await connection.query(
          `SELECT employee_id, email, device_type FROM user_system_info WHERE session_token = ?`,
          [token]
        );

        if (sessionInfo.length > 0) {
          const session = sessionInfo[0];

          // Update logout time
          await connection.query(
            `UPDATE user_system_info SET logout_time = NOW(), is_active = 0 WHERE session_token = ?`,
            [token]
          );

          // Update concurrent sessions
          const deviceField = session.device_type === 'PC' ? 'pc_count' : 
                             session.device_type === 'Mobile' ? 'mobile_count' : 
                             session.device_type === 'Tablet' ? 'tablet_count' : 'other_count';

          await connection.query(
            `UPDATE user_concurrent_sessions SET 
              total_active_sessions = total_active_sessions - 1,
              ${deviceField} = GREATEST(0, ${deviceField} - 1)
             WHERE employee_id = ?`,
            [session.employee_id]
          );

          console.log(`📱 Logout recorded for employee ${session.employee_id}`);
        }
      }

      console.log(`✅ Logout successful for user ${userId}`);

      res.status(200).json({
        success: true,
        message: 'Logout successful'
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('❌ Logout error:', error);
    res.status(500).json({
      success: false,
      message: 'Logout failed',
      error: error.message
    });
  }
};

// Logout user without forcing or triggering any attendance checkout logic
exports.logoutNoCheckout = async (req, res) => {
  try {
    const userId = req.user?.userId;
    const { token } = req.body; // Token from request body

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'Unauthorized'
      });
    }

    const connection = await pool.getConnection();

    try {
      // Mark session as inactive but do not trigger any attendance checkout behavior
      if (token) {
        const [sessionInfo] = await connection.query(
          `SELECT employee_id, email, device_type FROM user_system_info WHERE session_token = ?`,
          [token]
        );

        if (sessionInfo.length > 0) {
          const session = sessionInfo[0];

          // Update logout time and flag it as a normal logout without checkout
          await connection.query(
            `UPDATE user_system_info SET logout_time = NOW(), is_active = 0 WHERE session_token = ?`,
            [token]
          );

          // Update concurrent sessions counts
          const deviceField = session.device_type === 'PC' ? 'pc_count' : 
                             session.device_type === 'Mobile' ? 'mobile_count' : 
                             session.device_type === 'Tablet' ? 'tablet_count' : 'other_count';

          await connection.query(
            `UPDATE user_concurrent_sessions SET 
              total_active_sessions = GREATEST(0, total_active_sessions - 1),
              ${deviceField} = GREATEST(0, ${deviceField} - 1)
             WHERE employee_id = ?`,
            [session.employee_id]
          );

          console.log(`📱 Logout (no-checkout) recorded for employee ${session.employee_id}`);
        }
      }

      console.log(`✅ Logout (no-checkout) successful for user ${userId}`);

      res.status(200).json({
        success: true,
        message: 'Logout (no-checkout) successful'
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('❌ Logout (no-checkout) error:', error);
    res.status(500).json({
      success: false,
      message: 'Logout (no-checkout) failed',
      error: error.message
    });
  }
};

// Update password
exports.updatePassword = async (req, res) => {
  try {
    const userId = req.user?.userId;
    const { newPassword } = req.body;

    if (!userId || !newPassword) {
      return res.status(400).json({
        success: false,
        message: 'User ID and new password are required'
      });
    }

    const connection = await pool.getConnection();

    try {
      const hashedPassword = await bcrypt.hash(newPassword, 10);

      // Update password in user_as_employees only
      // Note: We don't update employee_onboarding to avoid trigger conflicts
      // The password_temp in onboarding remains as the original temp password
      await connection.query(
        `UPDATE user_as_employees 
         SET password = ?,
             request_password_change = FALSE,
             updated_at = NOW()
         WHERE id = ?`,
        [hashedPassword, userId]
      );

      console.log(`✅ Password updated for user ${userId}`);

      res.status(200).json({
        success: true,
        message: 'Password updated successfully'
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('❌ Password update error:', error);
    res.status(500).json({
      success: false,
      message: 'Password update failed',
      error: error.message
    });
  }
};

// Get all users (for admin)
exports.getAllUsers = async (req, res) => {
  try {
    const connection = await pool.getConnection();

    try {
      const [users] = await connection.query(
        `SELECT 
          id,
          employee_id,
          name,
          email,
          department,
          position,
          status,
          created_at,
          updated_at
         FROM employee_onboarding
         ORDER BY created_at DESC`
      );

      res.status(200).json({
        success: true,
        data: users,
        total: users.length
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('❌ Get users error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch users',
      error: error.message
    });
  }
};

// Get user by email
exports.getUserByEmail = async (req, res) => {
  try {
    const { email } = req.params;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Email is required'
      });
    }

    const connection = await pool.getConnection();

    try {
      const [users] = await connection.query(
        `SELECT 
          id,
          employee_id,
          name,
          email,
          department,
          position,
          status,
          request_password_change
         FROM employee_onboarding
         WHERE email = ?`,
        [email]
      );

      if (users.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }

      res.status(200).json({
        success: true,
        data: users[0]
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('❌ Get user error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch user',
      error: error.message
    });
  }
};

// Deactivate user
exports.deactivateUser = async (req, res) => {
  try {
    const { userId } = req.params;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required'
      });
    }

    const connection = await pool.getConnection();

    try {
      await connection.query(
        `UPDATE employee_onboarding SET status = 'Inactive' WHERE id = ?`,
        [userId]
      );

      console.log(`✅ User ${userId} deactivated`);

      res.status(200).json({
        success: true,
        message: 'User deactivated successfully'
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('❌ Deactivate user error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to deactivate user',
      error: error.message
    });
  }
};

// Get IP address information
exports.getIPInfo = async (req, res) => {
  try {
    // Get IP from request headers (works with proxies)
    let ipAddress = req.ip || 
                   req.connection.remoteAddress ||
                   req.socket.remoteAddress ||
                   req.connection.socket?.remoteAddress;

    // Remove IPv6 prefix if present
    if (ipAddress && ipAddress.includes(':')) {
      ipAddress = ipAddress.split(':').pop();
    }

    res.status(200).json({
      success: true,
      ipAddress: ipAddress || 'Unknown',
      timestamp: new Date()
    });

  } catch (error) {
    console.error('❌ IP info error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch IP information',
      error: error.message
    });
  }
};

