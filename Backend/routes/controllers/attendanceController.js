const pool = require('../../config/database');

// ============================================================
// HELPER FUNCTION: Get local date string (YYYY-MM-DD) from Date object
// ============================================================
const getLocalDateString = (date) => {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
};

// ============================================================
// HELPER FUNCTION: Calculate working hours for any check-in/out
// ============================================================
const calculateWorkingHours = (checkInTime, checkOutTime, breakMinutes = 0) => {
  try {
    if (!checkInTime || !checkOutTime) {
      return { gross: 0, net: 0, overtime: 0, overtimeHours: '0.00' };
    }

    const [checkInHour, checkInMin] = checkInTime.split(':').map(Number);
    const [checkOutHour, checkOutMin] = checkOutTime.split(':').map(Number);
    
    const checkInTotalMinutes = checkInHour * 60 + checkInMin;
    const checkOutTotalMinutes = checkOutHour * 60 + checkOutMin;
    
    let grossWorkingMinutes = 0;
    const isNightShift = checkInTotalMinutes >= 21 * 60;
    
    if (isNightShift) {
      const timeDifferenceMinutes = checkOutTotalMinutes - checkInTotalMinutes;
      
      if (timeDifferenceMinutes >= 0) {
        grossWorkingMinutes = timeDifferenceMinutes;
      } else if (checkOutTotalMinutes <= 6 * 60) {
        const minutesUntilMidnight = (24 * 60) - checkInTotalMinutes;
        const minutesAfterMidnight = checkOutTotalMinutes;
        grossWorkingMinutes = minutesUntilMidnight + minutesAfterMidnight;
      } else {
        const minutesUntilMidnight = (24 * 60) - checkInTotalMinutes;
        const minutesAfterMidnight = checkOutTotalMinutes;
        grossWorkingMinutes = minutesUntilMidnight + minutesAfterMidnight;
      }
    } else {
      grossWorkingMinutes = Math.max(0, checkOutTotalMinutes - checkInTotalMinutes);
    }

    const netWorkingMinutes = Math.max(0, grossWorkingMinutes - breakMinutes);
    const expectedWorkingMinutes = 540;
    let overtimeMinutes = 0;
    let overtimeHours = '0.00';

    if (netWorkingMinutes > expectedWorkingMinutes) {
      overtimeMinutes = netWorkingMinutes - expectedWorkingMinutes;
      overtimeHours = (overtimeMinutes / 60).toFixed(2);
    }

    return {
      gross: Math.max(0, grossWorkingMinutes),
      net: netWorkingMinutes,
      overtime: overtimeMinutes,
      overtimeHours: overtimeHours
    };
  } catch (error) {
    console.error('Error in calculateWorkingHours:', error);
    return { gross: 0, net: 0, overtime: 0, overtimeHours: '0.00' };
  }
};

// ============================================================
// HELPER FUNCTION: Validate attendance record has working hours
// ============================================================
const validateAndFixWorkingHours = async (connection, attendanceId, checkInTime, checkOutTime, breakMinutes, status) => {
  try {
    const [record] = await connection.query(
      'SELECT gross_working_time_minutes FROM Employee_Attendance WHERE id = ?',
      [attendanceId]
    );

    if (record.length === 0) return;

    // If missing or zero working hours but has check-in/out, recalculate
    if ((record[0].gross_working_time_minutes === 0 || record[0].gross_working_time_minutes === null) 
        && checkInTime && checkOutTime && (status === 'Present' || status === 'Late')) {
      
      const workingHours = calculateWorkingHours(checkInTime, checkOutTime, breakMinutes);
      
      await connection.query(
        `UPDATE Employee_Attendance 
         SET gross_working_time_minutes = ?,
             net_working_time_minutes = ?,
             overtime_minutes = ?,
             overtime_hours = ?
         WHERE id = ?`,
        [workingHours.gross, workingHours.net, workingHours.overtime, workingHours.overtimeHours, attendanceId]
      );
      
      console.log(`✅ Fixed missing working hours for attendance ID ${attendanceId}: ${workingHours.gross}min gross, ${workingHours.net}min net`);
    }
  } catch (error) {
    console.error('Error validating working hours:', error);
  }
};

// Record Check In

