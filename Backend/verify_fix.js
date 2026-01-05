const pool = require('./config/database');

async function verifyFix() {
  let connection;
  try {
    connection = await pool.getConnection();
    
    console.log('\n╔════════════════════════════════════════════════╗');
    console.log('║   Employee ID Mapping Verification Report     ║');
    console.log('╚════════════════════════════════════════════════╝\n');
    
    // Get all employees
    const [employees] = await connection.query(
      `SELECT id, employee_id, name, email FROM user_as_employees ORDER BY id`
    );
    
    console.log('📋 Employee ID Mappings:\n');
    console.log('Name                 | user_emp.id | emp_id | onboarding.id | Status');
    console.log('─────────────────────|─────────────|────────|───────────────|────────');
    
    let allValid = true;
    
    for (const emp of employees) {
      // Check if employee_id exists in employee_onboarding
      const [onboarded] = await connection.query(
        `SELECT id FROM employee_onboarding WHERE id = ?`,
        [emp.employee_id]
      );
      
      const status = onboarded.length > 0 ? '✅ Valid' : '❌ Invalid';
      if (onboarded.length === 0) allValid = false;
      
      console.log(
        `${emp.name.padEnd(20)} | ${String(emp.id).padEnd(11)} | ${String(emp.employee_id).padEnd(6)} | ${String(emp.employee_id).padEnd(13)} | ${status}`
      );
    }
    
    console.log('\n📊 Summary:\n');
    
    if (allValid) {
      console.log('✅ ALL EMPLOYEES MAPPED CORRECTLY\n');
      console.log('The fix ensures:');
      console.log('  1. Check-in uses employeeId from JWT (e.g., 12 for Raffay)');
      console.log('  2. This matches employee_onboarding.id (e.g., 12)');
      console.log('  3. Foreign key constraint is satisfied ✅\n');
    } else {
      console.log('❌ SOME EMPLOYEES HAVE INVALID MAPPINGS\n');
    }
    
    // Verify recent check-ins
    const [recentCheckins] = await connection.query(
      `SELECT DISTINCT employee_id, name FROM Employee_Attendance 
       ORDER BY created_at DESC LIMIT 10`
    );
    
    console.log('📝 Recent Attendance Records:\n');
    console.log('Employee Name        | employee_id | Exists in onboarding');
    console.log('─────────────────────|─────────────|─────────────────────');
    
    for (const record of recentCheckins) {
      const [check] = await connection.query(
        `SELECT id FROM employee_onboarding WHERE id = ?`,
        [record.employee_id]
      );
      const status = check.length > 0 ? '✅ Yes' : '❌ No';
      console.log(`${record.name.padEnd(20)} | ${String(record.employee_id).padEnd(11)} | ${status}`);
    }
    
    connection.release();
    console.log('\n✅ Verification complete!\n');
    
  } catch (error) {
    console.error('Error:', error.message);
    if (connection) connection.release();
  }
}

verifyFix();
