const pool = require('../../config/database');

// Get all rules
exports.getAllRules = async (req, res) => {
  try {
    const connection = await pool.getConnection();
    
    try {
      const [rules] = await connection.query(
        `SELECT * FROM Company_Rules WHERE is_active = TRUE ORDER BY priority ASC, created_at DESC`
      );

      res.status(200).json({
        success: true,
        message: 'Rules fetched successfully',
        data: rules,
        count: rules.length
      });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('❌ Error fetching rules:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch rules',
      error: error.message
    });
  }
};

// Get break rules only
exports.getBreakRules = async (req, res) => {
  try {
    const connection = await pool.getConnection();
    
    try {
      const [breakRules] = await connection.query(
        `SELECT id, rule_name, break_type, break_duration_minutes, description, priority 
         FROM Company_Rules 
         WHERE rule_type = 'BREAK_TIME' AND is_active = TRUE 
         ORDER BY priority ASC, created_at DESC`
      );

      // Format the response to match frontend expectations
      const formattedRules = breakRules.map(rule => ({
        id: rule.id,
        name: rule.break_type || rule.rule_name,
        type: (rule.break_type || rule.rule_name).toLowerCase().replace(' break', '').replace('break', ''),
        limit: rule.break_duration_minutes,
        description: rule.description
      }));

      res.status(200).json({
        success: true,
        message: 'Break rules fetched successfully',
        data: formattedRules,
        count: formattedRules.length
      });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('❌ Error fetching break rules:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch break rules',
      error: error.message
    });
  }
};

// Get rule by ID
exports.getRuleById = async (req, res) => {
  try {
    const { id } = req.params;
    const connection = await pool.getConnection();
    
    try {
      const [rule] = await connection.query(
        `SELECT * FROM Company_Rules WHERE id = ?`,
        [id]
      );

      if (rule.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Rule not found'
        });
      }

      res.status(200).json({
        success: true,
        message: 'Rule fetched successfully',
        data: rule[0]
      });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('❌ Error fetching rule:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch rule',
      error: error.message
    });
  }
};