exports.checkIn = async (req, res) => {
  let connection;
  try {
    // Extract from both JWT (auth) and request body for flexibility
    // But prefer JWT employeeId for consistency with employee_onboarding.id
    const jwtEmployeeId = req.user?.employeeId; // From JWT token (auth middleware)
    const jwtUserId = req.user?.userId; // From JWT token (user_as_employees.id)
    const reqEmployeeId = req.body.employee_id; // From request body
    const { email, name, device_info, ip_address } = req.body;
    
    // Determine which employee_id to use
    // IMPORTANT: Employee_Attendance.employee_id has FK to employee_onboarding.id (NOT user_as_employees.id)
    // Priority: JWT employeeId (employee_onboarding.id) > request employee_id > fallback to jwtUserId
    let employee_id = jwtEmployeeId || reqEmployeeId || jwtUserId;
    
    console.log('📥 Check-in request received:');
    console.log('   - JWT employeeId (onboarding ID):', jwtEmployeeId);
    console.log('   - JWT userId (user_as_employees.id):', jwtUserId);
    console.log('   - Request employee_id:', reqEmployeeId);
    console.log('   - Using employee_id:', employee_id);
    console.log('   - email:', email);
    console.log('   - name:', name);
    console.log('   - Full body:', req.body);

    if (!employee_id || !email || !name) {
      return res.status(400).json({
        success: false,
        message: 'Employee ID, email, and name are required'
      });
    }

    const now = new Date();
    const checkInTime = now.toTimeString().split(' ')[0]; // HH:MM:SS
    const checkInHour = now.getHours(); // Local hour
    
    // Determine attendance date for night shift:
    // Night shift: 21:00 (9 PM) to 06:00 (6 AM) next day
    // If check-in is between 00:00-05:59, it belongs to the PREVIOUS day's shift
    // If check-in is between 21:00-23:59, it belongs to TODAY's shift
    let attendanceDate;
    if (checkInHour >= 0 && checkInHour < 6) {
      // Early morning (00:00-05:59) - belongs to yesterday's shift
      const yesterday = new Date(now);
      yesterday.setDate(yesterday.getDate() - 1);
      attendanceDate = getLocalDateString(yesterday);
      console.log(`📅 Early morning check-in: Using YESTERDAY's date (${attendanceDate}) for night shift`);
    } else {
      // Evening/normal hours - use today
      attendanceDate = getLocalDateString(now);
      console.log(`📅 Evening check-in: Using TODAY's date (${attendanceDate})`);
    }

    connection = await pool.getConnection();

    try {
      // Check if attendance record already exists for the calculated attendance date
      const [existingAttendance] = await connection.query(
        `SELECT id, check_in_time, check_out_time FROM Employee_Attendance WHERE employee_id = ? AND attendance_date = ?`,
        [employee_id, attendanceDate]
      );

      if (existingAttendance.length > 0) {
        // If there's an existing record with NULL check_out_time, check if we should auto-complete it
        if (existingAttendance[0].check_out_time === null) {
          // IMPORTANT FIX: Only auto-checkout if the record is 24+ hours old
          // This prevents immediate auto-checkout on same-shift re-login
          
          // Get the check-in record with created_at timestamp
          const [fullRecord] = await connection.query(
            `SELECT id, check_in_time, created_at FROM Employee_Attendance WHERE id = ?`,
            [existingAttendance[0].id]
          );
          
          if (fullRecord.length > 0) {
            const createdAt = new Date(fullRecord[0].created_at);
            const hoursSinceCheckIn = (now.getTime() - createdAt.getTime()) / (1000 * 60 * 60); // Convert ms to hours
            
            // Only auto-checkout if 24+ hours have passed
            if (hoursSinceCheckIn >= 24) {
              console.log(`🔧 STALE RECORD DETECTED (24+ hours old): Auto-completing checkout for record ID ${existingAttendance[0].id}`);
              console.log(`   Created ${hoursSinceCheckIn.toFixed(1)} hours ago - Auto-completing...`);
              
              // Auto-complete the previous checkout with current time minus 1 minute
              const autoCheckOutTime = new Date(now.getTime() - 60000).toTimeString().split(' ')[0]; // 1 minute ago
              
              const [breakResult] = await connection.query(
                `SELECT total_break_duration_minutes FROM Employee_Attendance WHERE id = ?`,
                [existingAttendance[0].id]
              );
              
              const breakMinutes = breakResult[0]?.total_break_duration_minutes || 0;
              
              // Recalculate working hours for the auto-completed record
              const oldCheckInTime = fullRecord[0].check_in_time;
              const workingHours = calculateWorkingHours(oldCheckInTime, autoCheckOutTime, breakMinutes);
              
              // Update the stale record with auto-completed checkout and working hours
              await connection.query(
                `UPDATE Employee_Attendance 
                 SET check_out_time = ?, 
                     gross_working_time_minutes = ?,
                     net_working_time_minutes = ?,
                     overtime_minutes = ?,
                     overtime_hours = ?
                 WHERE id = ?`,
                [autoCheckOutTime, workingHours.gross, workingHours.net, workingHours.overtime, workingHours.overtimeHours, existingAttendance[0].id]
              );
              
              console.log(`✅ STALE RECORD AUTO-COMPLETED: ID ${existingAttendance[0].id}, checkout time: ${autoCheckOutTime}`);
              // After auto-completing stale record, proceed to create new check-in
            } else {
              // Record is less than 24 hours old - DO NOT auto-checkout
              console.log(`⚠️ RECORD STILL OPEN (only ${hoursSinceCheckIn.toFixed(1)} hours old): Preventing duplicate check-in`);
              console.log(`   Record ID: ${existingAttendance[0].id}`);
              console.log(`   Check-in Time: ${existingAttendance[0].check_in_time}`);
              console.log(`   Status: ALREADY CHECKED IN - Please checkout first before checking in again`);
              
              connection.release();
              return res.status(409).json({
                success: false,
                message: 'You are still checked in from your previous session. Please check out first before checking in again.',
                data: {
                  recordId: existingAttendance[0].id,
                  checkInTime: existingAttendance[0].check_in_time,
                  attendanceDate: attendanceDate,
                  hoursOpen: hoursSinceCheckIn.toFixed(1),
                  action: 'Please call POST /api/v1/attendance/check-out to complete your previous session'
                }
              });
            }
          }
        } else {
          // Record has proper checkout, prevent duplicate check-in
          connection.release();
          return res.status(409).json({
            success: false,
            message: 'Already checked in today'
          });
        }
      }

    const [checkInHourVal, checkInMin, checkInSec] = checkInTime.split(':').map(Number);
    const checkInTotalMinutes = checkInHourVal * 60 + checkInMin;
      
      // Time boundaries:
      // - Shift Start: 21:00 (1260 minutes) - Evening check-in
      // - Late After: 21:15 (1275 minutes) - Grace period ends, marked as Late if AFTER 21:15
      // Business Rule: Check-in AFTER 9:15 PM (21:16 onwards) is considered LATE
      const lateAfterTime = 21 * 60 + 15; // 21:15 = 1275 minutes
      const shiftStart = 21 * 60; // 21:00 = 1260 minutes
      
      let isLate = false;
      let lateByMinutes = 0;
      let status = 'Present';
      let onTime = 1; // Default to on time
      
      // Check if check-in is within valid shift hours (21:00 onwards for same day)
      // Valid check-in times: 21:00-23:59 (evening) or 00:00-06:00 (early morning)
      const isValidShiftTime = (checkInTotalMinutes >= shiftStart) || (checkInTotalMinutes <= 6 * 60);
      
      if (!isValidShiftTime) {
        console.log(`⚠️ Invalid Check In Time: ${name} at ${checkInTime} (outside shift hours 21:00-06:00)`);
      }
      
      // Determine attendance status based on check-in time
      // Logic: Check in AFTER 21:15 (9:15 PM) = Late
      // Check in at or before 21:15 = Present (On Time)
      
      // Check for Late: If checked in AFTER 21:15 (either evening or early morning)
      if (checkInTotalMinutes > lateAfterTime && checkInTotalMinutes <= 23 * 60 + 59) {
        // Evening late: After 21:15 in evening
        isLate = true;
        lateByMinutes = checkInTotalMinutes - lateAfterTime;
        status = 'Late';
        onTime = 0;
        console.log(`⏱️ Late Check In: ${name} at ${checkInTime} (${lateByMinutes} minutes late - after 21:15 PM)`);
      } else if (checkInTotalMinutes >= 0 && checkInTotalMinutes <= 6 * 60) {
        // Early morning late (any check-in from 00:00-06:00 is considered late)
        isLate = true;
        status = 'Late';
        onTime = 0;
        // Calculate minutes late: from 21:15 (1275) to early morning time
        // For early morning: add 24 hours (1440 minutes) to make comparison work
        const earlyMorningMinutesFrom21_15 = (1440 - lateAfterTime) + checkInTotalMinutes;
        lateByMinutes = earlyMorningMinutesFrom21_15;
        console.log(`⏱️ Late Check In (Early Morning): ${name} at ${checkInTime} (${lateByMinutes} minutes late - after 21:15 PM)`);
      }
      // Check for On Time: If checked in at or before 21:15
      else if (checkInTotalMinutes >= shiftStart && checkInTotalMinutes <= lateAfterTime) {
        // On time: between 21:00 and 21:15 (inclusive)
        console.log(`✅ On Time Check In: ${name} at ${checkInTime} (between 21:00-21:15)`);
      }

      // Create new attendance record
      const [result] = await connection.query(
        `INSERT INTO Employee_Attendance 
         (employee_id, email, name, attendance_date, check_in_time, status, on_time, late_by_minutes, device_info, ip_address)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [employee_id, email, name, attendanceDate, checkInTime, status, onTime, lateByMinutes, device_info || null, ip_address || null]
      );

      console.log(`✅ Check In: ${name} (${email}) at ${checkInTime} on ${attendanceDate}`);

      res.status(201).json({
        success: true,
        message: 'Check in successful',
        isCheckedIn: true,
        data: {
          id: result.insertId,
          employee_id,
          name,
          email,
          check_in_time: checkInTime,
          attendance_date: attendanceDate,
          status,
          isLate,
          lateByMinutes,
          onTime,
          isCheckedIn: true
        }
      });
    } finally {
      if (connection) connection.release();
    }
  } catch (error) {
    console.error('❌ Check In error:', error);
    console.error('❌ Error details:', {
      message: error.message,
      code: error.code,
      sql: error.sql,
      sqlState: error.sqlState,
      errno: error.errno,
      stack: error.stack
    });
    if (connection) connection.release();
    res.status(500).json({
      success: false,
      message: 'Check in failed',
      error: error.message,
      details: {
        code: error.code,
        sqlState: error.sqlState
      }
    });
  }
};

// Record Check Out
exports.checkOut = async (req, res) => {
  let connection;
  try {
    // Extract from both JWT (auth) and request body for flexibility
    const jwtEmployeeId = req.user?.employeeId; // From JWT token (employee_onboarding.id)
    const jwtUserId = req.user?.userId; // From JWT token (user_as_employees.id)
    const reqEmployeeId = req.body.employee_id; // From request body
    
    // Determine which employee_id to use - MUST use jwtEmployeeId (employee_onboarding.id) for FK consistency
    let employee_id = jwtEmployeeId || reqEmployeeId || jwtUserId;
    
    const now = new Date();
    const currentHour = now.getHours();
    const currentMinute = now.getMinutes();
    
    console.log('📤 Check-out request received:');
    console.log('   - JWT employeeId:', jwtEmployeeId);
    console.log('   - Request employee_id:', reqEmployeeId);
    console.log('   - Using employee_id:', employee_id);
    
    if (!employee_id) {
      return res.status(400).json({
        success: false,
        message: 'Employee ID is required'
      });
    }

    connection = await pool.getConnection();

    try {
      // Work date logic for night shift:
      // The night shift runs from 21:00 (9 PM) to 06:00 (6 AM) next day
      // Get today's date
      const todayStr = now.toISOString().split('T')[0];
      
      // First, try to find an active check-in for TODAY (current calendar day)
      const [attendanceRecordToday] = await connection.query(
        `SELECT id, check_in_time, total_break_duration_minutes FROM Employee_Attendance 
         WHERE employee_id = ? AND attendance_date = ? AND check_out_time IS NULL`,
        [employee_id, todayStr]
      );

      let attendanceRecord, workDateStr;
      
      if (attendanceRecordToday.length > 0) {
        // Found active check-in for TODAY - use it
        attendanceRecord = attendanceRecordToday;
        workDateStr = todayStr;
      } else {
        // No active check-in for today, try YESTERDAY (for morning check-outs)
        const yesterdayDate = new Date(now);
        yesterdayDate.setDate(yesterdayDate.getDate() - 1);
        const yesterdayStr = yesterdayDate.toISOString().split('T')[0];
        
        const [attendanceRecordYesterday] = await connection.query(
          `SELECT id, check_in_time, total_break_duration_minutes FROM Employee_Attendance 
           WHERE employee_id = ? AND attendance_date = ? AND check_out_time IS NULL`,
          [employee_id, yesterdayStr]
        );
        
        if (attendanceRecordYesterday.length > 0) {
          // Found active check-in for YESTERDAY - use it
          attendanceRecord = attendanceRecordYesterday;
          workDateStr = yesterdayStr;
        } else {
          // No active check-in found for either today or yesterday
          connection.release();
          return res.status(404).json({
            success: false,
            message: 'No active check in found for today'
          });
        }
      }

      const checkOutTime = new Date().toTimeString().split(' ')[0];
      const attendanceId = attendanceRecord[0].id;
      const checkInTime = attendanceRecord[0].check_in_time;
      const totalBreakMinutes = attendanceRecord[0].total_break_duration_minutes || 0;

      // Calculate working times
      // For night shift: if check-in is after 21:00 and check-out is before 06:00 NEXT DAY,
      // OR if check-in is after 21:00 and checkout is later same day
      const [checkInHour, checkInMin] = checkInTime.split(':').map(Number);
      const [checkOutHour, checkOutMin] = checkOutTime.split(':').map(Number);
      
      const checkInTotalMinutes = checkInHour * 60 + checkInMin;
      const checkOutTotalMinutes = checkOutHour * 60 + checkOutMin;
      
      let grossWorkingMinutes = 0;
      
      // Determine if this is a night shift based on check-in time
      const isNightShift = checkInTotalMinutes >= 21 * 60; // 21:00 or later
      
      if (isNightShift) {
        // Night shift: check-in at 21:00+ 
        // The key insight: if we found an active check-in on workDateStr,
        // and we're checking out now on the same workDateStr,
        // then this is either a same-night quick checkout or continues to next day
        
        // Calculate time difference for same-work-date scenarios
        const timeDifferenceMinutes = checkOutTotalMinutes - checkInTotalMinutes;
        
        if (timeDifferenceMinutes >= 0) {
          // Positive time difference: checkout is after check-in on same work date
          // Examples:
          // - 21:56:49 → 21:56:58 (9 seconds, same night)
          // - 21:00:00 → 23:30:00 (2.5 hours, same night)
          grossWorkingMinutes = timeDifferenceMinutes;
          console.log(`📊 Same-Work-Date Night Shift: ${checkInTime} → ${checkOutTime} = ${grossWorkingMinutes}min (${(grossWorkingMinutes/60).toFixed(2)}h)`);
        } else if (checkOutTotalMinutes <= 6 * 60) {
          // Negative time difference BUT checkout is at or before 6 AM = next day early morning
          // Examples:
          // - Check-in 21:00:00 → Check-out 05:30:00 (next day morning)
          // - Check-in 23:30:00 → Check-out 04:00:00 (next day morning)
          // - Check-in 22:07:50 → Check-out 06:00:00 (next day morning)
          const minutesUntilMidnight = (24 * 60) - checkInTotalMinutes; // Remaining today
          const minutesAfterMidnight = checkOutTotalMinutes; // Tomorrow morning
          grossWorkingMinutes = minutesUntilMidnight + minutesAfterMidnight;
          
          console.log(`📊 Normal Night Shift: Check-in ${checkInTime} → Check-out next day ${checkOutTime}`);
          console.log(`   Remaining today: ${minutesUntilMidnight}min, Tomorrow: ${minutesAfterMidnight}min, Total: ${grossWorkingMinutes}min (${(grossWorkingMinutes/60).toFixed(2)}h)`);
        } else {
          // Checkout is after 6 AM = next day afternoon checkout after night shift
          // Examples:
          // - Check-in 21:00 (Day 1) → Check-out 15:49 (Day 2 afternoon)
          const minutesUntilMidnight = (24 * 60) - checkInTotalMinutes;
          const minutesAfterMidnight = checkOutTotalMinutes;
          grossWorkingMinutes = minutesUntilMidnight + minutesAfterMidnight;
          
          console.log(`📊 Night Shift with Next-Day Afternoon Checkout:`);
          console.log(`   Check-in: ${checkInTime} (Day 1) → Check-out: ${checkOutTime} (Day 2 afternoon)`);
          console.log(`   Minutes until midnight: ${minutesUntilMidnight}min`);
          console.log(`   Minutes after midnight: ${minutesAfterMidnight}min`);
          console.log(`   Total: ${grossWorkingMinutes}min = ${(grossWorkingMinutes/60).toFixed(1)}h`);
        }
      } else {
        // Check-in is in early morning (before 21:00)
        // Checkout should also be on same day
        grossWorkingMinutes = checkOutTotalMinutes - checkInTotalMinutes;
        console.log(`📊 Day Shift: ${checkInTime} → ${checkOutTime} = ${grossWorkingMinutes}min`);
      }
      
      // Ensure no negative values
      grossWorkingMinutes = Math.max(0, grossWorkingMinutes);
      const netWorkingMinutes = Math.max(0, grossWorkingMinutes - totalBreakMinutes);
      
      // Calculate overtime
      const expectedWorkingMinutes = 540; // 9 hours
      let overtimeMinutes = 0;
      let overtimeHours = 0;
      
      // Overtime is calculated when net working time exceeds expected time
      if (netWorkingMinutes > expectedWorkingMinutes) {
        overtimeMinutes = netWorkingMinutes - expectedWorkingMinutes;
        overtimeHours = (overtimeMinutes / 60).toFixed(2);
        console.log(`📊 Overtime calculated: ${overtimeMinutes} minutes (${overtimeHours}h)`);
      } else {
        console.log(`⏱️ No overtime - worked ${(netWorkingMinutes/60).toFixed(1)}h out of expected 9h`);
      }

      // Update attendance record
      await connection.query(
        `UPDATE Employee_Attendance 
         SET check_out_time = ?,
             gross_working_time_minutes = ?,
             net_working_time_minutes = ?,
             overtime_minutes = ?,
             overtime_hours = ?,
             updated_at = NOW()
         WHERE id = ?`,
        [checkOutTime, grossWorkingMinutes, netWorkingMinutes, overtimeMinutes, overtimeHours, attendanceId]
      );

      // Validate working hours were saved correctly
      const [updatedRecord] = await connection.query(
        'SELECT gross_working_time_minutes, net_working_time_minutes FROM Employee_Attendance WHERE id = ?',
        [attendanceId]
      );

      if (updatedRecord.length > 0 && (updatedRecord[0].gross_working_time_minutes === 0 || updatedRecord[0].gross_working_time_minutes === null)) {
        console.warn(`⚠️ WARNING: Working hours not saved for attendance ID ${attendanceId}, attempting to fix...`);
        await validateAndFixWorkingHours(connection, attendanceId, checkInTime, checkOutTime, totalBreakMinutes, 'Present');
      }

      console.log(`✅ Check Out: Employee ${employee_id} at ${checkOutTime}`);

      res.status(200).json({
        success: true,
        message: 'Check out successful',
        isCheckedIn: false,
        data: {
          id: attendanceId,
          employee_id,
          check_out_time: checkOutTime,
          gross_working_time_minutes: grossWorkingMinutes,
          net_working_time_minutes: netWorkingMinutes,
          overtime_hours: parseFloat(overtimeHours),
          attendance_date: workDateStr,
          isCheckedIn: false
        }
      });
    } finally {
      if (connection) connection.release();
    }
  } catch (error) {
    console.error('❌ Check Out error:', error);
    if (connection) connection.release();
    res.status(500).json({
      success: false,
      message: 'Check out failed',
      error: error.message
    });
  }
};

// Generate Absent Records for all employees from joining date to today
exports.generateAbsentRecords = async (req, res) => {
  let connection;
  try {
    connection = await pool.getConnection();
    
    console.log('🔄 Starting absent record generation...');
    
    // Get all active employees with their joining dates
    const [employees] = await connection.query(
      `SELECT employee_id, name, email, created_at as joining_date 
       FROM user_as_employees 
       WHERE status = 'Active'`
    );
    
    if (employees.length === 0) {
      connection.release();
      return res.status(200).json({
        success: true,
        message: 'No active employees found',
        data: { processed: 0, created: 0 }
      });
    }
    
    let totalProcessed = 0;
    let totalCreated = 0;
    
    for (const employee of employees) {
      const { employee_id, name, email, joining_date } = employee;
      
      // Calculate date range from joining to today
      const startDate = new Date(joining_date);
      const today = new Date();
      today.setHours(0, 0, 0, 0); // Reset to start of day
      
      console.log(`👤 Processing ${name} (ID: ${employee_id}) from ${startDate.toDateString()}`);
      
      // Get all existing attendance dates for this employee
      const [existingDates] = await connection.query(
        `SELECT DISTINCT DATE(attendance_date) as attendance_date FROM Employee_Attendance 
         WHERE employee_id = ? AND DATE(attendance_date) >= ? AND DATE(attendance_date) <= ?`,
        [employee_id, startDate.toISOString().split('T')[0], today.toISOString().split('T')[0]]
      );
      
      const existingDateSet = new Set(
        existingDates.map(row => {
          // Handle both DATE objects and string date values
          if (row.attendance_date instanceof Date) {
            return row.attendance_date.toISOString().split('T')[0];
          }
          return row.attendance_date;
        })
      );
      
      // Generate all dates from joining to today
      const currentDate = new Date(startDate);
      let createdForEmployee = 0;
      
      while (currentDate <= today) {
        const dateString = currentDate.toISOString().split('T')[0];
        
        // Skip weekends (optional - remove if you want to track weekend absences)
        const dayOfWeek = currentDate.getDay();
        const isWeekend = dayOfWeek === 0 || dayOfWeek === 6; // Sunday = 0, Saturday = 6
        
        // If no attendance record exists for this date and it's not weekend
        if (!existingDateSet.has(dateString) && !isWeekend) {
          // First check if record already exists
          const [existingRecord] = await connection.query(
            `SELECT id FROM Employee_Attendance WHERE employee_id = ? AND attendance_date = ?`,
            [employee_id, dateString]
          );
          
          if (existingRecord.length === 0) {
            // Record doesn't exist, create it
            await connection.query(
              `INSERT INTO Employee_Attendance 
               (employee_id, email, name, attendance_date, status, 
                total_breaks_taken, smoke_break_count, dinner_break_count, 
                washroom_break_count, prayer_break_count, smoke_break_duration_minutes, 
                dinner_break_duration_minutes, washroom_break_duration_minutes, 
                prayer_break_duration_minutes, total_break_duration_minutes, 
                gross_working_time_minutes, net_working_time_minutes, overtime_minutes, 
                overtime_hours, on_time, late_by_minutes, created_at, updated_at) 
               VALUES (?, ?, ?, ?, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.00, 0, 0, NOW(), NOW())`,
              [employee_id, email, name, dateString]
            );
            
            createdForEmployee++;
            totalCreated++;
          }
        }
        
        // Move to next day
        currentDate.setDate(currentDate.getDate() + 1);
      }
      
      console.log(`   ✅ Created ${createdForEmployee} absent records for ${name}`);
      totalProcessed++;
    }
    
    connection.release();
    
    console.log(`🎯 Absent record generation complete:`);
    console.log(`   📊 Processed ${totalProcessed} employees`);
    console.log(`   📝 Created ${totalCreated} absent records`);
    
    res.status(200).json({
      success: true,
      message: 'Absent records generated successfully',
      data: {
        processed: totalProcessed,
        created: totalCreated,
        employees: employees.map(emp => ({
          employee_id: emp.employee_id,
          name: emp.name,
          joining_date: emp.joining_date
        }))
      }
    });
    
  } catch (error) {
    console.error('❌ Generate Absent Records error:', error);
    if (connection) connection.release();
    res.status(500).json({
      success: false,
      message: 'Failed to generate absent records',
      error: error.message
    });
  }
};

// Record Break Start (saves break immediately when employee starts break)
exports.recordBreakStart = async (req, res) => {
  let connection;
  try {
    const jwtEmployeeId = req.user?.employeeId; // From JWT (employee_onboarding.id)
    const jwtUserId = req.user?.userId; // From JWT (user_as_employees.id)
    const reqEmployeeId = req.body.employee_id;
    let employee_id = jwtEmployeeId || reqEmployeeId || jwtUserId;
    
    const { break_type, break_start_time, reason } = req.body;
    
    // Calculate attendance_date using same night shift logic
    const now = new Date();
    const checkInHour = now.getHours();
    let attendanceDate;
    if (checkInHour >= 0 && checkInHour < 6) {
      // Early morning (00:00-05:59) - belongs to yesterday's shift
      const yesterday = new Date(now);
      yesterday.setDate(yesterday.getDate() - 1);
      attendanceDate = getLocalDateString(yesterday);
    } else {
      // Evening/normal hours - use today
      attendanceDate = getLocalDateString(now);
    }

    console.log('⏸️ Record break START request received:');
    console.log('   - JWT employeeId:', jwtEmployeeId);
    console.log('   - Request employee_id:', reqEmployeeId);
    console.log('   - Using employee_id:', employee_id);
    console.log('   - Break Type:', break_type);
    console.log('   - Start Time:', break_start_time);
    console.log('   - Calculated attendance_date:', attendanceDate);

    if (!employee_id || !break_type) {
      return res.status(400).json({
        success: false,
        message: 'Employee ID and break type are required'
      });
    }

    const validBreakTypes = ['Smoke', 'Dinner', 'Washroom', 'Prayer', 'Other'];
    if (!validBreakTypes.includes(break_type)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid break type'
      });
    }

    connection = await pool.getConnection();

    try {
      // Find any attendance record for this employee on that date
      const [attendanceRows] = await connection.query(
        `SELECT id, check_in_time, check_out_time, status FROM Employee_Attendance 
         WHERE employee_id = ? AND attendance_date = ? LIMIT 1`,
        [employee_id, attendanceDate]
      );

      const breakStart = break_start_time || new Date().toTimeString().split(' ')[0];

      let attendanceId;

      if (attendanceRows.length === 0) {
        // No attendance record exists -> create a Present record with check_in_time = breakStart
        const [createRes] = await connection.query(
          `INSERT INTO Employee_Attendance (employee_id, email, name, attendance_date, status, check_in_time, total_breaks_taken, total_break_duration_minutes, created_at, updated_at)
           VALUES (?, ?, ?, ?, 'Present', ?, 0, 0, NOW(), NOW())`,
          [employee_id, null, null, attendanceDate, breakStart]
        );
        attendanceId = createRes.insertId;
        console.log(`ℹ️ Created attendance record ${attendanceId} as Present because break was started without an attendance record`);
      } else {
        const a = attendanceRows[0];
        attendanceId = a.id;

        // If the record exists but shows as Absent or has no check_in_time, convert to Present
        if (a.status === 'Absent' || !a.check_in_time) {
          await connection.query(
            `UPDATE Employee_Attendance SET status = 'Present', check_in_time = COALESCE(check_in_time, ?), updated_at = NOW() WHERE id = ?`,
            [breakStart, attendanceId]
          );
          console.log(`ℹ️ Updated attendance ${attendanceId} to Present (set check_in_time to ${breakStart})`);
        }

        // If the user has already checked out, refuse to start a break
        if (a.check_out_time) {
          if (connection) connection.release();
          return res.status(400).json({ success: false, message: 'Cannot start a break after check-out' });
        }
      }

      // Insert break record with only start time (end_time will be NULL initially)
      const [breakResult] = await connection.query(
        `INSERT INTO Employee_Breaks 
         (attendance_id, employee_id, break_type, break_start_time, break_end_time, reason)
         VALUES (?, ?, ?, ?, NULL, ?)`,
        [attendanceId, employee_id, break_type, breakStart, reason || null]
      );

      console.log(`✅ Break START recorded: ${break_type} for employee ${employee_id} at ${breakStart}`);
      console.log(`   Break ID: ${breakResult.insertId}`);

      res.status(201).json({
        success: true,
        message: 'Break start recorded successfully',
        data: {
          id: breakResult.insertId,
          employee_id,
          break_type,
          break_start_time: breakStart,
          break_end_time: null,
          status: 'active'
        }
      });
    } finally {
      if (connection) connection.release();
    }
  } catch (error) {
    console.error('❌ Record Break START error:', error);
    if (connection) connection.release();
    res.status(500).json({
      success: false,
      message: 'Failed to record break start',
      error: error.message
    });
  }
};

// Record Break End (updates break with end time and duration)
exports.recordBreakEnd = async (req, res) => {
  let connection;
  try {
    const jwtEmployeeId = req.user?.employeeId; // From JWT (employee_onboarding.id)
    const jwtUserId = req.user?.userId; // From JWT (user_as_employees.id)
    const reqEmployeeId = req.body.employee_id;
    let employee_id = jwtEmployeeId || reqEmployeeId || jwtUserId;
    
    const { break_type, break_end_time, break_duration_minutes } = req.body;
    
    // Calculate attendance_date using same night shift logic
    const now = new Date();
    const checkInHour = now.getHours();
    let attendanceDate;
    if (checkInHour >= 0 && checkInHour < 6) {
      // Early morning (00:00-05:59) - belongs to yesterday's shift
      const yesterday = new Date(now);
      yesterday.setDate(yesterday.getDate() - 1);
      attendanceDate = getLocalDateString(yesterday);
    } else {
      // Evening/normal hours - use today
      attendanceDate = getLocalDateString(now);
    }

    console.log('⏸️ Record break END request received:');
    console.log('   - JWT employeeId:', jwtEmployeeId);
    console.log('   - Request employee_id:', reqEmployeeId);
    console.log('   - Using employee_id:', employee_id);
    console.log('   - Break Type:', break_type);
    console.log('   - End Time:', break_end_time);
    console.log('   - Duration:', break_duration_minutes);
    console.log('   - Calculated attendance_date:', attendanceDate);

    if (!employee_id || !break_type) {
      return res.status(400).json({
        success: false,
        message: 'Employee ID and break type are required'
      });
    }

    const validBreakTypes = ['Smoke', 'Dinner', 'Washroom', 'Prayer', 'Other'];
    if (!validBreakTypes.includes(break_type)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid break type'
      });
    }

    connection = await pool.getConnection();

    try {
      // Get today's attendance record using calculated attendance date
      const [attendanceRecord] = await connection.query(
        `SELECT id FROM Employee_Attendance 
         WHERE employee_id = ? AND attendance_date = ? AND check_out_time IS NULL`,
        [employee_id, attendanceDate]
      );

      if (attendanceRecord.length === 0) {
        if (connection) connection.release();
        return res.status(404).json({
          success: false,
          message: 'No active check in found for today'
        });
      }

      const attendanceId = attendanceRecord[0].id;
      const breakEnd = break_end_time || new Date().toTimeString().split(' ')[0];

      // Find the most recent break record for this type that doesn't have an end time
      const [breakRecord] = await connection.query(
        `SELECT id FROM Employee_Breaks 
         WHERE attendance_id = ? AND employee_id = ? AND break_type = ? AND break_end_time IS NULL
         ORDER BY created_at DESC LIMIT 1`,
        [attendanceId, employee_id, break_type]
      );

      if (breakRecord.length === 0) {
        if (connection) connection.release();
        return res.status(404).json({
          success: false,
          message: 'No active break found for this type'
        });
      }

      const breakId = breakRecord[0].id;
      const breakDurationMinutes = Math.floor(break_duration_minutes || 0);

      // Update break record with end time and duration
      await connection.query(
        `UPDATE Employee_Breaks 
         SET break_end_time = ?, break_duration_minutes = ?, updated_at = NOW()
         WHERE id = ?`,
        [breakEnd, breakDurationMinutes, breakId]
      );

      // Update attendance record with break statistics
      const fieldMap = {
        'Smoke': 'smoke_break_count',
        'Dinner': 'dinner_break_count',
        'Washroom': 'washroom_break_count',
        'Prayer': 'prayer_break_count',
        'Other': 'smoke_break_count'
      };

      const breakCountField = fieldMap[break_type];
      
      let updateQueryParts;
      let queryParams;

      if (['Smoke', 'Dinner', 'Washroom', 'Prayer'].includes(break_type)) {
        const breakDurationField = break_type.toLowerCase() + '_break_duration_minutes';
        
        updateQueryParts = [
          'UPDATE Employee_Attendance',
          'SET total_breaks_taken = total_breaks_taken + 1,',
          `    ${breakCountField} = ${breakCountField} + 1,`,
          `    ${breakDurationField} = ${breakDurationField} + ?,`,
          '    total_break_duration_minutes = total_break_duration_minutes + ?,',
          '    updated_at = NOW()',
          'WHERE id = ?'
        ];
        queryParams = [breakDurationMinutes, breakDurationMinutes, attendanceId];
      } else {
        updateQueryParts = [
          'UPDATE Employee_Attendance',
          'SET total_breaks_taken = total_breaks_taken + 1,',
          '    total_break_duration_minutes = total_break_duration_minutes + ?,',
          '    updated_at = NOW()',
          'WHERE id = ?'
        ];
        queryParams = [breakDurationMinutes, attendanceId];
      }
      
      const updateQuery = updateQueryParts.join('\n');
      await connection.query(updateQuery, queryParams);

      console.log(`✅ Break END recorded: ${break_type} for employee ${employee_id} (${breakDurationMinutes} min)`);

      res.status(200).json({
        success: true,
        message: 'Break end recorded successfully',
        data: {
          id: breakId,
          employee_id,
          break_type,
          break_end_time: breakEnd,
          break_duration_minutes: breakDurationMinutes,
          status: 'completed'
        }
      });
    } finally {
      if (connection) connection.release();
    }
  } catch (error) {
    console.error('❌ Record Break END error:', error);
    if (connection) connection.release();
    res.status(500).json({
      success: false,
      message: 'Failed to record break end',
      error: error.message
    });
  }
};

// Auto-save break progress (updates current duration every 30 seconds)
exports.recordBreakProgress = async (req, res) => {
  let connection;
  try {
    const jwtEmployeeId = req.user?.employeeId; // From JWT (employee_onboarding.id)
    const jwtUserId = req.user?.userId; // From JWT (user_as_employees.id)
    const reqEmployeeId = req.body.employee_id;
    let employee_id = jwtEmployeeId || reqEmployeeId || jwtUserId;
    
    const { break_type, current_time, current_duration_minutes } = req.body;
    
    // Calculate attendance_date using same night shift logic
    const now = new Date();
    const checkInHour = now.getHours();
    let attendanceDate;
    if (checkInHour >= 0 && checkInHour < 6) {
      // Early morning (00:00-05:59) - belongs to yesterday's shift
      const yesterday = new Date(now);
      yesterday.setDate(yesterday.getDate() - 1);
      attendanceDate = getLocalDateString(yesterday);
    } else {
      // Evening/normal hours - use today
      attendanceDate = getLocalDateString(now);
    }

    console.log('⏸️ Auto-save break progress request received:');
    console.log('   - Break Type:', break_type);
    console.log('   - Current Duration:', current_duration_minutes, 'minutes');

    if (!employee_id || !break_type) {
      return res.status(400).json({
        success: false,
        message: 'Employee ID and break type are required'
      });
    }

    const validBreakTypes = ['Smoke', 'Dinner', 'Washroom', 'Prayer', 'Other'];
    if (!validBreakTypes.includes(break_type)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid break type'
      });
    }

    connection = await pool.getConnection();

    try {
      // Get today's attendance record using calculated attendance date
      const [attendanceRecord] = await connection.query(
        `SELECT id FROM Employee_Attendance 
         WHERE employee_id = ? AND attendance_date = ? AND check_out_time IS NULL`,
        [employee_id, attendanceDate]
      );

      if (attendanceRecord.length === 0) {
        if (connection) connection.release();
        return res.status(404).json({
          success: false,
          message: 'No active check in found for today'
        });
      }

      const attendanceId = attendanceRecord[0].id;

      // Find the most recent break record for this type that doesn't have an end time
      const [breakRecord] = await connection.query(
        `SELECT id FROM Employee_Breaks 
         WHERE attendance_id = ? AND employee_id = ? AND break_type = ? AND break_end_time IS NULL
         ORDER BY created_at DESC LIMIT 1`,
        [attendanceId, employee_id, break_type]
      );

      if (breakRecord.length === 0) {
        if (connection) connection.release();
        return res.status(404).json({
          success: false,
          message: 'No active break found for this type'
        });
      }

      const breakId = breakRecord[0].id;

      // Update break record with current duration (while still active)
      // This is an optional field to track progress in real-time
      // Note: This updates the record but doesn't set end_time yet
      await connection.query(
        `UPDATE Employee_Breaks 
         SET break_duration_minutes = ?, updated_at = NOW()
         WHERE id = ? AND break_end_time IS NULL`,
        [Math.floor(current_duration_minutes), breakId]
      );

      console.log(`✅ Break progress auto-saved: ${break_type} - Duration: ${current_duration_minutes}m`);

      res.status(200).json({
        success: true,
        message: 'Break progress saved successfully',
        data: {
          id: breakId,
          employee_id,
          break_type,
          current_duration_minutes: Math.floor(current_duration_minutes),
          status: 'in_progress'
        }
      });
    } finally {
      if (connection) connection.release();
    }
  } catch (error) {
    console.error('❌ Record Break Progress error:', error);
    if (connection) connection.release();
    res.status(500).json({
      success: false,
      message: 'Failed to record break progress',
      error: error.message
    });
  }
};

// Get ongoing breaks for today (used to restore breaks on page reload)
exports.getOngoingBreaks = async (req, res) => {
  let connection;
  try {
    const jwtEmployeeId = req.user?.employeeId; // From JWT (employee_onboarding.id)
    const jwtUserId = req.user?.userId; // From JWT (user_as_employees.id)
    const reqEmployeeId = req.params.employee_id;
    let employee_id = jwtEmployeeId || reqEmployeeId || jwtUserId;
    
    const now = new Date();
    const checkInHour = now.getHours();
    
    // Calculate attendance_date using same night shift logic as check-in
    let attendanceDate;
    if (checkInHour >= 0 && checkInHour < 6) {
      // Early morning (00:00-05:59) - belongs to yesterday's shift
      const yesterday = new Date(now);
      yesterday.setDate(yesterday.getDate() - 1);
      attendanceDate = getLocalDateString(yesterday);
    } else {
      // Evening/normal hours - use today
      attendanceDate = getLocalDateString(now);
    }

    console.log('📋 Get ongoing breaks request received:');
    console.log('   - JWT employeeId:', jwtEmployeeId);
    console.log('   - Params employee_id:', reqEmployeeId);
    console.log('   - Using employee_id:', employee_id);
    console.log('   - Calculated attendance_date:', attendanceDate);

    if (!employee_id) {
      return res.status(400).json({
        success: false,
        message: 'Employee ID is required'
      });
    }

    connection = await pool.getConnection();

    try {
      // Get today's attendance record using calculated attendance date
      const [attendanceRecord] = await connection.query(
        `SELECT id FROM Employee_Attendance 
         WHERE employee_id = ? AND attendance_date = ? AND check_out_time IS NULL`,
        [employee_id, attendanceDate]
      );

      if (attendanceRecord.length === 0) {
        if (connection) connection.release();
        return res.status(200).json({
          success: true,
          message: 'No active check in found',
          data: []
        });
      }

      const attendanceId = attendanceRecord[0].id;

      // Find all ongoing breaks (break_end_time IS NULL) for today
      const [ongoingBreaks] = await connection.query(
        `SELECT id, break_type, break_start_time, break_duration_minutes, created_at
         FROM Employee_Breaks 
         WHERE attendance_id = ? AND employee_id = ? AND break_end_time IS NULL
         ORDER BY created_at DESC`,
        [attendanceId, employee_id]
      );

      console.log(`✅ Found ${ongoingBreaks.length} ongoing breaks for employee ${employee_id}`);

      // Compute real-time duration for each ongoing break using the attendance date
      const now = new Date();
      const result = ongoingBreaks.map(brk => {
        // Construct break start using the calculated attendanceDate.
        // Note: For early-morning times (00:00 - 05:59), the actual datetime is on the next calendar day
        // even though attendance_date represents the previous shift day. Handle that here.
        const hourPart = parseInt(String(brk.break_start_time || '00:00:00').split(':')[0], 10) || 0;
        let breakDateObj = new Date(`${attendanceDate}T00:00:00`);
        if (hourPart >= 0 && hourPart < 6) {
          // move to next calendar day for the real timestamp
          breakDateObj.setDate(breakDateObj.getDate() + 1);
        }
        const pad = (n) => String(n).padStart(2, '0');
        const dateForBreak = `${breakDateObj.getFullYear()}-${pad(breakDateObj.getMonth() + 1)}-${pad(breakDateObj.getDate())}`;
        const breakStart = new Date(`${dateForBreak}T${brk.break_start_time}`);
        const durationNow = Math.floor((now - breakStart) / (1000 * 60));

        // Prefer the real-time calculated duration if it differs significantly from stored value
        const storedDuration = brk.break_duration_minutes || 0;
        const chosenDuration = (Math.abs(storedDuration - durationNow) > 10) ? durationNow : Math.max(storedDuration, durationNow);

        return {
          id: brk.id,
          break_type: brk.break_type,
          break_start_time: brk.break_start_time,
          break_duration_minutes: chosenDuration,
          created_at: brk.created_at,
          status: 'ongoing',
          attendance_date: attendanceDate
        };
      });

      res.status(200).json({
        success: true,
        message: 'Ongoing breaks retrieved successfully',
        data: result
      });
    } finally {
      if (connection) connection.release();
    }
  } catch (error) {
    console.error('❌ Get Ongoing Breaks error:', error);
    if (connection) connection.release();
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve ongoing breaks',
      error: error.message
    });
  }
};

// Get today's completed breaks for an employee
exports.getTodayBreaks = async (req, res) => {
  let connection;
  try {
    const jwtEmployeeId = req.user?.employeeId; // From JWT (employee_onboarding.id)
    const jwtUserId = req.user?.userId; // From JWT (user_as_employees.id)
    const reqEmployeeId = req.params.employee_id;
    let employee_id = jwtEmployeeId || reqEmployeeId || jwtUserId;
    
    const now = new Date();
    const checkInHour = now.getHours();
    
    // Calculate attendance_date using same night shift logic as check-in
    let attendanceDate;
    if (checkInHour >= 0 && checkInHour < 6) {
      // Early morning (00:00-05:59) - belongs to yesterday's shift
      const yesterday = new Date(now);
      yesterday.setDate(yesterday.getDate() - 1);
      attendanceDate = getLocalDateString(yesterday);
    } else {
      // Evening/normal hours - use today
      attendanceDate = getLocalDateString(now);
    }

    console.log('📋 Get today\'s breaks request received:');
    console.log('   - JWT employeeId:', jwtEmployeeId);
    console.log('   - Params employee_id:', reqEmployeeId);
    console.log('   - Using employee_id:', employee_id);
    console.log('   - Calculated attendance_date:', attendanceDate);

    if (!employee_id) {
      return res.status(400).json({
        success: false,
        message: 'Employee ID is required'
      });
    }

    connection = await pool.getConnection();

    try {
      // Convert user_as_employees.id to employee_onboarding.id if needed
      let finalEmployeeId = employee_id;
      if (!jwtEmployeeId && reqEmployeeId) {
        // If employee_id came from params (could be user_as_employees.id), convert it
        // First check if it's already an onboarding.id
        const [directMatch] = await connection.query(
          `SELECT id FROM employee_onboarding WHERE id = ?`,
          [reqEmployeeId]
        );
        
        if (directMatch.length === 0) {
          // Not a direct match, try to find via user_as_employees
          const [userMapping] = await connection.query(
            `SELECT employee_id FROM user_as_employees WHERE id = ?`,
            [reqEmployeeId]
          );
          
          if (userMapping.length > 0) {
            finalEmployeeId = userMapping[0].employee_id;
            console.log(`🔄 Converted user_as_employees.id ${reqEmployeeId} to employee_onboarding.id ${finalEmployeeId}`);
          }
        }
      }
      
      // Get today's attendance record using calculated attendance date
      const [attendanceRecord] = await connection.query(
        `SELECT id FROM Employee_Attendance 
         WHERE employee_id = ? AND attendance_date = ?`,
        [finalEmployeeId, attendanceDate]
      );

      if (attendanceRecord.length === 0) {
        return res.status(200).json({
          success: true,
          message: 'No attendance record for today',
          data: []
        });
      }

      const attendanceId = attendanceRecord[0].id;

      // Get all breaks for today (both completed and ongoing)
      const [todayBreaks] = await connection.query(
        `SELECT id, break_type, break_start_time, break_end_time, break_duration_minutes, created_at
         FROM Employee_Breaks 
         WHERE attendance_id = ? AND employee_id = ?
         ORDER BY created_at ASC`,
        [attendanceId, finalEmployeeId]
      );

      console.log(`✅ Found ${todayBreaks.length} breaks for employee ${finalEmployeeId} on ${attendanceDate}`);

      res.status(200).json({
        success: true,
        message: 'Today\'s breaks retrieved successfully',
        data: todayBreaks.map(brk => ({
          id: brk.id,
          break_type: brk.break_type,
          break_start_time: brk.break_start_time,
          break_end_time: brk.break_end_time,
          break_duration_minutes: brk.break_duration_minutes || 0,
          created_at: brk.created_at,
          status: brk.break_end_time ? 'completed' : 'ongoing'
        }))
      });
    } finally {
      if (connection) connection.release();
    }
  } catch (error) {
    console.error('❌ Get Today\'s Breaks error:', error);
    if (connection) connection.release();
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve today\'s breaks',
      error: error.message
    });
  }
};

// Record Break (Legacy - for backward compatibility)
exports.recordBreak = async (req, res) => {
  let connection;
  try {
    // Extract from both JWT (auth) and request body for flexibility
    const jwtEmployeeId = req.user?.employeeId; // From JWT (employee_onboarding.id)
    const jwtUserId = req.user?.userId; // From JWT token (user_as_employees.id)
    const reqEmployeeId = req.body.employee_id; // From request body
    
    // Determine which employee_id to use - MUST use jwtEmployeeId for FK consistency
    let employee_id = jwtEmployeeId || reqEmployeeId || jwtUserId;
    
    const { break_type, break_start_time, break_end_time, break_duration_minutes, reason } = req.body;
    
    // Calculate attendance_date using same night shift logic
    const now = new Date();
    const checkInHour = now.getHours();
    let attendanceDate;
    if (checkInHour >= 0 && checkInHour < 6) {
      // Early morning (00:00-05:59) - belongs to yesterday's shift
      const yesterday = new Date(now);
      yesterday.setDate(yesterday.getDate() - 1);
      attendanceDate = getLocalDateString(yesterday);
    } else {
      // Evening/normal hours - use today
      attendanceDate = getLocalDateString(now);
    }

    console.log('⏸️ Record break request received:');
    console.log('   - JWT employeeId:', jwtEmployeeId);
    console.log('   - Request employee_id:', reqEmployeeId);
    console.log('   - Using employee_id:', employee_id);

    if (!employee_id || !break_type) {
      return res.status(400).json({
        success: false,
        message: 'Employee ID and break type are required'
      });
    }

    const validBreakTypes = ['Smoke', 'Dinner', 'Washroom', 'Prayer', 'Other'];
    if (!validBreakTypes.includes(break_type)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid break type'
      });
    }

    connection = await pool.getConnection();

    try {
      // Get today's attendance record using calculated attendance date
      const [attendanceRecord] = await connection.query(
        `SELECT id, check_in_time FROM Employee_Attendance 
         WHERE employee_id = ? AND attendance_date = ? AND check_out_time IS NULL`,
        [employee_id, attendanceDate]
      );

      if (attendanceRecord.length === 0) {
        if (connection) connection.release();
        return res.status(404).json({
          success: false,
          message: 'No active check in found for today'
        });
      }

      const attendanceId = attendanceRecord[0].id;
      const breakStart = break_start_time || new Date().toTimeString().split(' ')[0];
      const breakEnd = break_end_time || new Date().toTimeString().split(' ')[0];

      // Use provided duration or calculate it
      let breakDurationMinutes = break_duration_minutes;
      
      if (!breakDurationMinutes || breakDurationMinutes < 0) {
        // Calculate break duration as fallback
        const breakStartDate = new Date(`${today}T${breakStart}`);
        const breakEndDate = new Date(`${today}T${breakEnd}`);
        breakDurationMinutes = Math.floor((breakEndDate - breakStartDate) / 60000);
      }
      
      console.log('💾 Recording break - Duration sent by frontend:', break_duration_minutes, 'Calculated:', breakDurationMinutes);

      // Insert break record
      const [breakResult] = await connection.query(
        `INSERT INTO Employee_Breaks 
         (attendance_id, employee_id, break_type, break_start_time, break_end_time, break_duration_minutes, reason)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [attendanceId, employee_id, break_type, breakStart, breakEnd, breakDurationMinutes, reason || null]
      );

      // Update attendance record with break count
      const fieldMap = {
        'Smoke': 'smoke_break_count',
        'Dinner': 'dinner_break_count',
        'Washroom': 'washroom_break_count',
        'Prayer': 'prayer_break_count',
        'Other': 'smoke_break_count'  // Default to smoke for Other types
      };

      const breakCountField = fieldMap[break_type];
      
      // Only update specific break duration field if it exists for this type
      let updateQueryParts;
      let queryParams;

      if (['Smoke', 'Dinner', 'Washroom', 'Prayer'].includes(break_type)) {
        const breakDurationField = break_type.toLowerCase() + '_break_duration_minutes';
        
        updateQueryParts = [
          'UPDATE Employee_Attendance',
          'SET total_breaks_taken = total_breaks_taken + 1,',
          `    ${breakCountField} = ${breakCountField} + 1,`,
          `    ${breakDurationField} = ${breakDurationField} + ?,`,
          '    total_break_duration_minutes = total_break_duration_minutes + ?,',
          '    updated_at = NOW()',
          'WHERE id = ?'
        ];
        queryParams = [breakDurationMinutes, breakDurationMinutes, attendanceId];
      } else {
        // For 'Other' type, only update total breaks and total duration
        updateQueryParts = [
          'UPDATE Employee_Attendance',
          'SET total_breaks_taken = total_breaks_taken + 1,',
          '    total_break_duration_minutes = total_break_duration_minutes + ?,',
          '    updated_at = NOW()',
          'WHERE id = ?'
        ];
        queryParams = [breakDurationMinutes, attendanceId];
      }
      
      const updateQuery = updateQueryParts.join('\n');
      
      console.log('🔍 Update Query:', updateQuery);
      console.log('📊 Parameters:', queryParams);
      
      await connection.query(updateQuery, queryParams);

      console.log(`✅ Break Recorded: ${break_type} for employee ${employee_id} (${breakDurationMinutes} min)`);

      res.status(201).json({
        success: true,
        message: 'Break recorded successfully',
        data: {
          id: breakResult.insertId,
          employee_id,
          break_type,
          break_start_time: breakStart,
          break_end_time: breakEnd,
          break_duration_minutes: breakDurationMinutes
        }
      });
    } finally {
      if (connection) connection.release();
    }
  } catch (error) {
    console.error('❌ Record Break error:', error);
    if (connection) connection.release();
    res.status(500).json({
      success: false,
      message: 'Failed to record break',
      error: error.message
    });
  }
};

