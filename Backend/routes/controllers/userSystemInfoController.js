const pool = require('../../config/database');
const jwt = require('jsonwebtoken');

// Record user login with system information
exports.recordLogin = async (req, res) => {
  try {
    const { 
      employeeId, 
      email, 
      name, 
      sessionToken,
      deviceType = 'PC',
      deviceName,
      browser,
      os,
      ipAddress,
      hostname,
      macAddress,
      userAgent,
      country,
      city,
      timezone
    } = req.body;

    if (!employeeId || !email || !sessionToken || !ipAddress) {
      return res.status(400).json({
        success: false,
        message: 'Required fields missing: employeeId, email, sessionToken, ipAddress'
      });
    }

    const connection = await pool.getConnection();

    try {
      // Start transaction
      await connection.query('START TRANSACTION');

      // Insert into user_system_info
      const [insertResult] = await connection.query(
        `INSERT INTO user_system_info 
         (employee_id, email, name, session_token, device_type, device_name, browser, os, 
          ip_address, hostname, mac_address, user_agent, country, city, timezone, login_time, is_active)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), 1)`,
        [employeeId, email, name, sessionToken, deviceType, deviceName, browser, os, 
         ipAddress, hostname, macAddress, userAgent, country, city, timezone]
      );

      const sessionId = insertResult.insertId;

      // Update concurrent sessions count
      const [existingSession] = await connection.query(
        `SELECT * FROM user_concurrent_sessions WHERE employee_id = ?`,
        [employeeId]
      );

      if (existingSession.length > 0) {
        // Update existing record
        const updateQuery = `UPDATE user_concurrent_sessions SET 
          total_active_sessions = total_active_sessions + 1`;
        const params = [];

        // Increment device count
        if (deviceType === 'PC') {
          params.push('pc_count = pc_count + 1');
        } else if (deviceType === 'Mobile') {
          params.push('mobile_count = mobile_count + 1');
        } else if (deviceType === 'Tablet') {
          params.push('tablet_count = tablet_count + 1');
        } else {
          params.push('other_count = other_count + 1');
        }

        await connection.query(
          `UPDATE user_concurrent_sessions SET 
            total_active_sessions = total_active_sessions + 1,
            ${deviceType === 'PC' ? 'pc_count = pc_count + 1' : 
              deviceType === 'Mobile' ? 'mobile_count = mobile_count + 1' : 
              deviceType === 'Tablet' ? 'tablet_count = tablet_count + 1' : 
              'other_count = other_count + 1'}
           WHERE employee_id = ?`,
          [employeeId]
        );
      } else {
        // Create new record
        const deviceCounts = {
          PC: 0,
          Mobile: 0,
          Tablet: 0,
          Other: 0
        };
        deviceCounts[deviceType] = 1;

        await connection.query(
          `INSERT INTO user_concurrent_sessions 
           (employee_id, email, total_active_sessions, pc_count, mobile_count, tablet_count, other_count)
           VALUES (?, ?, ?, ?, ?, ?, ?)`,
          [employeeId, email, 1, deviceCounts.PC, deviceCounts.Mobile, deviceCounts.Tablet, deviceCounts.Other]
        );
      }

      await connection.query('COMMIT');

      console.log(`✅ Login recorded for ${email} on ${deviceType} from IP ${ipAddress}`);

      res.status(200).json({
        success: true,
        message: 'Login recorded successfully',
        data: {
          sessionId: sessionId,
          sessionToken: sessionToken,
          loginTime: new Date(),
          deviceType: deviceType
        }
      });

    } catch (error) {
      await connection.query('ROLLBACK');
      throw error;
    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('❌ Record login error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to record login',
      error: error.message
    });
  }
};

// Record user logout
exports.recordLogout = async (req, res) => {
  try {
    const { sessionToken } = req.body;

    if (!sessionToken) {
      return res.status(400).json({
        success: false,
        message: 'Session token is required'
      });
    }

    const connection = await pool.getConnection();

    try {
      await connection.query('START TRANSACTION');

      // Get session info
      const [sessions] = await connection.query(
        `SELECT employee_id, email, device_type FROM user_system_info WHERE session_token = ?`,
        [sessionToken]
      );

      if (sessions.length === 0) {
        await connection.query('ROLLBACK');
        return res.status(404).json({
          success: false,
          message: 'Session not found'
        });
      }

      const session = sessions[0];

      // Update logout time
      await connection.query(
        `UPDATE user_system_info SET logout_time = NOW(), is_active = 0 WHERE session_token = ?`,
        [sessionToken]
      );

      // Update concurrent sessions
      await connection.query(
        `UPDATE user_concurrent_sessions SET 
          total_active_sessions = total_active_sessions - 1,
          ${session.device_type === 'PC' ? 'pc_count = pc_count - 1' : 
            session.device_type === 'Mobile' ? 'mobile_count = mobile_count - 1' : 
            session.device_type === 'Tablet' ? 'tablet_count = tablet_count - 1' : 
            'other_count = other_count - 1'}
         WHERE employee_id = ?`,
        [session.employee_id]
      );

      await connection.query('COMMIT');

      console.log(`✅ Logout recorded for ${session.email}`);

      res.status(200).json({
        success: true,
        message: 'Logout recorded successfully'
      });

    } catch (error) {
      await connection.query('ROLLBACK');
      throw error;
    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('❌ Record logout error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to record logout',
      error: error.message
    });
  }
};

