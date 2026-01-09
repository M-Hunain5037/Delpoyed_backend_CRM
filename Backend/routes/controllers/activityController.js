const pool = require('../../config/database');
const { getPakistanMySQLDateTime, getPakistanDateString } = require('../../utils/timezone');

// Record Employee Activity
exports.recordActivity = async (req, res) => {
  try {
    const {
      employee_id,
      activity_type,
      action,
      description,
      location,
      device,
      duration_minutes
    } = req.body;

    if (!employee_id || !activity_type || !action) {
      return res.status(400).json({
        success: false,
        message: 'Employee ID, activity type, and action are required'
      });
    }

    const connection = await pool.getConnection();

    try {
      const timestamp = getPakistanMySQLDateTime();

      // Insert activity record
      const [result] = await connection.query(
        `INSERT INTO Employee_Activities 
         (employee_id, activity_type, action, description, timestamp, location, device, duration_minutes)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          employee_id,
          activity_type,
          action,
          description || null,
          timestamp,
          location || null,
          device || null,
          duration_minutes || null
        ]
      );

      console.log(`✅ Activity Recorded: ${action} for employee ${employee_id}`);

      res.status(201).json({
        success: true,
        message: 'Activity recorded successfully',
        data: {
          id: result.insertId,
          employee_id,
          activity_type,
          action,
          timestamp
        }
      });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('❌ Record Activity error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to record activity',
      error: error.message
    });
  }
};

// Get All Activities (Admin)
exports.getAllActivities = async (req, res) => {
  try {
    const {
      employee_id,
      activity_type,
      start_date,
      end_date,
      limit = 50,
      page = 1
    } = req.query;

    const connection = await pool.getConnection();

    try {
      let query = `
        SELECT ea.*, eo.name as employee_name, eo.department 
        FROM Employee_Activities ea
        LEFT JOIN employee_onboarding eo ON ea.employee_id = eo.id
        WHERE 1=1
      `;
      const params = [];

      if (employee_id) {
        query += ` AND ea.employee_id = ?`;
        params.push(employee_id);
      }

      if (activity_type) {
        query += ` AND ea.activity_type = ?`;
        params.push(activity_type);
      }

      if (start_date) {
        query += ` AND DATE(ea.timestamp) >= ?`;
        params.push(start_date);
      }

      if (end_date) {
        query += ` AND DATE(ea.timestamp) <= ?`;
        params.push(end_date);
      }

      query += ` ORDER BY ea.timestamp DESC LIMIT ? OFFSET ?`;
      params.push(parseInt(limit), (parseInt(page) - 1) * parseInt(limit));

      const [activities] = await connection.query(query, params);

      res.status(200).json({
        success: true,
        message: 'All activities retrieved',
        data: activities,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: activities.length
        }
      });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('❌ Get All Activities error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch activities',
      error: error.message
    });
  }
};

// Get Activities By Employee
exports.getEmployeeActivities = async (req, res) => {
  try {
    const { employee_id } = req.params;
    const { limit = 50, page = 1 } = req.query;

    const connection = await pool.getConnection();

    try {
      const [activities] = await connection.query(
        `SELECT * FROM Employee_Activities 
         WHERE employee_id = ? 
         ORDER BY timestamp DESC 
         LIMIT ? OFFSET ?`,
        [employee_id, parseInt(limit), (parseInt(page) - 1) * parseInt(limit)]
      );

      res.status(200).json({
        success: true,
        message: 'Employee activities retrieved',
        data: activities,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: activities.length
        }
      });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('❌ Get Employee Activities error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch employee activities',
      error: error.message
    });
  }
};

// Get Today's Activities
exports.getTodayActivities = async (req, res) => {
  try {
    const today = getPakistanDateString();

    const connection = await pool.getConnection();

    try {
      const [activities] = await connection.query(
        `SELECT ea.*, eo.name as employee_name, eo.department 
         FROM Employee_Activities ea
         LEFT JOIN employee_onboarding eo ON ea.employee_id = eo.id
         WHERE DATE(ea.timestamp) = ? 
         ORDER BY ea.timestamp DESC`,
        [today]
      );

      res.status(200).json({
        success: true,
        message: 'Today activities retrieved',
        data: activities,
        total: activities.length
      });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('❌ Get Today Activities error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch today activities',
      error: error.message
    });
  }
};

// Get Activity Statistics
exports.getActivityStats = async (req, res) => {
  try {
    const { start_date, end_date } = req.query;

    const connection = await pool.getConnection();

    try {
      let query = `
        SELECT 
          activity_type,
          COUNT(*) as count,
          COUNT(DISTINCT employee_id) as unique_employees
        FROM Employee_Activities
        WHERE 1=1
      `;
      const params = [];

      if (start_date) {
        query += ` AND DATE(timestamp) >= ?`;
        params.push(start_date);
      }

      if (end_date) {
        query += ` AND DATE(timestamp) <= ?`;
        params.push(end_date);
      }

      query += ` GROUP BY activity_type ORDER BY count DESC`;

      const [stats] = await connection.query(query, params);

      res.status(200).json({
        success: true,
        message: 'Activity statistics retrieved',
        data: stats
      });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('❌ Get Activity Stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch activity statistics',
      error: error.message
    });
  }
};