// Get Today's Attendance
exports.getTodayAttendance = async (req, res) => {
  try {
    const { employee_id } = req.params;
    const now = new Date();
    const currentHour = now.getHours();
    
    // For night shift: if current time is 00:00-05:59, check YESTERDAY's attendance
    // Because night shift runs from 21:00 Day1 to 06:00 Day2
    let searchDate;
    if (currentHour >= 0 && currentHour < 6) {
      // Early morning - look for yesterday's shift
      const yesterday = new Date(now);
      yesterday.setDate(yesterday.getDate() - 1);
      searchDate = getLocalDateString(yesterday);
      console.log(`📅 getTodayAttendance [EARLY MORNING] - Searching YESTERDAY's date: ${searchDate}`);
    } else {
      // Normal hours - look for today's shift
      searchDate = getLocalDateString(now);
      console.log(`📅 getTodayAttendance [NORMAL HOURS] - Searching TODAY's date: ${searchDate}`);
    }

    console.log(`📅 getTodayAttendance - Looking for employee_id: ${employee_id}, date: ${searchDate}`);

    const connection = await pool.getConnection();

    try {
      // Convert user_as_employees.id to employee_onboarding.id if needed
      let finalEmployeeId = employee_id;
      const [employeeMapping] = await connection.query(
        `SELECT eo.id as onboarding_id FROM employee_onboarding eo
         WHERE eo.id = ?`,
        [employee_id]
      );
      
      // If we have a direct match, use it. Otherwise try to look up by user_as_employees
      if (employeeMapping.length === 0) {
        // Try to find via user_as_employees table (convert user_as_employees.id to onboarding id)
        const [userMapping] = await connection.query(
          `SELECT uae.employee_id FROM user_as_employees uae WHERE uae.id = ?`,
          [employee_id]
        );
        
        if (userMapping.length > 0) {
          finalEmployeeId = userMapping[0].employee_id;
          console.log(`🔄 Converted user_as_employees.id ${employee_id} to employee_onboarding.id ${finalEmployeeId}`);
        }
      }
      
      const [attendance] = await connection.query(
        `SELECT * FROM Employee_Attendance WHERE employee_id = ? AND attendance_date = ?`,
        [finalEmployeeId, searchDate]
      );

      if (attendance.length === 0) {
        console.log(`⚠️ No attendance record found for finalEmployeeId: ${finalEmployeeId} on date: ${searchDate}`);
        
        // Try to find if employee exists at all
        const [employeeCheck] = await connection.query(
          `SELECT id, employee_id as emp_id, name, email FROM user_as_employees WHERE id = ?`,
          [employee_id]
        );
        
        if (employeeCheck.length === 0) {
          console.log(`❌ Employee not found in user_as_employees with id: ${employee_id}`);
        } else {
          console.log(`ℹ️ Employee found in user_as_employees: ${employeeCheck[0].emp_id} (${employeeCheck[0].name})`);
        }
        
        return res.status(404).json({
          success: false,
          message: 'No attendance record for today',
          employee_id: finalEmployeeId
        });
      }

      const record = attendance[0];
      const [breaks] = await connection.query(
        `SELECT * FROM Employee_Breaks WHERE attendance_id = ? ORDER BY break_start_time ASC`,
        [record.id]
      );

      // Format attendance_date to preserve local date
      const d = record.attendance_date instanceof Date ? record.attendance_date : new Date(record.attendance_date);
      const localDateStr = getLocalDateString(d);
      
      // Determine if user is currently checked in (check_out_time is null)
      const isCheckedIn = record.check_out_time === null;

      res.status(200).json({
        success: true,
        message: 'Today attendance data',
        isCheckedIn: isCheckedIn,
        data: {
          ...record,
          attendance_date: localDateStr,
          breaks: breaks,
          isCheckedIn: isCheckedIn
        }
      });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('❌ Get Today Attendance error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch attendance data',
      error: error.message
    });
  }
};

