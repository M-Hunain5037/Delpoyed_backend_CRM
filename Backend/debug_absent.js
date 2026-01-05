const pool = require('./config/database');

async function debugAbsent() {
  let connection;
  try {
    connection = await pool.getConnection();
    
    const startDate = new Date('2025-11-01');
    const today = new Date('2026-01-02');
    
    const [existingDates] = await connection.query(
      `SELECT DISTINCT attendance_date FROM Employee_Attendance 
       WHERE employee_id = 1 AND attendance_date >= ? AND attendance_date <= ?`,
      [startDate.toISOString().split('T')[0], today.toISOString().split('T')[0]]
    );
    
    console.log('🔍 Existing dates count:', existingDates.length);
    console.log('📅 Sample existing dates:');
    existingDates.slice(0, 10).forEach(row => {
      const dateStr = row.attendance_date.toISOString().split('T')[0];
      console.log(`   ${dateStr} (${typeof dateStr})`);
    });
    
    // Check for 2025-11-05
    const target = '2025-11-05';
    const found = existingDates.find(row => {
      const dateStr = row.attendance_date.toISOString().split('T')[0];
      return dateStr === target;
    });
    
    console.log(`\n🔎 Looking for ${target}: ${found ? '✓ FOUND' : '✗ NOT FOUND'}`);
    
    connection.release();
  } catch (error) {
    console.error('Error:', error);
  }
}

debugAbsent();
