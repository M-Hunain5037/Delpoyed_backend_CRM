const os = require('os');
const pool = require('../config/database');

/**
 * Get system information for the current device
 * @returns {Object} System info object
 */
function getSystemInfo() {
  try {
    // Get network interfaces
    const networkInterfaces = os.networkInterfaces();
    let ipAddress = 'N/A';
    let macAddress = 'N/A';

    // Extract IP and MAC addresses
    for (const [name, addresses] of Object.entries(networkInterfaces)) {
      for (const addr of addresses) {
        if (addr.family === 'IPv4' && !addr.internal) {
          ipAddress = addr.address;
          macAddress = addr.mac;
          break;
        }
      }
      if (ipAddress !== 'N/A') break;
    }

    const systemInfo = {
      hostname: os.hostname(),
      platform: os.platform(),
      arch: os.arch(),
      cpu_cores: os.cpus().length,
      total_memory: Math.round(os.totalmem() / (1024 * 1024 * 1024)) + ' GB',
      free_memory: Math.round(os.freemem() / (1024 * 1024 * 1024)) + ' GB',
      uptime: Math.round(os.uptime() / 3600) + ' hours',
      os_version: os.version ? os.version() : 'N/A',
      ip_address: ipAddress,
      mac_address: macAddress
    };

    return systemInfo;
  } catch (error) {
    console.error('❌ Error getting system info:', error);
    return {
      hostname: 'Unknown',
      platform: 'Unknown',
      ip_address: 'N/A',
      mac_address: 'N/A',
      error: error.message
    };
  }
}

/**
 * Record user login in user_system_info table
 * @param {number} userId - User ID from employee_onboarding
 * @param {string} email - User email
 * @param {string} name - User name
 * @returns {Promise<Object>} Login record object
 */
async function recordUserLogin(userId, email, name) {
  try {
    const systemInfo = getSystemInfo();
    const connection = await pool.getConnection();

    try {
      // Get current login count for this user on this device
      const [existingLogins] = await connection.query(
        `SELECT COUNT(*) as login_count 
         FROM user_system_info 
         WHERE user_id = ? AND hostname = ? AND mac_address = ?`,
        [userId, systemInfo.hostname, systemInfo.mac_address]
      );

      const deviceLoginCount = existingLogins[0]?.login_count || 0;

      // Insert new login record
      const [result] = await connection.query(
        `INSERT INTO user_system_info 
         (user_id, email, name, hostname, platform, ip_address, mac_address, 
          arch, cpu_cores, total_memory, free_memory, os_version, 
          login_status, login_time)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())`,
        [
          userId,
          email,
          name,
          systemInfo.hostname,
          systemInfo.platform,
          systemInfo.ip_address,
          systemInfo.mac_address,
          systemInfo.arch,
          systemInfo.cpu_cores,
          systemInfo.total_memory,
          systemInfo.free_memory,
          systemInfo.os_version,
          'active'
        ]
      );

      console.log(`✅ Login recorded for user ${email} (ID: ${userId})`);
      console.log(`   Hostname: ${systemInfo.hostname}`);
      console.log(`   IP: ${systemInfo.ip_address}`);
      console.log(`   MAC: ${systemInfo.mac_address}`);
      console.log(`   Device login count: ${deviceLoginCount + 1}`);

      return {
        success: true,
        sessionId: result.insertId,
        systemInfo: systemInfo,
        deviceLoginCount: deviceLoginCount + 1
      };

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('❌ Error recording login:', error);
    throw error;
  }
}

/**
 * Record user logout in user_system_info table
 * @param {number} sessionId - Session ID from login record
 * @param {number} userId - User ID
 * @returns {Promise<Object>} Logout record
 */
async function recordUserLogout(sessionId, userId) {
  try {
    const connection = await pool.getConnection();

    try {
      // Update logout time and status
      await connection.query(
        `UPDATE user_system_info 
         SET logout_time = NOW(),
             login_status = 'inactive',
             session_duration = TIMESTAMPDIFF(SECOND, login_time, NOW())
         WHERE id = ? AND user_id = ?`,
        [sessionId, userId]
      );

      console.log(`✅ Logout recorded for session ${sessionId}`);

      return { success: true };

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('❌ Error recording logout:', error);
    throw error;
  }
}

/**
 * Get all active sessions for a user
 * @param {number} userId - User ID
 * @returns {Promise<Array>} List of active sessions
 */
async function getUserActiveSessions(userId) {
  try {
    const connection = await pool.getConnection();

    try {
      const [sessions] = await connection.query(
        `SELECT 
          id,
          hostname,
          platform,
          ip_address,
          mac_address,
          login_time,
          login_status,
          TIMESTAMPDIFF(MINUTE, login_time, NOW()) as session_minutes
         FROM user_system_info
         WHERE user_id = ? AND login_status = 'active'
         ORDER BY login_time DESC`,
        [userId]
      );

      return sessions;

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('❌ Error fetching active sessions:', error);
    throw error;
  }
}

/**
 * Get device count for a user (how many different devices they logged in from)
 * @param {number} userId - User ID
 * @returns {Promise<number>} Device count
 */
async function getUserDeviceCount(userId) {
  try {
    const connection = await pool.getConnection();

    try {
      const [result] = await connection.query(
        `SELECT COUNT(DISTINCT CONCAT(hostname, '_', mac_address)) as device_count
         FROM user_system_info
         WHERE user_id = ?`,
        [userId]
      );

      return result[0]?.device_count || 0;

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('❌ Error getting device count:', error);
    throw error;
  }
}

/**
 * Get user login history
 * @param {number} userId - User ID
 * @param {number} limit - Number of records to return (default: 20)
 * @returns {Promise<Array>} Login history
 */
async function getUserLoginHistory(userId, limit = 20) {
  try {
    const connection = await pool.getConnection();

    try {
      const [history] = await connection.query(
        `SELECT 
          id,
          hostname,
          platform,
          ip_address,
          mac_address,
          login_time,
          logout_time,
          login_status,
          session_duration,
          cpu_cores,
          total_memory,
          free_memory
         FROM user_system_info
         WHERE user_id = ?
         ORDER BY login_time DESC
         LIMIT ?`,
        [userId, limit]
      );

      return history;

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('❌ Error fetching login history:', error);
    throw error;
  }
}

/**
 * Get all devices a user has logged in from
 * @param {number} userId - User ID
 * @returns {Promise<Array>} List of devices
 */
async function getUserDevices(userId) {
  try {
    const connection = await pool.getConnection();

    try {
      const [devices] = await connection.query(
        `SELECT DISTINCT
          hostname,
          platform,
          mac_address,
          ip_address,
          MAX(login_time) as last_login,
          COUNT(*) as login_count
         FROM user_system_info
         WHERE user_id = ?
         GROUP BY hostname, platform, mac_address, ip_address
         ORDER BY MAX(login_time) DESC`,
        [userId]
      );

      return devices;

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('❌ Error fetching user devices:', error);
    throw error;
  }
}

module.exports = {
  getSystemInfo,
  recordUserLogin,
  recordUserLogout,
  getUserActiveSessions,
  getUserDeviceCount,
  getUserLoginHistory,
  getUserDevices
};
