// Check for break records on absent days
const pool = require('./config/database');

async function checkAbsentBreaks() {
  let connection;
  try {
    connection = await pool.getConnection();
    
    console.log('\n🔍 Checking for breaks on absent days...\n');
    
    // Find attendance records marked as Absent that have breaks
    const [absentWithBreaks] = await connection.query(
      `SELECT 
        ea.id,
        ea.employee_id,
        eo.name,
        ea.attendance_date,
        ea.status,
        ea.check_in_time,
        ea.check_out_time,
        COUNT(eb.id) as break_count,
        SUM(eb.duration) as total_break_minutes
       FROM Employee_Attendance ea
       LEFT JOIN employee_onboarding eo ON ea.employee_id = eo.id
       LEFT JOIN Employee_Breaks eb ON ea.id = eb.attendance_id
       WHERE ea.status = 'Absent'
       GROUP BY ea.id
       HAVING break_count > 0
       ORDER BY ea.attendance_date DESC
       LIMIT 20`
    );
    
    if (absentWithBreaks.length === 0) {
      console.log('✅ No breaks found on absent days\n');
    } else {
      console.log(`⚠️  Found ${absentWithBreaks.length} absent days with breaks:\n`);
      console.log('Date       | Employee      | Status | Breaks | Total Minutes | Check-in | Check-out');
      console.log('-----------|---------------|--------|--------|---------------|----------|----------');
      
      for (const record of absentWithBreaks) {
        const date = new Date(record.attendance_date).toLocaleDateString();
        const name = (record.name || 'Unknown').substring(0, 13).padEnd(13);
        const checkIn = record.check_in_time || 'NULL';
        const checkOut = record.check_out_time || 'NULL';
        
        console.log(`${date} | ${name} | ${record.status} | ${record.break_count}      | ${record.total_break_minutes || 0}            | ${checkIn} | ${checkOut}`);
      }
      
      console.log('\n📊 Break Details for Absent Days:\n');
      
      // Get detailed break information
      const [breakDetails] = await connection.query(
        `SELECT 
          ea.attendance_date,
          eo.name,
          eb.break_start,
          eb.break_end,
          eb.duration,
          eb.break_type
         FROM Employee_Breaks eb
         JOIN Employee_Attendance ea ON eb.attendance_id = ea.id
         JOIN employee_onboarding eo ON ea.employee_id = eo.id
         WHERE ea.status = 'Absent'
         ORDER BY ea.attendance_date DESC, eb.break_start
         LIMIT 50`
      );
      
      for (const brk of breakDetails) {
        const date = new Date(brk.attendance_date).toLocaleDateString();
        console.log(`${date} | ${brk.name} | ${brk.break_type || 'Unknown'} | ${brk.break_start} → ${brk.break_end} (${brk.duration} min)`);
      }
    }
    
    connection.release();
    
  } catch (error) {
    console.error('Error:', error.message);
    if (connection) connection.release();
  }
}

checkAbsentBreaks();
