const axios = require('axios');

// Configuration
const API_BASE_URL = 'http://localhost:5000/api/v1';
const DB_HOST = 'localhost';
const DB_USER = 'root';
const DB_NAME = 'Digious_CRM_DataBase';

const mysql = require('mysql2/promise');

// Helper to calculate attendance values
function calculateAttendance(checkInTime, checkOutTime, totalBreakMinutes) {
  const [inH, inM] = checkInTime.split(':').map(Number);
  const [outH, outM] = checkOutTime.split(':').map(Number);
  
  const inTotalMin = inH * 60 + inM;
  const outTotalMin = outH * 60 + outM;
  
  // Night shift logic
  let grossWorkingMinutes = 0;
  let lateByMinutes = 0;
  let onTime = 1;
  let status = 'Present';
  
  // Check for late arrival (after 22:15)
  const gracePeriodEnd = 22 * 60 + 15; // 1335 minutes
  const shiftStart = 21 * 60; // 1260 minutes
  
  if (inTotalMin > gracePeriodEnd) {
    lateByMinutes = inTotalMin - gracePeriodEnd;
    onTime = 0;
    status = 'Late';
  } else if (inTotalMin >= shiftStart && inTotalMin <= gracePeriodEnd) {
    onTime = 1;
    status = 'Present';
  }
  
  // Calculate working time
  if (inTotalMin >= shiftStart) {
    // Check-in after 21:00 (evening)
    if (outTotalMin < inTotalMin) {
      // Check-out time is smaller than check-in = crosses midnight (next day)
      const minUntilMidnight = (24 * 60) - inTotalMin;
      const minAfterMidnight = outTotalMin;
      grossWorkingMinutes = minUntilMidnight + minAfterMidnight;
    } else {
      // Check-out time is same or after check-in = same day
      grossWorkingMinutes = Math.max(0, outTotalMin - inTotalMin);
    }
  } else if (inTotalMin <= 6 * 60) {
    // Check-in in early morning (00:00-06:00)
    if (outTotalMin > inTotalMin) {
      // Same day checkout
      grossWorkingMinutes = outTotalMin - inTotalMin;
    } else {
      // Checkout next day (crosses midnight)
      const minUntilMidnight = (24 * 60) - inTotalMin;
      const minAfterMidnight = outTotalMin;
      grossWorkingMinutes = minUntilMidnight + minAfterMidnight;
    }
  } else {
    // Check-in outside shift hours (6:00-21:00) - invalid time
    grossWorkingMinutes = 0;
  }
  
  const netWorkingMinutes = Math.max(0, grossWorkingMinutes - totalBreakMinutes);
  
  // Calculate overtime
  let overtimeMinutes = 0;
  let overtimeHours = '0.00';
  
  if (outH >= 6 && netWorkingMinutes > 540) {
    overtimeMinutes = netWorkingMinutes - 540;
    overtimeHours = (overtimeMinutes / 60).toFixed(2);
  }
  
  return {
    lateByMinutes,
    onTime,
    status,
    grossWorkingMinutes,
    netWorkingMinutes,
    overtimeMinutes,
    overtimeHours
  };
}

async function fixDatabaseRecords() {
  let connection;
  
  try {
    console.log('🔗 Connecting to database...');
    connection = await mysql.createConnection({
      host: DB_HOST,
      user: DB_USER,
      database: DB_NAME
    });
    console.log('✅ Connected to database');

    // Get all attendance records for employee 2
    console.log('\n📊 Fetching attendance records for employee 2...');
    const [records] = await connection.query(
      `SELECT id, check_in_time, check_out_time, total_break_duration_minutes 
       FROM Employee_Attendance 
       WHERE employee_id = 2 AND check_out_time IS NOT NULL
       ORDER BY id ASC`
    );

    console.log(`Found ${records.length} records to fix\n`);

    for (const record of records) {
      const calculated = calculateAttendance(
        record.check_in_time,
        record.check_out_time,
        record.total_break_duration_minutes || 0
      );

      console.log(`📅 Record ID ${record.id}:`);
      console.log(`   Check-in: ${record.check_in_time}, Check-out: ${record.check_out_time}`);
      console.log(`   Calculated: Late=${calculated.lateByMinutes}min, Gross=${calculated.grossWorkingMinutes}min, OT=${calculated.overtimeHours}h`);

      // Update the record
      await connection.query(
        `UPDATE Employee_Attendance 
         SET late_by_minutes = ?,
             on_time = ?,
             status = ?,
             gross_working_time_minutes = ?,
             net_working_time_minutes = ?,
             overtime_minutes = ?,
             overtime_hours = ?
         WHERE id = ?`,
        [
          calculated.lateByMinutes,
          calculated.onTime,
          calculated.status,
          calculated.grossWorkingMinutes,
          calculated.netWorkingMinutes,
          calculated.overtimeMinutes,
          calculated.overtimeHours,
          record.id
        ]
      );

      console.log(`   ✅ Updated\n`);
    }

    console.log('✅ All records fixed!');

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

// Run the fix
fixDatabaseRecords();