// Get Monthly Attendance Summary
exports.getMonthlyAttendance = async (req, res) => {
  try {
    const { employee_id } = req.params;
    const { year, month } = req.query;

    const currentYear = year || new Date().getFullYear();
    const currentMonth = month || new Date().getMonth() + 1;

    const connection = await pool.getConnection();

    try {
      // Convert user_as_employees.id to employee_onboarding.id if needed
      let finalEmployeeId = employee_id;
      const [employeeMapping] = await connection.query(
        `SELECT eo.id as onboarding_id FROM employee_onboarding eo
         WHERE eo.id = ?`,
        [employee_id]
      );
      
      // If we have a direct match, use it. Otherwise try to look up by user_as_employees
      if (employeeMapping.length === 0) {
        // Try to find via user_as_employees table (convert user_as_employees.id to onboarding id)
        const [userMapping] = await connection.query(
          `SELECT uae.employee_id FROM user_as_employees uae WHERE uae.id = ?`,
          [employee_id]
        );
        
        if (userMapping.length > 0) {
          finalEmployeeId = userMapping[0].employee_id;
          console.log(`🔄 getMonthlyAttendance: Converted user_as_employees.id ${employee_id} to employee_onboarding.id ${finalEmployeeId}`);
        }
      }
      
      const [monthlyData] = await connection.query(
        `SELECT * FROM Employee_Attendance 
         WHERE employee_id = ? AND YEAR(attendance_date) = ? AND MONTH(attendance_date) = ?
         ORDER BY attendance_date ASC`,
        [finalEmployeeId, currentYear, currentMonth]
      );

      // Convert dates to proper format for frontend using local date components
      const formattedData = monthlyData.map(record => ({
        ...record,
        attendance_date: (() => {
          const d = record.attendance_date instanceof Date ? record.attendance_date : new Date(record.attendance_date);
          return getLocalDateString(d);
        })()
      }));

      res.status(200).json({
        success: true,
        message: 'Monthly attendance data',
        data: formattedData,
        summary: {
          year: currentYear,
          month: currentMonth,
          total_days: formattedData.length,
          present_days: formattedData.filter(r => r.status === 'Present').length,
          absent_days: formattedData.filter(r => r.status === 'Absent').length,
          late_days: formattedData.filter(r => r.status === 'Late').length
        }
      });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('❌ Get Monthly Attendance error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch monthly attendance',
      error: error.message
    });
  }
};

