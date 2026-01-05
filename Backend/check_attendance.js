const pool = require('./config/database');

async function checkAttendance() {
  const connection = await pool.getConnection();
  try {
    // Get all records
    const [records] = await connection.query(
      `SELECT id, employee_id, email, name, attendance_date, check_in_time, check_out_time, status FROM Employee_Attendance ORDER BY attendance_date DESC LIMIT 20`
    );
    
    console.log('\n📊 All Attendance Records (Last 20):');
    console.log(`Total: ${records.length}`);
    records.forEach(r => {
      console.log(`  - ${r.name} | ${r.attendance_date} | Check-in: ${r.check_in_time} | Check-out: ${r.check_out_time} | Status: ${r.status}`);
    });

    // Get today's records
    const today = new Date().toISOString().split('T')[0];
    const [todayRecords] = await connection.query(
      `SELECT id, employee_id, email, name, attendance_date, check_in_time, check_out_time, status FROM Employee_Attendance WHERE attendance_date = ? ORDER BY check_in_time DESC`,
      [today]
    );
    
    console.log(`\n📅 Today's Records (${today}): ${todayRecords.length}`);
    todayRecords.forEach(r => {
      console.log(`  - ${r.name} | Check-in: ${r.check_in_time} | Check-out: ${r.check_out_time} | Status: ${r.status}`);
    });

  } finally {
    connection.release();
    process.exit(0);
  }
}

checkAttendance().catch(err => {
  console.error('Error:', err);
  process.exit(1);
});
