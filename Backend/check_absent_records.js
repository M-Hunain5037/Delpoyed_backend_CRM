const pool = require('./config/database');

async function checkAbsentRecords() {
  let connection;
  try {
    connection = await pool.getConnection();
    
    // Check for 2025-11-05 specifically
    const [records] = await connection.query(
      `SELECT id, employee_id, attendance_date, status FROM Employee_Attendance 
       WHERE employee_id = 1 AND DATE(attendance_date) = '2025-11-05'`
    );
    
    console.log('🔍 Records for 2025-11-05:');
    console.log(JSON.stringify(records, null, 2));
    
    // Check raw attendance_date values
    const [rawRecords] = await connection.query(
      `SELECT id, employee_id, attendance_date, CAST(attendance_date AS CHAR) as date_str, 
              DATE(attendance_date) as date_only, status FROM Employee_Attendance 
       WHERE employee_id = 1 ORDER BY attendance_date LIMIT 15`
    );
    
    console.log('\n📅 Raw attendance dates:');
    rawRecords.forEach(record => {
      console.log(`   ID: ${record.id}, Raw: ${record.attendance_date}, Char: ${record.date_str}, Date: ${record.date_only}, Status: ${record.status}`);
    });
    
    connection.release();
  } catch (error) {
    console.error('Error:', error);
  }
}

checkAbsentRecords();