// Add new rule
exports.addRule = async (req, res) => {
  try {
    const {
      rule_name,
      rule_type,
      description,
      start_time,
      end_time,
      total_hours,
      break_duration_minutes,
      break_type,
      overtime_starts_after_minutes,
      overtime_multiplier,
      is_active = true,
      priority = 0
    } = req.body;

    // Validation
    if (!rule_name || !rule_type) {
      return res.status(400).json({
        success: false,
        message: 'Rule name and rule type are required'
      });
    }

    // Validate rule_type
    const validTypes = ['WORKING_HOURS', 'BREAK_TIME', 'OVERTIME', 'LEAVE'];
    if (!validTypes.includes(rule_type)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid rule type. Must be one of: WORKING_HOURS, BREAK_TIME, OVERTIME, LEAVE'
      });
    }

    // Validate based on rule type
    if (rule_type === 'WORKING_HOURS' && (!start_time || !end_time || !total_hours)) {
      return res.status(400).json({
        success: false,
        message: 'Working hours rule requires: start_time, end_time, total_hours'
      });
    }

    if (rule_type === 'BREAK_TIME' && (!break_duration_minutes || !break_type)) {
      return res.status(400).json({
        success: false,
        message: 'Break time rule requires: break_duration_minutes, break_type'
      });
    }

    if (rule_type === 'OVERTIME' && (!overtime_starts_after_minutes || !overtime_multiplier)) {
      return res.status(400).json({
        success: false,
        message: 'Overtime rule requires: overtime_starts_after_minutes, overtime_multiplier'
      });
    }

    const connection = await pool.getConnection();
    
    try {
      // Check if rule name already exists
      const [existingRule] = await connection.query(
        `SELECT id FROM Company_Rules WHERE rule_name = ?`,
        [rule_name]
      );

      if (existingRule.length > 0) {
        return res.status(409).json({
          success: false,
          message: 'Rule with this name already exists'
        });
      }

      // Insert new rule
      const [result] = await connection.query(
        `INSERT INTO Company_Rules 
         (rule_name, rule_type, description, start_time, end_time, total_hours, 
          break_duration_minutes, break_type, overtime_starts_after_minutes, 
          overtime_multiplier, is_active, priority)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          rule_name,
          rule_type,
          description || null,
          start_time || null,
          end_time || null,
          total_hours || null,
          break_duration_minutes || null,
          break_type || null,
          overtime_starts_after_minutes || null,
          overtime_multiplier || null,
          is_active,
          priority
        ]
      );

      console.log(`✅ New rule added: ${rule_name}`);

      res.status(201).json({
        success: true,
        message: 'Rule added successfully',
        data: {
          id: result.insertId,
          rule_name,
          rule_type,
          description,
          is_active,
          priority
        }
      });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('❌ Error adding rule:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to add rule',
      error: error.message
    });
  }
};

// Update rule
exports.updateRule = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      rule_name,
      description,
      start_time,
      end_time,
      total_hours,
      break_duration_minutes,
      break_type,
      overtime_starts_after_minutes,
      overtime_multiplier,
      is_active,
      priority
    } = req.body;

    const connection = await pool.getConnection();
    
    try {
      // Check if rule exists
      const [existingRule] = await connection.query(
        `SELECT id FROM Company_Rules WHERE id = ?`,
        [id]
      );

      if (existingRule.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Rule not found'
        });
      }

      // Check if new rule name already exists (if being changed)
      if (rule_name) {
        const [duplicateRule] = await connection.query(
          `SELECT id FROM Company_Rules WHERE rule_name = ? AND id != ?`,
          [rule_name, id]
        );

        if (duplicateRule.length > 0) {
          return res.status(409).json({
            success: false,
            message: 'Rule with this name already exists'
          });
        }
      }

      // Build update query dynamically
      const updates = [];
      const values = [];

      if (rule_name !== undefined) {
        updates.push('rule_name = ?');
        values.push(rule_name);
      }
      if (description !== undefined) {
        updates.push('description = ?');
        values.push(description);
      }
      if (start_time !== undefined) {
        updates.push('start_time = ?');
        values.push(start_time);
      }
      if (end_time !== undefined) {
        updates.push('end_time = ?');
        values.push(end_time);
      }
      if (total_hours !== undefined) {
        updates.push('total_hours = ?');
        values.push(total_hours);
      }
      if (break_duration_minutes !== undefined) {
        updates.push('break_duration_minutes = ?');
        values.push(break_duration_minutes);
      }
      if (break_type !== undefined) {
        updates.push('break_type = ?');
        values.push(break_type);
      }
      if (overtime_starts_after_minutes !== undefined) {
        updates.push('overtime_starts_after_minutes = ?');
        values.push(overtime_starts_after_minutes);
      }
      if (overtime_multiplier !== undefined) {
        updates.push('overtime_multiplier = ?');
        values.push(overtime_multiplier);
      }
      if (is_active !== undefined) {
        updates.push('is_active = ?');
        values.push(is_active);
      }
      if (priority !== undefined) {
        updates.push('priority = ?');
        values.push(priority);
      }

      if (updates.length === 0) {
        return res.status(400).json({
          success: false,
          message: 'No fields to update'
        });
      }

      updates.push('updated_at = NOW()');
      values.push(id);

      const query = `UPDATE Company_Rules SET ${updates.join(', ')} WHERE id = ?`;
      await connection.query(query, values);

      console.log(`✅ Rule updated: ID ${id}`);

      res.status(200).json({
        success: true,
        message: 'Rule updated successfully',
        data: { id }
      });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('❌ Error updating rule:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update rule',
      error: error.message
    });
  }
};

// Delete rule
exports.deleteRule = async (req, res) => {
  try {
    const { id } = req.params;
    const connection = await pool.getConnection();
    
    try {
      // Check if rule exists
      const [existingRule] = await connection.query(
        `SELECT rule_name FROM Company_Rules WHERE id = ?`,
        [id]
      );

      if (existingRule.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Rule not found'
        });
      }

      // Delete rule
      await connection.query(
        `DELETE FROM Company_Rules WHERE id = ?`,
        [id]
      );

      console.log(`✅ Rule deleted: ${existingRule[0].rule_name}`);

      res.status(200).json({
        success: true,
        message: 'Rule deleted successfully',
        data: { id }
      });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('❌ Error deleting rule:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete rule',
      error: error.message
    });
  }
};

// Get rules by type
exports.getRulesByType = async (req, res) => {
  try {
    const { type } = req.params;
    
    const validTypes = ['WORKING_HOURS', 'BREAK_TIME', 'OVERTIME', 'LEAVE'];
    if (!validTypes.includes(type)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid rule type'
      });
    }

    const connection = await pool.getConnection();
    
    try {
      const [rules] = await connection.query(
        `SELECT * FROM Company_Rules WHERE rule_type = ? AND is_active = TRUE ORDER BY priority ASC`,
        [type]
      );

      res.status(200).json({
        success: true,
        message: `Rules of type ${type} fetched successfully`,
        data: rules,
        count: rules.length
      });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('❌ Error fetching rules by type:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch rules by type',
      error: error.message
    });
  }
};
