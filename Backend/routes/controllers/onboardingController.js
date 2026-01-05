const pool = require('../../config/database');
const bcrypt = require('bcryptjs');

// Create new employee onboarding
exports.createEmployee = async (req, res) => {
  try {
    const {
      employeeId,
      name,
      email,
      password,
      phone,
      cnic,
      department,
      position,
      joinDate,
      baseSalary,
      allowances,
      address,
      emergencyContact,
      bankAccount,
      taxId,
      designation,
      // Resources
      laptop,
      laptopSerial,
      charger,
      chargerSerial,
      mouse,
      mouseSerial,
      mobile,
      mobileSerial,
      keyboard,
      keyboardSerial,
      monitor,
      monitorSerial,
      dynamicResources,
      resourcesNote
    } = req.body;

    // Validation
    if (!employeeId || !name || !email || !password || !phone || !department || !position || !joinDate || !baseSalary) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields'
      });
    }

    const connection = await pool.getConnection();
    
    try {
      await connection.beginTransaction();

      // Hash password
      const hashedPassword = await bcrypt.hash(password, 10);

      // Insert employee onboarding record
      const [employeeResult] = await connection.query(
        `INSERT INTO employee_onboarding 
        (employee_id, name, email, password_temp, phone, cnic, department, position, join_date, address, emergency_contact, bank_account, tax_id, designation, status)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [employeeId, name, email, hashedPassword, phone, cnic || null, department, position, joinDate, address || null, emergencyContact || null, bankAccount || null, taxId || null, designation || null, 'Active']
      );

      const newEmployeeId = employeeResult.insertId;

      // Insert salary record
      const totalSalary = baseSalary + (allowances?.reduce((sum, a) => sum + a.amount, 0) || 0);
      await connection.query(
        `INSERT INTO employee_salary (employee_id, base_salary, total_salary) VALUES (?, ?, ?)`,
        [newEmployeeId, baseSalary, totalSalary]
      );

      // Insert allowances
      if (allowances && allowances.length > 0) {
        for (const allowance of allowances) {
          await connection.query(
            `INSERT INTO employee_allowances (employee_id, allowance_name, allowance_amount) VALUES (?, ?, ?)`,
            [newEmployeeId, allowance.name, allowance.amount]
          );
        }
      }

      // Insert resources
      await connection.query(
        `INSERT INTO employee_resources 
        (employee_id, laptop, laptop_serial, charger, charger_serial, mouse, mouse_serial, mobile, mobile_serial, keyboard, keyboard_serial, monitor, monitor_serial, resources_note)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [newEmployeeId, laptop || false, laptopSerial || null, charger || false, chargerSerial || null, mouse || false, mouseSerial || null, mobile || false, mobileSerial || null, keyboard || false, keyboardSerial || null, monitor || false, monitorSerial || null, resourcesNote || null]
      );

      // Insert dynamic resources
      if (dynamicResources && dynamicResources.length > 0) {
        console.log('📦 Inserting dynamic resources:', dynamicResources);
        for (const resource of dynamicResources) {
          const insertResult = await connection.query(
            `INSERT INTO employee_dynamic_resources (employee_id, resource_name, resource_serial) VALUES (?, ?, ?)`,
            [newEmployeeId, resource.name, resource.serial || null]
          );
          console.log('✅ Dynamic resource inserted:', insertResult);
        }
      }

      // Initialize onboarding progress
      await connection.query(
        `INSERT INTO onboarding_progress 
        (employee_id, step_1_basic_info, step_2_security_setup, step_3_job_details, step_4_allowances, step_5_additional_info, step_6_review_confirm, is_completed, overall_completion_percentage)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [newEmployeeId, 1, 1, 1, 1, 1, 1, 1, 100]
      );

      // NOTE: Employee is automatically synced to user_as_employees by the after_employee_insert trigger
      // Do NOT manually insert here - let the trigger handle it

      console.log(`✅ Employee added with ID ${newEmployeeId} - trigger will auto-sync to user_as_employees`);

      // Fetch created dynamic resources to return
      const [createdDynamicResources] = await connection.query(
        `SELECT id, resource_name as name, resource_serial as serial FROM employee_dynamic_resources WHERE employee_id = ?`,
        [newEmployeeId]
      );

      await connection.commit();

      res.status(201).json({
        success: true,
        message: 'Employee onboarded successfully',
        data: {
          id: newEmployeeId,
          employeeId,
          name,
          email,
          department,
          position,
          status: 'Active',
          dynamicResourcesCreated: createdDynamicResources
        }
      });

    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('❌ Error creating employee:', error);
    console.error('Error Stack:', error.stack);
    console.error('Error Code:', error.code);
    console.error('Error SQL:', error.sql);
    res.status(500).json({
      success: false,
      message: 'Error creating employee',
      error: error.message,
      code: error.code,
      details: process.env.NODE_ENV === 'development' ? error.sql : undefined
    });
  }
};

// Get all employees
exports.getAllEmployees = async (req, res) => {
  try {
    const [employees] = await pool.query(
      `SELECT eo.*, es.base_salary, es.total_salary 
       FROM employee_onboarding eo
       LEFT JOIN employee_salary es ON eo.id = es.employee_id
       ORDER BY eo.created_at DESC`
    );

    res.status(200).json({
      success: true,
      data: employees,
      total: employees.length
    });

  } catch (error) {
    console.error('Error fetching employees:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching employees',
      error: error.message
    });
  }
};

// Get single employee with all details
exports.getEmployeeById = async (req, res) => {
  try {
    const { id } = req.params;

    const connection = await pool.getConnection();

    try {
      // Get basic employee info
      const [employees] = await connection.query(
        `SELECT eo.*, es.base_salary, es.total_salary 
         FROM employee_onboarding eo
         LEFT JOIN employee_salary es ON eo.id = es.employee_id
         WHERE eo.id = ?`,
        [id]
      );

      if (employees.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Employee not found'
        });
      }

      const employee = employees[0];

      // Get allowances
      const [allowances] = await connection.query(
        `SELECT allowance_name as name, allowance_amount as amount 
         FROM employee_allowances 
         WHERE employee_id = ?`,
        [id]
      );

      // Get resources
      const [resources] = await connection.query(
        `SELECT * FROM employee_resources WHERE employee_id = ?`,
        [id]
      );

      // Get dynamic resources
      const [dynamicResources] = await connection.query(
        `SELECT id, resource_name as name, resource_serial as serial 
         FROM employee_dynamic_resources 
         WHERE employee_id = ?`,
        [id]
      );

      // Get onboarding progress
      const [progress] = await connection.query(
        `SELECT * FROM onboarding_progress WHERE employee_id = ?`,
        [id]
      );

      res.status(200).json({
        success: true,
        data: {
          ...employee,
          allowances,
          resources: resources[0] || {},
          dynamicResources,
          onboardingProgress: progress[0] || {}
        }
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('Error fetching employee:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching employee',
      error: error.message
    });
  }
};

// Update employee
exports.updateEmployee = async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;

    const connection = await pool.getConnection();

    try {
      await connection.beginTransaction();

      // Build update query
      const allowedFields = ['name', 'email', 'phone', 'cnic', 'department', 'position', 'address', 'emergency_contact', 'bank_account', 'tax_id', 'status'];
      const updateFields = [];
      const updateValues = [];

      for (const [key, value] of Object.entries(updates)) {
        if (allowedFields.includes(key)) {
          updateFields.push(`${key} = ?`);
          updateValues.push(value);
        }
      }

      if (updateFields.length > 0) {
        updateValues.push(id);
        await connection.query(
          `UPDATE employee_onboarding SET ${updateFields.join(', ')} WHERE id = ?`,
          updateValues
        );
      }

      await connection.commit();

      res.status(200).json({
        success: true,
        message: 'Employee updated successfully'
      });

    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('Error updating employee:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating employee',
      error: error.message
    });
  }
};

// Delete employee
exports.deleteEmployee = async (req, res) => {
  try {
    const { id } = req.params;

    const connection = await pool.getConnection();

    try {
      await connection.beginTransaction();

      // Delete related records (foreign keys will handle via CASCADE)
      await connection.query(`DELETE FROM employee_onboarding WHERE id = ?`, [id]);

      await connection.commit();

      res.status(200).json({
        success: true,
        message: 'Employee deleted successfully'
      });

    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('Error deleting employee:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting employee',
      error: error.message
    });
  }
};

// Get onboarding progress
exports.getOnboardingProgress = async (req, res) => {
  try {
    const { id } = req.params;

    const [progress] = await pool.query(
      `SELECT * FROM onboarding_progress WHERE employee_id = ?`,
      [id]
    );

    if (progress.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Onboarding progress not found'
      });
    }

    res.status(200).json({
      success: true,
      data: progress[0]
    });

  } catch (error) {
    console.error('Error fetching progress:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching progress',
      error: error.message
    });
  }
};
