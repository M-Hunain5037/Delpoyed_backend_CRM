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
      sub_department,
      join_date,
      joinDate,
      baseSalary,
      allowances,
      address,
      emergencyContact,
      emergency_contact,
      bankAccount,
      bank_account,
      taxId,
      tax_id,
      designation,
      employment_status,
      employmentStatus,
      confirmation_date,
      confirmationDate,
      account_title_name,
      accountTitleName,
      bank_name,
      bankName,
      cnic_issue_date,
      cnicIssueDate,
      cnic_expiry_date,
      cnicExpiryDate,
      requestPasswordChange,
      request_password_change,
      // Resources
      laptop,
      laptopSerial,
      laptop_serial,
      charger,
      chargerSerial,
      charger_serial,
      mouse,
      mouseSerial,
      mouse_serial,
      mobile,
      mobileSerial,
      mobile_serial,
      keyboard,
      keyboardSerial,
      keyboard_serial,
      monitor,
      monitorSerial,
      monitor_serial,
      dynamicResources,
      dynamic_resources,
      resourcesNote,
      resources_note
    } = req.body;

    // Normalize field names (handle both camelCase and snake_case)
    const normalizedData = {
      employeeId,
      name,
      email,
      password,
      phone,
      cnic,
      department,
      sub_department,
      joinDate: join_date || joinDate,
      baseSalary,
      allowances,
      address,
      emergencyContact: emergency_contact || emergencyContact,
      bankAccount: bank_account || bankAccount,
      taxId: tax_id || taxId,
      designation,
      employmentStatus: employment_status || employmentStatus,
      confirmationDate: confirmation_date || confirmationDate,
      accountTitleName: account_title_name || accountTitleName,
      bankName: bank_name || bankName,
      cnicIssueDate: cnic_issue_date || cnicIssueDate,
      cnicExpiryDate: cnic_expiry_date || cnicExpiryDate,
      requestPasswordChange: request_password_change !== undefined ? request_password_change : requestPasswordChange,
      laptop,
      laptopSerial: laptop_serial || laptopSerial,
      charger,
      chargerSerial: charger_serial || chargerSerial,
      mouse,
      mouseSerial: mouse_serial || mouseSerial,
      mobile,
      mobileSerial: mobile_serial || mobileSerial,
      keyboard,
      keyboardSerial: keyboard_serial || keyboardSerial,
      monitor,
      monitorSerial: monitor_serial || monitorSerial,
      dynamicResources: dynamic_resources || dynamicResources,
      resourcesNote: resources_note || resourcesNote
    };

    const {
      joinDate: finalJoinDate,
      employmentStatus: finalEmploymentStatus,
      confirmationDate: finalConfirmationDate,
      accountTitleName: finalAccountTitleName,
      bankName: finalBankName,
      cnicIssueDate: finalCnicIssueDate,
      cnicExpiryDate: finalCnicExpiryDate,
      emergencyContact: finalEmergencyContact,
      bankAccount: finalBankAccount,
      taxId: finalTaxId
    } = normalizedData;

    // Normalize CNIC month-year (YYYY-MM) to full date YYYY-MM-01 for storage
    const normalizeMonthYearToDate = (val) => {
      if (!val) return null;
      // Accept YYYY-MM or YYYY-MM-DD
      if (/^\d{4}-\d{2}$/.test(val)) {
        const [y, m] = val.split('-');
        const mm = Number(m);
        if (mm >= 1 && mm <= 12) return `${y}-${m}-01`;
        return null;
      }
      if (/^\d{4}-\d{2}-\d{2}$/.test(val)) return val;
      return null;
    };

    const normalizedCnicIssueDate = normalizeMonthYearToDate(finalCnicIssueDate);
    const normalizedCnicExpiryDate = normalizeMonthYearToDate(finalCnicExpiryDate);

    if (finalCnicIssueDate && !normalizedCnicIssueDate) {
      return res.status(400).json({ success: false, message: 'CNIC issue date format invalid. Use month and year (YYYY-MM) or full date YYYY-MM-DD' });
    }
    if (finalCnicExpiryDate && !normalizedCnicExpiryDate) {
      return res.status(400).json({ success: false, message: 'CNIC expiry date format invalid. Use month and year (YYYY-MM) or full date YYYY-MM-DD' });
    }

    // Ensure expiry is same or after issue month
    if (normalizedCnicIssueDate && normalizedCnicExpiryDate) {
      if (new Date(normalizedCnicExpiryDate) < new Date(normalizedCnicIssueDate)) {
        return res.status(400).json({ success: false, message: 'CNIC expiry must be same or after issue month' });
      }
    }

    // Validation
    // Email must be @digioussolutions.com
    if (!normalizedData.email || !normalizedData.email.endsWith('@digioussolutions.com')) {
      return res.status(400).json({
        success: false,
        message: 'Email must be @digioussolutions.com domain',
        received: { email: normalizedData.email }
      });
    }

    if (!normalizedData.employeeId || !normalizedData.name || !normalizedData.email || !normalizedData.password || !normalizedData.phone || !normalizedData.department || !normalizedData.sub_department || !normalizedData.joinDate || !normalizedData.baseSalary || !finalEmploymentStatus || !finalConfirmationDate || !finalAccountTitleName || !finalBankName) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields. Required: employeeId, name, email, password, phone, department, sub_department, joinDate, baseSalary, employment_status, confirmation_date, account_title_name, bank_name',
        received: {
          employeeId: normalizedData.employeeId,
          name: normalizedData.name,
          email: normalizedData.email,
          password: normalizedData.password ? '***' : 'missing',
          phone: normalizedData.phone,
          department: normalizedData.department,
          sub_department: normalizedData.sub_department,
          joinDate: normalizedData.joinDate,
          baseSalary: normalizedData.baseSalary,
          employmentStatus: finalEmploymentStatus,
          confirmationDate: finalConfirmationDate,
          accountTitleName: finalAccountTitleName,
          bankName: finalBankName
        }
      });
    }

    const connection = await pool.getConnection();
    
    try {
      await connection.beginTransaction();

      // Hash password
      const hashedPassword = await bcrypt.hash(normalizedData.password, 10);

      // Insert employee onboarding record
      const [employeeResult] = await connection.query(
        `INSERT INTO employee_onboarding 
        (employee_id, name, email, password_temp, phone, cnic, department, sub_department, join_date, confirmation_date, address, emergency_contact, request_password_change, account_title_name, bank_name, bank_account, tax_id, designation, employment_status, cnic_issue_date, cnic_expiry_date, status)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          normalizedData.employeeId, 
          normalizedData.name, 
          normalizedData.email, 
          hashedPassword, 
          normalizedData.phone, 
          normalizedData.cnic || null, 
          normalizedData.department, 
          normalizedData.sub_department, 
          normalizedData.joinDate, 
          finalConfirmationDate, 
          normalizedData.address || null, 
          finalEmergencyContact || null, 
          normalizedData.requestPasswordChange ? 1 : 0, 
          finalAccountTitleName, 
          finalBankName, 
          finalBankAccount || null, 
          finalTaxId || null, 
          normalizedData.designation || null, 
          finalEmploymentStatus, 
          normalizedCnicIssueDate || null, 
          normalizedCnicExpiryDate || null, 
          'Active'
        ]
      );

      const newEmployeeId = employeeResult.insertId;

      // Insert bank account details
      if (finalAccountTitleName && finalBankName) {
        // Generate account number if not provided (use employee_id + timestamp)
        const generatedAccountNumber = `${normalizedData.employeeId}-${Date.now()}`.substring(0, 50);
        await connection.query(
          `INSERT INTO employee_bank_accounts (employee_id, account_number, account_title_name, bank_name, is_primary) VALUES (?, ?, ?, ?, 1)`,
          [newEmployeeId, generatedAccountNumber, finalAccountTitleName, finalBankName]
        );
      }

      // Insert salary record
      const totalSalary = normalizedData.baseSalary + (normalizedData.allowances?.reduce((sum, a) => sum + a.amount, 0) || 0);
      await connection.query(
        `INSERT INTO employee_salary (employee_id, base_salary, total_salary) VALUES (?, ?, ?)`,
        [newEmployeeId, normalizedData.baseSalary, totalSalary]
      );

      // Insert allowances
      if (normalizedData.allowances && normalizedData.allowances.length > 0) {
        for (const allowance of normalizedData.allowances) {
          await connection.query(
            `INSERT INTO employee_allowances (employee_id, allowance_name, allowance_amount, currency) VALUES (?, ?, ?, ?)`,
            [newEmployeeId, allowance.name, allowance.amount, 'PKR']
          );
        }
      }

      // Insert resources
      await connection.query(
        `INSERT INTO employee_resources 
        (employee_id, laptop, laptop_serial, charger, charger_serial, mouse, mouse_serial, mobile, mobile_serial, keyboard, keyboard_serial, monitor, monitor_serial, resources_note)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [newEmployeeId, normalizedData.laptop || false, normalizedData.laptopSerial || null, normalizedData.charger || false, normalizedData.chargerSerial || null, normalizedData.mouse || false, normalizedData.mouseSerial || null, normalizedData.mobile || false, normalizedData.mobileSerial || null, normalizedData.keyboard || false, normalizedData.keyboardSerial || null, normalizedData.monitor || false, normalizedData.monitorSerial || null, normalizedData.resourcesNote || null]
      );

      // Insert dynamic resources
      if (normalizedData.dynamicResources && normalizedData.dynamicResources.length > 0) {
        console.log('📦 Inserting dynamic resources:', normalizedData.dynamicResources);
        for (const resource of normalizedData.dynamicResources) {
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
          employeeId: normalizedData.employeeId,
          name: normalizedData.name,
          email: normalizedData.email,
          department: normalizedData.department,
          sub_department: normalizedData.sub_department,
          employment_status: finalEmploymentStatus,
          confirmation_date: finalConfirmationDate,
          account_title_name: finalAccountTitleName,
          bank_name: finalBankName,
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

      // Build update query for employee_onboarding
      const allowedFields = ['name', 'email', 'phone', 'cnic', 'department', 'sub_department', 'address', 'emergency_contact', 'account_title_name', 'bank_name', 'bank_account', 'tax_id', 'status', 'designation', 'employment_status', 'confirmation_date', 'cnic_issue_date', 'cnic_expiry_date'];
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

      // Update resources if provided
      if (updates.laptop !== undefined || updates.charger !== undefined || updates.mouse !== undefined || 
          updates.keyboard !== undefined || updates.monitor !== undefined || updates.mobile !== undefined ||
          updates.resources_note !== undefined) {
        
        const resourceFields = [];
        const resourceValues = [];

        if (updates.laptop !== undefined) {
          resourceFields.push('laptop = ?');
          resourceValues.push(updates.laptop ? 1 : 0);
        }
        if (updates.laptop_serial !== undefined) {
          resourceFields.push('laptop_serial = ?');
          resourceValues.push(updates.laptop_serial || null);
        }
        if (updates.charger !== undefined) {
          resourceFields.push('charger = ?');
          resourceValues.push(updates.charger ? 1 : 0);
        }
        if (updates.charger_serial !== undefined) {
          resourceFields.push('charger_serial = ?');
          resourceValues.push(updates.charger_serial || null);
        }
        if (updates.mouse !== undefined) {
          resourceFields.push('mouse = ?');
          resourceValues.push(updates.mouse ? 1 : 0);
        }
        if (updates.mouse_serial !== undefined) {
          resourceFields.push('mouse_serial = ?');
          resourceValues.push(updates.mouse_serial || null);
        }
        if (updates.keyboard !== undefined) {
          resourceFields.push('keyboard = ?');
          resourceValues.push(updates.keyboard ? 1 : 0);
        }
        if (updates.keyboard_serial !== undefined) {
          resourceFields.push('keyboard_serial = ?');
          resourceValues.push(updates.keyboard_serial || null);
        }
        if (updates.monitor !== undefined) {
          resourceFields.push('monitor = ?');
          resourceValues.push(updates.monitor ? 1 : 0);
        }
        if (updates.monitor_serial !== undefined) {
          resourceFields.push('monitor_serial = ?');
          resourceValues.push(updates.monitor_serial || null);
        }
        if (updates.mobile !== undefined) {
          resourceFields.push('mobile = ?');
          resourceValues.push(updates.mobile ? 1 : 0);
        }
        if (updates.mobile_serial !== undefined) {
          resourceFields.push('mobile_serial = ?');
          resourceValues.push(updates.mobile_serial || null);
        }
        if (updates.resources_note !== undefined) {
          resourceFields.push('resources_note = ?');
          resourceValues.push(updates.resources_note || null);
        }

        if (resourceFields.length > 0) {
          resourceValues.push(id);
          await connection.query(
            `UPDATE employee_resources SET ${resourceFields.join(', ')} WHERE employee_id = ?`,
            resourceValues
          );
        }
      }

      // Update allowances if provided
      if (updates.allowances && Array.isArray(updates.allowances)) {
        // First, delete existing allowances
        await connection.query(
          `DELETE FROM employee_allowances WHERE employee_id = ?`,
          [id]
        );

        // Then insert new allowances
        for (const allowance of updates.allowances) {
          if (allowance.name && allowance.amount) {
            await connection.query(
              `INSERT INTO employee_allowances (employee_id, allowance_name, allowance_amount) VALUES (?, ?, ?)`,
              [id, allowance.name, allowance.amount]
            );
          }
        }
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

// Check if employee ID is available
exports.checkEmployeeIdAvailability = async (req, res) => {
  try {
    const { numericId } = req.params;
    const EMPLOYEE_ID_PREFIX = 'DG';

    // Validate numeric ID
    // Must be at least 3 digits and not "000"
    if (!numericId || !/^\d+$/.test(numericId)) {
      return res.status(400).json({
        success: false,
        message: 'Employee ID must contain only numeric digits',
        exists: false
      });
    }

    // Validate it's at least 3 digits
    if (numericId.length < 3) {
      return res.status(400).json({
        success: false,
        message: 'Employee ID must have at least 3 digits',
        exists: false
      });
    }

    // Validate "000" is not allowed
    if (numericId === '000' || parseInt(numericId) === 0) {
      return res.status(400).json({
        success: false,
        message: '000 is not a valid Employee ID',
        exists: false
      });
    }

    // Keep the ID as-is without padding for exact match checking
    const fullEmployeeId = `${EMPLOYEE_ID_PREFIX}-${numericId}`;

    // Check if EXACT ID exists in database (case-insensitive) - use the exact user input
    const [result] = await pool.query(
      `SELECT employee_id FROM employee_onboarding WHERE UPPER(employee_id) = UPPER(?)`,
      [fullEmployeeId]
    );

    const exists = result.length > 0;

    if (!exists) {
      // ID is available
      return res.status(200).json({
        success: true,
        message: 'Employee ID is available',
        exists: false,
        employeeId: fullEmployeeId
      });
    }

    // ID exists, suggest next available ID
    // Get all employee IDs with the configured prefix (case-insensitive)
    const [allIds] = await pool.query(
      `SELECT employee_id FROM employee_onboarding 
       WHERE UPPER(employee_id) LIKE UPPER(?)
       ORDER BY CAST(SUBSTRING_INDEX(employee_id, '-', -1) AS UNSIGNED) ASC`,
      [`${EMPLOYEE_ID_PREFIX}-%`]
    );

    // Extract numeric parts and find next available
    const usedNumbers = allIds.map(row => {
      const numPart = row.employee_id.split('-')[1];
      return parseInt(numPart);
    }).filter(n => !isNaN(n) && n !== 0);

    // Find next available number
    let nextNumber = 1;
    for (let num of usedNumbers) {
      if (num === nextNumber) {
        nextNumber++;
      } else {
        break;
      }
    }

    const suggestedId = `${EMPLOYEE_ID_PREFIX}-${nextNumber}`;

    return res.status(200).json({
      success: false,
      message: 'Employee ID already exists',
      exists: true,
      employeeId: fullEmployeeId,
      suggestedId: suggestedId
    });

  } catch (error) {
    console.error('Error checking employee ID:', error);
    res.status(500).json({
      success: false,
      message: 'Error checking employee ID availability',
      error: error.message,
      exists: false
    });
  }
};