// Get All Attendance Records (Admin)
exports.getAllAttendance = async (req, res) => {
  try {
    const { date, status, limit = 50, page = 1 } = req.query;

    const connection = await pool.getConnection();

    try {
      let query = `SELECT * FROM Employee_Attendance WHERE 1=1`;
      const params = [];

      if (date) {
        query += ` AND attendance_date = ?`;
        params.push(date);
      }

      if (status) {
        query += ` AND status = ?`;
        params.push(status);
      }

      query += ` ORDER BY attendance_date DESC, employee_id ASC LIMIT ? OFFSET ?`;
      params.push(parseInt(limit), (parseInt(page) - 1) * parseInt(limit));

      const [attendance] = await connection.query(query, params);

      // Fetch breaks for each attendance record
      const attendanceWithBreaks = await Promise.all(
        attendance.map(async (record) => {
          const [breaks] = await connection.query(
            `SELECT id, break_type, break_start_time, break_end_time, break_duration_minutes, reason 
             FROM Employee_Breaks 
             WHERE attendance_id = ? 
             ORDER BY break_start_time ASC`,
            [record.id]
          );
          
          return {
            ...record,
            breaks: breaks || [],
            total_breaks_count: breaks ? breaks.length : 0
          };
        })
      );

      res.status(200).json({
        success: true,
        message: 'All attendance records',
        data: attendanceWithBreaks,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: attendanceWithBreaks.length
        }
      });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('❌ Get All Attendance error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch attendance records',
      error: error.message
    });
  }
};