// Get active users
exports.getActiveUsers = async (req, res) => {
  try {
    const connection = await pool.getConnection();

    try {
      const [activeUsers] = await connection.query(
        `SELECT 
          id,
          employee_id,
          email,
          name,
          login_time,
          device_type,
          device_name,
          browser,
          os,
          ip_address,
          hostname,
          mac_address,
          country,
          city,
          TIMESTAMPDIFF(MINUTE, login_time, NOW()) as logged_in_minutes,
          last_activity_time
         FROM user_system_info
         WHERE is_active = 1
         ORDER BY login_time DESC`
      );

      res.status(200).json({
        success: true,
        data: activeUsers,
        total: activeUsers.length
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('❌ Get active users error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch active users',
      error: error.message
    });
  }
};

// Get user session summary
exports.getUserSessionSummary = async (req, res) => {
  try {
    const { employeeId } = req.params;

    if (!employeeId) {
      return res.status(400).json({
        success: false,
        message: 'Employee ID is required'
      });
    }

    const connection = await pool.getConnection();

    try {
      // Get all sessions for this employee
      const [sessions] = await connection.query(
        `SELECT 
          id,
          email,
          name,
          login_time,
          logout_time,
          device_type,
          device_name,
          browser,
          os,
          ip_address,
          hostname,
          mac_address,
          country,
          city,
          is_active,
          CASE 
            WHEN is_active = 1 THEN TIMESTAMPDIFF(MINUTE, login_time, NOW())
            ELSE TIMESTAMPDIFF(MINUTE, login_time, logout_time)
          END as session_duration_minutes
         FROM user_system_info
         WHERE employee_id = ?
         ORDER BY login_time DESC
         LIMIT 100`,
        [employeeId]
      );

      // Get summary
      const [summary] = await connection.query(
        `SELECT 
          total_active_sessions,
          pc_count as pc_sessions,
          mobile_count as mobile_sessions,
          tablet_count as tablet_sessions,
          other_count as other_sessions
         FROM user_concurrent_sessions
         WHERE employee_id = ?`,
        [employeeId]
      );

      res.status(200).json({
        success: true,
        data: {
          sessions: sessions,
          summary: summary.length > 0 ? summary[0] : {
            total_active_sessions: 0,
            pc_sessions: 0,
            mobile_sessions: 0,
            tablet_sessions: 0,
            other_sessions: 0
          }
        }
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('❌ Get user session summary error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch user sessions',
      error: error.message
    });
  }
};

// Get concurrent login count for a user
exports.getConcurrentLoginCount = async (req, res) => {
  try {
    const { employeeId } = req.params;

    if (!employeeId) {
      return res.status(400).json({
        success: false,
        message: 'Employee ID is required'
      });
    }

    const connection = await pool.getConnection();

    try {
      const [result] = await connection.query(
        `SELECT 
          employee_id,
          email,
          total_active_sessions,
          pc_count,
          mobile_count,
          tablet_count,
          other_count
         FROM user_concurrent_sessions
         WHERE employee_id = ?`,
        [employeeId]
      );

      if (result.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'No session data found for this employee'
        });
      }

      res.status(200).json({
        success: true,
        data: result[0]
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('❌ Get concurrent login count error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch concurrent login count',
      error: error.message
    });
  }
};

// Update last activity time
exports.updateLastActivity = async (req, res) => {
  try {
    const { sessionToken } = req.body;

    if (!sessionToken) {
      return res.status(400).json({
        success: false,
        message: 'Session token is required'
      });
    }

    const connection = await pool.getConnection();

    try {
      await connection.query(
        `UPDATE user_system_info SET last_activity_time = NOW() WHERE session_token = ?`,
        [sessionToken]
      );

      res.status(200).json({
        success: true,
        message: 'Last activity time updated'
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('❌ Update last activity error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update last activity',
      error: error.message
    });
  }
};

// Get user login history
exports.getUserLoginHistory = async (req, res) => {
  try {
    const { employeeId } = req.params;
    const { days = 30, limit = 50 } = req.query;

    if (!employeeId) {
      return res.status(400).json({
        success: false,
        message: 'Employee ID is required'
      });
    }

    const connection = await pool.getConnection();

    try {
      const [history] = await connection.query(
        `SELECT 
          id,
          email,
          name,
          login_time,
          logout_time,
          device_type,
          device_name,
          browser,
          os,
          ip_address,
          hostname,
          mac_address,
          country,
          city,
          is_active,
          CASE 
            WHEN logout_time IS NOT NULL THEN TIMESTAMPDIFF(MINUTE, login_time, logout_time)
            WHEN is_active = 1 THEN TIMESTAMPDIFF(MINUTE, login_time, NOW())
            ELSE NULL
          END as session_duration_minutes
         FROM user_system_info
         WHERE employee_id = ? AND login_time >= DATE_SUB(NOW(), INTERVAL ? DAY)
         ORDER BY login_time DESC
         LIMIT ?`,
        [employeeId, days, limit]
      );

      res.status(200).json({
        success: true,
        data: history,
        total: history.length,
        filters: {
          days: parseInt(days),
          limit: parseInt(limit)
        }
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('❌ Get user login history error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch login history',
      error: error.message
    });
  }
};
