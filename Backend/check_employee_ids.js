const pool = require('./config/database');

async function checkEmployeeIds() {
  let connection;
  try {
    connection = await pool.getConnection();
    
    console.log('📋 Checking employee ID mappings...\n');
    
    // Check user_as_employees table
    const [employees] = await connection.query(
      `SELECT id, employee_id, name, email FROM user_as_employees LIMIT 10`
    );
    
    console.log('👥 user_as_employees table:');
    console.log('ID | employee_id | name | email');
    console.log('---|-------------|------|------');
    for (const emp of employees) {
      console.log(`${emp.id} | ${emp.employee_id} | ${emp.name} | ${emp.email}`);
    }
    
    console.log('\n');
    
    // Check employee_onboarding table
    const [onboarded] = await connection.query(
      `SELECT id, employee_id, name, email FROM employee_onboarding LIMIT 10`
    );
    
    console.log('📋 employee_onboarding table:');
    console.log('ID | employee_id | name | email');
    console.log('---|-------------|------|------');
    for (const emp of onboarded) {
      console.log(`${emp.id} | ${emp.employee_id} | ${emp.name} | ${emp.email}`);
    }
    
    console.log('\n');
    
    // Find mismatches
    console.log('🔍 Checking for mismatches...\n');
    
    for (const emp of employees) {
      const matchingOnboarded = onboarded.find(o => 
        o.id === emp.employee_id || 
        o.employee_id === emp.employee_id ||
        o.email === emp.email
      );
      
      if (!matchingOnboarded) {
        console.log(`❌ MISMATCH: ${emp.name} (user_as_employees.id=${emp.id}, employee_id=${emp.employee_id})`);
        console.log(`   Not found in employee_onboarding!`);
      } else {
        console.log(`✅ ${emp.name}: user_as_employees.employee_id=${emp.employee_id} → employee_onboarding.id=${matchingOnboarded.id}`);
      }
    }
    
    connection.release();
  } catch (error) {
    console.error('Error:', error.message);
    if (connection) connection.release();
  }
}

checkEmployeeIds();