// Get All Attendance with Absent Records (includes all employees)
exports.getAllAttendanceWithAbsent = async (req, res) => {
  try {
    const { date, status, limit = 100, page = 1 } = req.query;

    const connection = await pool.getConnection();

    try {
      // First get all active employees
      const [allEmployees] = await connection.query(
        `SELECT id, employee_id, name, email, department, status FROM employee_onboarding WHERE status = 'Active'`
      );

      let attendanceQuery = `SELECT * FROM Employee_Attendance WHERE 1=1`;
      const attendanceParams = [];

      if (date) {
        attendanceQuery += ` AND attendance_date = ?`;
        attendanceParams.push(date);
      }

      if (status) {
        attendanceQuery += ` AND status = ?`;
        attendanceParams.push(status);
      }

      attendanceQuery += ` ORDER BY attendance_date DESC, employee_id ASC`;

      const [attendance] = await connection.query(attendanceQuery, attendanceParams);

      // Fetch breaks for each attendance record
      const attendanceWithBreaks = await Promise.all(
        attendance.map(async (record) => {
          const [breaks] = await connection.query(
            `SELECT id, break_type, break_start_time, break_end_time, break_duration_minutes, reason 
             FROM Employee_Breaks 
             WHERE attendance_id = ? 
             ORDER BY break_start_time ASC`,
            [record.id]
          );
          
          return {
            ...record,
            breaks: breaks || [],
            total_breaks_count: breaks ? breaks.length : 0
          };
        })
      );

      // If date filter is applied, create absent records for employees who haven't checked in
      let completeAttendanceData = attendanceWithBreaks;
      
      if (date) {
        // Check if the date is a weekend (Saturday = 6, Sunday = 0)
        const dateObj = new Date(date);
        const dayOfWeek = dateObj.getDay();
        const isWeekend = dayOfWeek === 0 || dayOfWeek === 6;
        
        // Only create absent records for weekdays
        if (!isWeekend) {
          const attendanceEmployeeIds = new Set(attendance.map(a => a.employee_id));
          
          // Add absent records for employees who didn't check in
          const absentRecords = allEmployees
            .filter(emp => !attendanceEmployeeIds.has(emp.id))
            .map(emp => ({
              id: null,
              employee_id: emp.id,
              email: emp.email,
              name: emp.name,
              attendance_date: date,
              check_in_time: null,
              check_out_time: null,
              status: 'Absent',
              total_breaks_taken: 0,
              smoke_break_count: 0,
              dinner_break_count: 0,
              washroom_break_count: 0,
              prayer_break_count: 0,
              smoke_break_duration_minutes: 0,
              dinner_break_duration_minutes: 0,
              washroom_break_duration_minutes: 0,
              prayer_break_duration_minutes: 0,
              total_break_duration_minutes: 0,
              gross_working_time_minutes: 0,
              net_working_time_minutes: 0,
              expected_working_time_minutes: 540,
              overtime_minutes: 0,
              overtime_hours: '0.00',
              on_time: 0,
              late_by_minutes: 0,
              remarks: 'No check-in',
              device_info: null,
              ip_address: null,
              created_at: null,
              updated_at: null,
              breaks: [],
              total_breaks_count: 0
            }));

          completeAttendanceData = [...attendanceWithBreaks, ...absentRecords].sort((a, b) => {
            if (a.name !== b.name) return a.name.localeCompare(b.name);
            return (a.status || 'Z').localeCompare(b.status || 'Z');
          });
        }
      }

      // Apply pagination
      const startIdx = (parseInt(page) - 1) * parseInt(limit);
      const endIdx = startIdx + parseInt(limit);
      const paginatedData = completeAttendanceData.slice(startIdx, endIdx);

      res.status(200).json({
        success: true,
        message: 'All attendance records with absent status',
        data: paginatedData,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: completeAttendanceData.length,
          total_active_employees: allEmployees.length
        }
      });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('❌ Get All Attendance With Absent error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch attendance records',
      error: error.message
    });
  }
};

