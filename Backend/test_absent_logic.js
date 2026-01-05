// Test the absent record generation logic
const pool = require('./config/database');

async function testAbsentGeneration() {
  let connection;
  try {
    connection = await pool.getConnection();
    
    console.log('🔄 Testing absent record generation...');
    
    // Get all active employees with their joining dates
    const [employees] = await connection.query(
      `SELECT employee_id, name, email, created_at as joining_date 
       FROM user_as_employees 
       WHERE status = 'Active' LIMIT 2`
    );
    
    console.log('👥 Found employees:', employees.length);
    
    for (const employee of employees) {
      const { employee_id, name, email, joining_date } = employee;
      
      // Calculate date range from joining to today
      const startDate = new Date(joining_date);
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      
      console.log(`\n👤 ${name} (ID: ${employee_id})`);
      console.log(`   Joining: ${startDate.toDateString()}`);
      console.log(`   Today: ${today.toDateString()}`);
      
      // Get existing attendance dates
      const [existingDates] = await connection.query(
        `SELECT DISTINCT attendance_date FROM Employee_Attendance 
         WHERE employee_id = ? AND attendance_date >= ? AND attendance_date <= ?`,
        [employee_id, startDate.toISOString().split('T')[0], today.toISOString().split('T')[0]]
      );
      
      console.log(`   Existing records: ${existingDates.length}`);
      
      const existingDateSet = new Set(
        existingDates.map(row => row.attendance_date.toISOString().split('T')[0])
      );
      
      // Count missing days
      const currentDate = new Date(startDate);
      let missingDays = 0;
      let workingDays = 0;
      
      while (currentDate <= today) {
        const dateString = currentDate.toISOString().split('T')[0];
        const dayOfWeek = currentDate.getDay();
        const isWeekend = dayOfWeek === 0 || dayOfWeek === 6;
        
        if (!isWeekend) {
          workingDays++;
          if (!existingDateSet.has(dateString)) {
            missingDays++;
          }
        }
        
        currentDate.setDate(currentDate.getDate() + 1);
      }
      
      console.log(`   Working days since joining: ${workingDays}`);
      console.log(`   Missing attendance records: ${missingDays}`);
    }
    
    connection.release();
    console.log('\n✅ Test completed successfully');
    
  } catch (error) {
    console.error('❌ Test error:', error);
    if (connection) connection.release();
  }
}

// Run test
testAbsentGeneration();