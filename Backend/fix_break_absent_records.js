const pool = require('./config/database');

async function fixBreakAbsentRecords() {
  let connection;
  try {
    connection = await pool.getConnection();

    // Find absent attendance records that have break records
    const [rows] = await connection.query(
      `SELECT 
         a.id as attendance_id,
         a.employee_id,
         (SELECT name FROM employee_onboarding WHERE id = a.employee_id) as employee_name,
         a.attendance_date,
         COUNT(b.id) as break_count,
         MIN(b.break_start_time) as first_break_start,
         SUM(COALESCE(b.break_duration_minutes, TIMESTAMPDIFF(MINUTE, b.break_start_time, b.break_end_time))) as total_break_minutes
       FROM Employee_Attendance a
       JOIN Employee_Breaks b ON a.id = b.attendance_id
       WHERE a.status = 'Absent'
       GROUP BY a.id
       HAVING break_count > 0
       ORDER BY a.attendance_date DESC`);

    console.log(`Found ${rows.length} Absent records with break activity`);

    for (const r of rows) {
      const attendanceId = r.attendance_id;
      const minStart = r.first_break_start || null;
      const totalMinutes = r.total_break_minutes || 0;

      console.log(`Fixing attendance ${attendanceId} (${r.employee_name} @ ${r.attendance_date}) → breaks: ${r.break_count}, ${totalMinutes}m`);

      await connection.query(
        `UPDATE Employee_Attendance SET
           status = 'Present',
           check_in_time = COALESCE(check_in_time, ?),
           total_breaks_taken = ?,
           total_break_duration_minutes = COALESCE(total_break_duration_minutes, 0) + ?,
           updated_at = NOW()
         WHERE id = ?`,
        [minStart, r.break_count, totalMinutes, attendanceId]
      );

      console.log(`  -> Updated attendance ${attendanceId} to Present`);
    }

    connection.release();
    console.log('Done fixing records.');
  } catch (err) {
    console.error('Error fixing break/absent records:', err.message);
    if (connection) connection.release();
  }
}

fixBreakAbsentRecords();