// Get Attendance Summary View
exports.getAttendanceSummary = async (req, res) => {
  try {
    const { employee_id, start_date, end_date } = req.query;

    const connection = await pool.getConnection();

    try {
      let query = `SELECT * FROM Attendance_Summary_View WHERE 1=1`;
      const params = [];

      if (employee_id) {
        query += ` AND employee_id = ?`;
        params.push(employee_id);
      }

      if (start_date) {
        query += ` AND attendance_date >= ?`;
        params.push(start_date);
      }

      if (end_date) {
        query += ` AND attendance_date <= ?`;
        params.push(end_date);
      }

      const [summary] = await connection.query(query, params);

      res.status(200).json({
        success: true,
        message: 'Attendance summary',
        data: summary
      });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('❌ Get Attendance Summary error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch attendance summary',
      error: error.message
    });
  }
};

// Get Overtime Report
exports.getOvertimeReport = async (req, res) => {
  try {
    const { employee_id, start_date, end_date } = req.query;

    const connection = await pool.getConnection();

    try {
      let query = `SELECT * FROM Overtime_Report_View WHERE 1=1`;
      const params = [];

      if (employee_id) {
        query += ` AND employee_id = ?`;
        params.push(employee_id);
      }

      if (start_date) {
        query += ` AND attendance_date >= ?`;
        params.push(start_date);
      }

      if (end_date) {
        query += ` AND attendance_date <= ?`;
        params.push(end_date);
      }

      const [overtimeData] = await connection.query(query, params);

      // Calculate totals
      const totalOvertimeMinutes = overtimeData.reduce((sum, row) => sum + (row.overtime_minutes || 0), 0);
      const totalOvertimeHours = (totalOvertimeMinutes / 60).toFixed(2);

      res.status(200).json({
        success: true,
        message: 'Overtime report',
        data: overtimeData,
        summary: {
          total_overtime_hours: parseFloat(totalOvertimeHours),
          total_overtime_days: overtimeData.length,
          average_overtime_per_day: (totalOvertimeHours / overtimeData.length).toFixed(2)
        }
      });
    } finally {
      connection.release();
    }
  } catch (error) {
      console.error('❌ Get Overtime Report error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch overtime report',
      error: error.message
    });
  }
};

// Get all breaks
exports.getAllBreaks = async (req, res) => {
  try {
    const connection = await pool.getConnection();

    try {
      const [breaks] = await connection.query(
        `SELECT eb.id, eb.attendance_id, eb.employee_id, eb.break_type, 
                eb.break_start_time, eb.break_end_time, eb.break_duration_minutes,
                eb.reason, eb.created_at, eb.updated_at,
                eo.name as employee_name 
         FROM Employee_Breaks eb
         LEFT JOIN employee_onboarding eo ON eb.employee_id = eo.id
         ORDER BY eb.created_at DESC`
      );

      console.log(`📊 Retrieved ${breaks.length} break records from database`);

      res.status(200).json({
        success: true,
        message: 'All breaks retrieved successfully',
        data: breaks,
        count: breaks.length
      });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('❌ Get All Breaks error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch breaks',
      error: error.message
    });
  }
};

