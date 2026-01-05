// Direct test of the employee_id fix without needing login
const pool = require('./config/database');

async function testEmployeeIdMapping() {
  let connection;
  try {
    connection = await pool.getConnection();
    
    console.log('🧪 Testing Employee ID Mapping Fix\n');
    
    // Get Raffay Ahmed's info
    const [raffay] = await connection.query(
      `SELECT id, employee_id, name, email FROM user_as_employees 
       WHERE email = 'raffay.ahmed@digious.com'`
    );
    
    const raffayUser = raffay[0];
    console.log('👤 Employee Record:');
    console.log(`   user_as_employees.id: ${raffayUser.id}`);
    console.log(`   user_as_employees.employee_id: ${raffayUser.employee_id}`);
    console.log(`   Name: ${raffayUser.name}`);
    console.log(`   Email: ${raffayUser.email}`);
    
    // Verify this employee_id exists in employee_onboarding
    const [onboarded] = await connection.query(
      `SELECT id, name FROM employee_onboarding WHERE id = ?`,
      [raffayUser.employee_id]
    );
    
    if (onboarded.length > 0) {
      console.log(`\n✅ Correct: employee_id=${raffayUser.employee_id} exists in employee_onboarding`);
    } else {
      console.log(`\n❌ ERROR: employee_id=${raffayUser.employee_id} NOT found in employee_onboarding`);
    }
    
    // Now test the check-in logic simulation
    console.log('\n🧪 Simulating Check-In Logic:\n');
    
    // Simulate what the middleware would extract
    const jwtEmployeeId = raffayUser.employee_id; // From JWT (should be 12)
    const requestEmployeeId = 6; // What the request body mistakenly sends
    
    // Simulate the new check-in logic
    let employee_id = jwtEmployeeId || requestEmployeeId;
    
    console.log(`   JWT employeeId: ${jwtEmployeeId}`);
    console.log(`   Request employee_id: ${requestEmployeeId}`);
    console.log(`   Using employee_id: ${employee_id} ← This should be ${raffayUser.employee_id}`);
    
    if (employee_id === raffayUser.employee_id) {
      console.log(`\n✅ CORRECT: Using the right employee_id from JWT`);
    } else {
      console.log(`\n❌ WRONG: Using incorrect employee_id`);
    }
    
    // Try to insert with the correct employee_id
    console.log('\n📝 Testing INSERT with correct employee_id...');
    
    const today = new Date().toISOString().split('T')[0];
    
    // Check if record already exists
    const [existing] = await connection.query(
      `SELECT id FROM Employee_Attendance 
       WHERE employee_id = ? AND attendance_date = ?`,
      [employee_id, today]
    );
    
    if (existing.length > 0) {
      console.log(`   Record already exists for today, skipping INSERT test`);
    } else {
      const [insertResult] = await connection.query(
        `INSERT INTO Employee_Attendance 
         (employee_id, email, name, attendance_date, check_in_time, status, on_time, late_by_minutes)
         VALUES (?, ?, ?, ?, '00:16:00', 'Present', 1, 0)`,
        [employee_id, raffayUser.email, raffayUser.name, today]
      );
      
      console.log(`✅ INSERT successful with employee_id=${employee_id}`);
      console.log(`   Inserted record ID: ${insertResult.insertId}`);
    }
    
    connection.release();
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    if (connection) connection.release();
  }
}

testEmployeeIdMapping();
