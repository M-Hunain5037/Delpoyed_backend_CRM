const pool = require('./config/database');

async function checkDatabase() {
  let connection;
  try {
    connection = await pool.getConnection();
    
    console.log('\n========================================');
    console.log('DATABASE STRUCTURE CHECK');
    console.log('========================================\n');

    // 1. Check user_as_employees table structure
    console.log('1. user_as_employees Table Structure:');
    console.log('----------------------------------------');
    const [columns] = await connection.query(`
      SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT
      FROM information_schema.COLUMNS 
      WHERE TABLE_SCHEMA = 'Digious_CRM_DataBase' 
      AND TABLE_NAME = 'user_as_employees'
      ORDER BY ORDINAL_POSITION
    `);
    
    columns.forEach(col => {
      console.log(`  - ${col.COLUMN_NAME} (${col.DATA_TYPE})`);
    });

    // 2. Check for triggers
    console.log('\n2. Triggers on employee_onboarding:');
    console.log('----------------------------------------');
    const [triggers] = await connection.query(`
      SELECT TRIGGER_NAME, EVENT_MANIPULATION, ACTION_TIMING
      FROM information_schema.TRIGGERS 
      WHERE TRIGGER_SCHEMA = 'Digious_CRM_DataBase' 
      AND EVENT_OBJECT_TABLE = 'employee_onboarding'
    `);
    
    if (triggers.length === 0) {
      console.log('  ❌ NO TRIGGERS FOUND!');
    } else {
      triggers.forEach(t => {
        console.log(`  ✓ ${t.TRIGGER_NAME} (${t.ACTION_TIMING} ${t.EVENT_MANIPULATION})`);
      });
    }

    // 3. Check data in user_as_employees
    console.log('\n3. Current Data in user_as_employees:');
    console.log('----------------------------------------');
    const [users] = await connection.query(`
      SELECT * FROM user_as_employees LIMIT 5
    `);
    
    if (users.length === 0) {
      console.log('  ⚠️  No users found');
    } else {
      console.log(`  Total users: ${users.length}`);
      users.forEach(user => {
        console.log(`  - ID: ${user.id}, Employee ID: ${user.employee_id}`);
        console.log(`    Name: ${user.name || 'NULL'}, Email: ${user.email || 'NULL'}`);
        console.log(`    Password: ${user.password ? 'SET' : 'NULL'}`);
        console.log(`    Department: ${user.department || 'NULL'}, Position: ${user.position || 'NULL'}`);
      });
    }

    // 4. Check employee_onboarding data
    console.log('\n4. Employees in employee_onboarding:');
    console.log('----------------------------------------');
    const [employees] = await connection.query(`
      SELECT id, employee_id, name, email, department, position, status 
      FROM employee_onboarding 
      LIMIT 5
    `);
    
    console.log(`  Total employees: ${employees.length}`);
    employees.forEach(emp => {
      console.log(`  - ${emp.employee_id}: ${emp.name} (${emp.email}) - ${emp.department}`);
    });

    // 5. Check if DIG-005 exists
    console.log('\n5. Check DIG-005 Employee:');
    console.log('----------------------------------------');
    const [dig005onboarding] = await connection.query(`
      SELECT * FROM employee_onboarding WHERE employee_id = 'DIG-005'
    `);
    
    if (dig005onboarding.length > 0) {
      console.log('  ✓ DIG-005 exists in employee_onboarding');
      console.log(`    Name: ${dig005onboarding[0].name}`);
      console.log(`    Email: ${dig005onboarding[0].email}`);
    } else {
      console.log('  ❌ DIG-005 NOT found in employee_onboarding');
    }

    const [dig005auth] = await connection.query(`
      SELECT * FROM user_as_employees WHERE employee_id = 'DIG-005'
    `);
    
    if (dig005auth.length > 0) {
      console.log('  ✓ DIG-005 exists in user_as_employees');
      console.log(`    Name: ${dig005auth[0].name || 'NULL'}`);
      console.log(`    Email: ${dig005auth[0].email || 'NULL'}`);
    } else {
      console.log('  ❌ DIG-005 NOT found in user_as_employees');
    }

    console.log('\n========================================');
    console.log('DIAGNOSIS SUMMARY');
    console.log('========================================');
    
    const hasNameColumn = columns.some(c => c.COLUMN_NAME === 'name');
    const hasEmailColumn = columns.some(c => c.COLUMN_NAME === 'email');
    const hasPasswordColumn = columns.some(c => c.COLUMN_NAME === 'password');
    const hasTriggers = triggers.length === 3;
    
    if (!hasNameColumn || !hasEmailColumn || !hasPasswordColumn) {
      console.log('❌ ISSUE: Missing required columns in user_as_employees');
      console.log('   FIX: Run complete_setup.sql to add columns');
    }
    
    if (!hasTriggers) {
      console.log('❌ ISSUE: Triggers not configured (found ' + triggers.length + '/3)');
      console.log('   FIX: Run complete_setup.sql to create triggers');
    }
    
    if (hasNameColumn && hasEmailColumn && hasPasswordColumn && hasTriggers) {
      console.log('✓ Everything looks good!');
      console.log('  Try inserting a test employee to verify triggers work.');
    }

    console.log('\n');

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    if (connection) connection.release();
    process.exit(0);
  }
}

checkDatabase();
