const pool = require('../../config/database');

// Debug endpoint to check dynamic resources in database
exports.debugDynamicResources = async (req, res) => {
  let connection;
  try {
    connection = await pool.getConnection();
    
    const [resources] = await connection.query(
      `SELECT edr.*, eo.name, eo.employee_id 
       FROM employee_dynamic_resources edr
       LEFT JOIN employee_onboarding eo ON edr.employee_id = eo.id
       ORDER BY edr.id DESC
       LIMIT 20`
    );

    console.log('📋 All Dynamic Resources in Database:', resources);

    res.status(200).json({
      success: true,
      message: 'Dynamic resources debug data',
      data: resources,
      total: resources.length
    });

  } catch (error) {
    console.error('❌ Error fetching dynamic resources:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching dynamic resources',
      error: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};

// Debug endpoint to check specific employee's resources
exports.debugEmployeeResources = async (req, res) => {
  try {
    const { id } = req.params;

    const connection = await pool.getConnection();

    try {
      // Get employee
      const [employees] = await connection.query(
        `SELECT * FROM employee_onboarding WHERE id = ?`,
        [id]
      );

      if (employees.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Employee not found'
        });
      }

      // Get predefined resources
      const [predefinedResources] = await connection.query(
        `SELECT * FROM employee_resources WHERE employee_id = ?`,
        [id]
      );

      // Get dynamic resources
      const [dynamicResources] = await connection.query(
        `SELECT * FROM employee_dynamic_resources WHERE employee_id = ?`,
        [id]
      );

      console.log(`🔍 Employee ${id} - ${employees[0].name}`);
      console.log('Predefined Resources:', predefinedResources);
      console.log('Dynamic Resources:', dynamicResources);

      res.status(200).json({
        success: true,
        employee: employees[0],
        predefinedResources: predefinedResources[0] || {},
        dynamicResources: dynamicResources
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({
      success: false,
      message: 'Error',
      error: error.message
    });
  }
};