// Auto-fix missing working hours for all records
exports.autoFixMissingWorkingHours = async (req, res) => {
  let connection;
  try {
    connection = await pool.getConnection();

    // SQL query to recalculate missing working hours for all records
    const query = `
      UPDATE Employee_Attendance
      SET 
          gross_working_time_minutes = CASE
              WHEN check_in_time IS NOT NULL AND check_out_time IS NOT NULL 
                  AND status IN ('Present', 'Late')
                  AND (gross_working_time_minutes = 0 OR gross_working_time_minutes IS NULL) THEN
                  CASE
                      WHEN (HOUR(check_in_time) * 60 + MINUTE(check_in_time)) >= 21 * 60 THEN
                          CASE
                              WHEN (HOUR(check_out_time) * 60 + MINUTE(check_out_time)) > (HOUR(check_in_time) * 60 + MINUTE(check_in_time)) THEN
                                  (HOUR(check_out_time) * 60 + MINUTE(check_out_time)) - (HOUR(check_in_time) * 60 + MINUTE(check_in_time))
                              WHEN (HOUR(check_out_time) * 60 + MINUTE(check_out_time)) <= 6 * 60 THEN
                                  ((24 * 60) - (HOUR(check_in_time) * 60 + MINUTE(check_in_time))) + (HOUR(check_out_time) * 60 + MINUTE(check_out_time))
                              ELSE
                                  ((24 * 60) - (HOUR(check_in_time) * 60 + MINUTE(check_in_time))) + (HOUR(check_out_time) * 60 + MINUTE(check_out_time))
                          END
                      ELSE
                          GREATEST(0, (HOUR(check_out_time) * 60 + MINUTE(check_out_time)) - (HOUR(check_in_time) * 60 + MINUTE(check_in_time)))
                  END
              ELSE gross_working_time_minutes
          END,
          net_working_time_minutes = CASE
              WHEN check_in_time IS NOT NULL AND check_out_time IS NOT NULL 
                  AND status IN ('Present', 'Late')
                  AND (net_working_time_minutes = 0 OR net_working_time_minutes IS NULL) THEN
                  GREATEST(0,
                      CASE
                          WHEN (HOUR(check_in_time) * 60 + MINUTE(check_in_time)) >= 21 * 60 THEN
                              CASE
                                  WHEN (HOUR(check_out_time) * 60 + MINUTE(check_out_time)) > (HOUR(check_in_time) * 60 + MINUTE(check_in_time)) THEN
                                      (HOUR(check_out_time) * 60 + MINUTE(check_out_time)) - (HOUR(check_in_time) * 60 + MINUTE(check_in_time))
                                  WHEN (HOUR(check_out_time) * 60 + MINUTE(check_out_time)) <= 6 * 60 THEN
                                      ((24 * 60) - (HOUR(check_in_time) * 60 + MINUTE(check_in_time))) + (HOUR(check_out_time) * 60 + MINUTE(check_out_time))
                                  ELSE
                                      ((24 * 60) - (HOUR(check_in_time) * 60 + MINUTE(check_in_time))) + (HOUR(check_out_time) * 60 + MINUTE(check_out_time))
                              END
                          ELSE
                              GREATEST(0, (HOUR(check_out_time) * 60 + MINUTE(check_out_time)) - (HOUR(check_in_time) * 60 + MINUTE(check_in_time)))
                      END - COALESCE(total_break_duration_minutes, 0)
                  )
              ELSE net_working_time_minutes
          END,
          overtime_minutes = CASE
              WHEN (CASE
                  WHEN check_in_time IS NOT NULL AND check_out_time IS NOT NULL THEN
                      GREATEST(0,
                          CASE
                              WHEN (HOUR(check_in_time) * 60 + MINUTE(check_in_time)) >= 21 * 60 THEN
                                  CASE
                                      WHEN (HOUR(check_out_time) * 60 + MINUTE(check_out_time)) > (HOUR(check_in_time) * 60 + MINUTE(check_in_time)) THEN
                                          (HOUR(check_out_time) * 60 + MINUTE(check_out_time)) - (HOUR(check_in_time) * 60 + MINUTE(check_in_time))
                                      WHEN (HOUR(check_out_time) * 60 + MINUTE(check_out_time)) <= 6 * 60 THEN
                                          ((24 * 60) - (HOUR(check_in_time) * 60 + MINUTE(check_in_time))) + (HOUR(check_out_time) * 60 + MINUTE(check_out_time))
                                      ELSE
                                          ((24 * 60) - (HOUR(check_in_time) * 60 + MINUTE(check_in_time))) + (HOUR(check_out_time) * 60 + MINUTE(check_out_time))
                                  END
                              ELSE
                                  GREATEST(0, (HOUR(check_out_time) * 60 + MINUTE(check_out_time)) - (HOUR(check_in_time) * 60 + MINUTE(check_in_time)))
                          END - COALESCE(total_break_duration_minutes, 0)
                      )
                  ELSE 0
              END) > 540 THEN
                  (CASE
                      WHEN check_in_time IS NOT NULL AND check_out_time IS NOT NULL THEN
                          GREATEST(0,
                              CASE
                                  WHEN (HOUR(check_in_time) * 60 + MINUTE(check_in_time)) >= 21 * 60 THEN
                                      CASE
                                          WHEN (HOUR(check_out_time) * 60 + MINUTE(check_out_time)) > (HOUR(check_in_time) * 60 + MINUTE(check_in_time)) THEN
                                              (HOUR(check_out_time) * 60 + MINUTE(check_out_time)) - (HOUR(check_in_time) * 60 + MINUTE(check_in_time))
                                          WHEN (HOUR(check_out_time) * 60 + MINUTE(check_out_time)) <= 6 * 60 THEN
                                              ((24 * 60) - (HOUR(check_in_time) * 60 + MINUTE(check_in_time))) + (HOUR(check_out_time) * 60 + MINUTE(check_out_time))
                                          ELSE
                                              ((24 * 60) - (HOUR(check_in_time) * 60 + MINUTE(check_in_time))) + (HOUR(check_out_time) * 60 + MINUTE(check_out_time))
                                      END
                                  ELSE
                                      GREATEST(0, (HOUR(check_out_time) * 60 + MINUTE(check_out_time)) - (HOUR(check_in_time) * 60 + MINUTE(check_in_time)))
                              END - COALESCE(total_break_duration_minutes, 0)
                          )
                      ELSE 0
                  END) - 540
              ELSE 0
          END,
          overtime_hours = CASE
              WHEN (CASE
                  WHEN check_in_time IS NOT NULL AND check_out_time IS NOT NULL THEN
                      GREATEST(0,
                          CASE
                              WHEN (HOUR(check_in_time) * 60 + MINUTE(check_in_time)) >= 21 * 60 THEN
                                  CASE
                                      WHEN (HOUR(check_out_time) * 60 + MINUTE(check_out_time)) > (HOUR(check_in_time) * 60 + MINUTE(check_in_time)) THEN
                                          (HOUR(check_out_time) * 60 + MINUTE(check_out_time)) - (HOUR(check_in_time) * 60 + MINUTE(check_in_time))
                                      WHEN (HOUR(check_out_time) * 60 + MINUTE(check_out_time)) <= 6 * 60 THEN
                                          ((24 * 60) - (HOUR(check_in_time) * 60 + MINUTE(check_in_time))) + (HOUR(check_out_time) * 60 + MINUTE(check_out_time))
                                      ELSE
                                          ((24 * 60) - (HOUR(check_in_time) * 60 + MINUTE(check_in_time))) + (HOUR(check_out_time) * 60 + MINUTE(check_out_time))
                                  END
                              ELSE
                                  GREATEST(0, (HOUR(check_out_time) * 60 + MINUTE(check_out_time)) - (HOUR(check_in_time) * 60 + MINUTE(check_in_time)))
                          END - COALESCE(total_break_duration_minutes, 0)
                      )
                  ELSE 0
              END) > 540 THEN
                  ROUND((CASE
                      WHEN check_in_time IS NOT NULL AND check_out_time IS NOT NULL THEN
                          GREATEST(0,
                              CASE
                                  WHEN (HOUR(check_in_time) * 60 + MINUTE(check_in_time)) >= 21 * 60 THEN
                                      CASE
                                          WHEN (HOUR(check_out_time) * 60 + MINUTE(check_out_time)) > (HOUR(check_in_time) * 60 + MINUTE(check_in_time)) THEN
                                              (HOUR(check_out_time) * 60 + MINUTE(check_out_time)) - (HOUR(check_in_time) * 60 + MINUTE(check_in_time))
                                          WHEN (HOUR(check_out_time) * 60 + MINUTE(check_out_time)) <= 6 * 60 THEN
                                              ((24 * 60) - (HOUR(check_in_time) * 60 + MINUTE(check_in_time))) + (HOUR(check_out_time) * 60 + MINUTE(check_out_time))
                                          ELSE
                                              ((24 * 60) - (HOUR(check_in_time) * 60 + MINUTE(check_in_time))) + (HOUR(check_out_time) * 60 + MINUTE(check_out_time))
                                      END
                                  ELSE
                                      GREATEST(0, (HOUR(check_out_time) * 60 + MINUTE(check_out_time)) - (HOUR(check_in_time) * 60 + MINUTE(check_in_time)))
                              END - COALESCE(total_break_duration_minutes, 0)
                          )
                      ELSE 0
                  END - 540) / 60, 2)
              ELSE '0.00'
          END,
          updated_at = NOW()
      WHERE (gross_working_time_minutes = 0 OR gross_working_time_minutes IS NULL)
          AND check_in_time IS NOT NULL
          AND check_out_time IS NOT NULL
          AND status IN ('Present', 'Late');
    `;

    const [result] = await connection.query(query);
    
    connection.release();

    console.log(`✅ Auto-fixed ${result.affectedRows} records with missing working hours`);

    res.status(200).json({
      success: true,
      message: `Successfully auto-fixed working hours`,
      records_updated: result.affectedRows,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('❌ Auto-fix missing working hours error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to auto-fix working hours',
      error: error.message
    });
  }
};
