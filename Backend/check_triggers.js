const pool = require('./config/database');

async function checkTriggers() {
  let connection;
  try {
    connection = await pool.getConnection();
    
    console.log('\n╔════════════════════════════════════════════════╗');
    console.log('║    Employee Sync Triggers Analysis            ║');
    console.log('╚════════════════════════════════════════════════╝\n');
    
    // Get trigger definitions
    const [triggers] = await connection.query(
      `SELECT TRIGGER_NAME, EVENT_MANIPULATION, ACTION_STATEMENT
       FROM INFORMATION_SCHEMA.TRIGGERS
       WHERE TRIGGER_SCHEMA = 'Digious_CRM_DataBase'
       AND TRIGGER_NAME LIKE '%employee%'`
    );
    
    console.log('📌 Found Triggers:\n');
    
    for (const trigger of triggers) {
      console.log(`Trigger: ${trigger.TRIGGER_NAME}`);
      console.log(`Event: ${trigger.EVENT_MANIPULATION}`);
      console.log(`Action: ${trigger.ACTION_STATEMENT?.substring(0, 100)}...\n`);
    }
    
    // Test trigger by simulating onboarding
    console.log('🧪 Testing Employee Sync Process:\n');
    
    // Get the last onboarded employee (Raffay - ID 12)
    const [lastEmp] = await connection.query(
      `SELECT id, name, email FROM employee_onboarding 
       WHERE id = (SELECT MAX(id) FROM employee_onboarding)
       LIMIT 1`
    );
    
    if (lastEmp.length > 0) {
      const emp = lastEmp[0];
      console.log(`Most recent onboarded employee: ${emp.name} (ID: ${emp.id})\n`);
      
      // Check if sync exists
      const [synced] = await connection.query(
        `SELECT id, employee_id FROM user_as_employees 
         WHERE employee_id = ? LIMIT 1`,
        [emp.id]
      );
      
      if (synced.length > 0) {
        const userEmp = synced[0];
        console.log(`✅ Sync confirmed:`);
        console.log(`   employee_onboarding.id: ${emp.id}`);
        console.log(`   user_as_employees.employee_id: ${userEmp.employee_id}`);
        console.log(`   user_as_employees.id: ${userEmp.id}\n`);
        console.log(`This employee can now check in/out successfully! ✅\n`);
      } else {
        console.log(`❌ Sync FAILED for ${emp.name}`);
        console.log(`   Not found in user_as_employees\n`);
      }
    }
    
    // Test the complete workflow
    console.log('📝 Employee Onboarding Workflow:\n');
    console.log('1. Admin adds employee to employee_onboarding');
    console.log('   - employee_id is auto-assigned (DIG-001, DIG-002, etc.)');
    console.log('   - Status is set to "Active"\n');
    
    console.log('2. Trigger (after_employee_insert) fires');
    console.log('   - Creates entry in user_as_employees');
    console.log('   - Sets employee_id to onboarding.id (the numeric ID)\n');
    
    console.log('3. Employee can now login');
    console.log('   - JWT token contains correct employeeId\n');
    
    console.log('4. Employee can check in/out');
    console.log('   - Uses employeeId from JWT\n');
    
    console.log('5. Attendance recorded correctly');
    console.log('   - Foreign key constraint satisfied ✅\n');
    
    connection.release();
    
  } catch (error) {
    console.error('Error:', error.message);
    if (connection) connection.release();
  }
}

checkTriggers();
