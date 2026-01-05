const pool = require('./config/database');

async function checkBreakLogic() {
  let connection;
  try {
    connection = await pool.getConnection();
    
    console.log('\n╔════════════════════════════════════════════════╗');
    console.log('║     Break Records for Absent Employees        ║');
    console.log('╚════════════════════════════════════════════════╝\n');
    
    // Check for breaks on absent days
    const [results] = await connection.query(
      `SELECT 
        a.id as attendance_id,
        a.employee_id,
        (SELECT name FROM employee_onboarding WHERE id = a.employee_id) as employee_name,
        a.attendance_date,
        a.status,
        a.check_in_time,
        a.check_out_time,
        COUNT(b.id) as break_count,
        SUM(TIMESTAMPDIFF(MINUTE, b.break_start, b.break_end)) as total_break_minutes
       FROM Employee_Attendance a
       LEFT JOIN Employee_Breaks b ON a.id = b.attendance_id
       WHERE a.status = 'Absent'
       GROUP BY a.id
       HAVING break_count > 0
       ORDER BY a.attendance_date DESC
       LIMIT 20`
    );
    
    console.log(`Found ${results.length} Absent records with breaks:\n`);
    
    if (results.length > 0) {
      console.log('ISSUE FOUND:');
      console.log('═════════════════════════════════════════════\n');
      
      results.forEach((r, i) => {
        console.log(`${i + 1}. ${r.employee_name}`);
        console.log(`   Date: ${new Date(r.attendance_date).toDateString()}`);
        console.log(`   Status: ${r.status}`);
        console.log(`   Check-In: ${r.check_in_time}`);
        console.log(`   Check-Out: ${r.check_out_time}`);
        console.log(`   ❌ Breaks: ${r.break_count} (${r.total_break_minutes} min)`);
        console.log(`   PROBLEM: Absent employee should NOT have breaks!\n`);
      });
      
      console.log('✅ SOLUTION:');
      console.log('═════════════════════════════════════════════');
      console.log('Only allow break records when:');
      console.log('1. Status = "Present" (not "Absent")');
      console.log('2. Status = "Late" (not "Absent")');
      console.log('3. Status = "Early Leave" (not "Absent")');
      console.log('\nAbsent employees should have:');
      console.log('- No check_in_time');
      console.log('- No check_out_time');
      console.log('- No break records\n');
      
    } else {
      console.log('✅ No issues found - all break records are for Present/Late employees\n');
    }
    
    // Now check the absent records creation logic
    console.log('\n📊 Checking Absent Records Generation:\n');
    
    const [absentStats] = await connection.query(
      `SELECT 
        a.employee_id,
        (SELECT name FROM employee_onboarding WHERE id = a.employee_id) as employee_name,
        COUNT(*) as absent_count,
        MIN(a.attendance_date) as first_absent,
        MAX(a.attendance_date) as last_absent,
        COUNT(DISTINCT b.id) as break_records
       FROM Employee_Attendance a
       LEFT JOIN Employee_Breaks b ON a.id = b.attendance_id
       WHERE a.status = 'Absent'
       GROUP BY a.employee_id
       ORDER BY a.employee_id`
    );
    
    console.log('Employee | Absent Days | First Absent | Last Absent | Break Records');
    console.log('---------|------------|--------------|-------------|---------------');
    
    absentStats.forEach(stat => {
      const breakIssue = stat.break_records > 0 ? ` ⚠️ ${stat.break_records}` : ' ✅ 0';
      console.log(`${stat.employee_name.substring(0, 8)} | ${stat.absent_count} | ${stat.first_absent} | ${stat.last_absent} |${breakIssue}`);
    });
    
    connection.release();
    
  } catch (error) {
    console.error('Error:', error.message);
    if (connection) connection.release();
  }
}

checkBreakLogic();
