const axios = require('axios');

// Configuration
const API_BASE_URL = 'http://localhost:5000/api/v1';
const TEST_EMPLOYEE_ID = 2;
const TEST_EMAIL = 'MH@gmail.com';
const TEST_PASSWORD = 'karachi123';

let authToken = null;

// Helper function to login and get token
async function login() {
  try {
    console.log('🔐 Logging in...');
    const response = await axios.post(`${API_BASE_URL}/auth/login`, {
      email: TEST_EMAIL,
      password: TEST_PASSWORD
    });

    authToken = response.data.data.token;
    console.log('✅ Login successful');
    return authToken;
  } catch (error) {
    console.error('❌ Login failed:', error.response?.data || error.message);
    process.exit(1);
  }
}

// Fetch attendance data for a specific month
async function getAttendanceData(year, month) {
  try {
    if (!authToken) {
      await login();
    }

    console.log(`\n📊 Fetching attendance for ${year}-${month}...`);
    const response = await axios.get(
      `${API_BASE_URL}/attendance/monthly/${TEST_EMPLOYEE_ID}?year=${year}&month=${month}`,
      {
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      }
    );

    return response.data.data;
  } catch (error) {
    console.error('❌ Failed to fetch attendance:', error.response?.data || error.message);
    process.exit(1);
  }
}

// Analyze and display attendance records
function analyzeAttendance(records) {
  console.log('\n' + '='.repeat(120));
  console.log('📋 ATTENDANCE ANALYSIS FOR MH@gmail.com');
  console.log('='.repeat(120));

  records.forEach((record, index) => {
    const dateObj = new Date(record.attendance_date);
    const formattedDate = dateObj.toLocaleDateString('en-US', { 
      weekday: 'long', 
      year: 'numeric', 
      month: 'long', 
      day: 'numeric' 
    });

    console.log(`\n📅 Record ${index + 1}: ${formattedDate}`);
    console.log('-'.repeat(120));
    
    console.log(`   Check-in:  ${record.check_in_time || 'N/A'}`);
    console.log(`   Check-out: ${record.check_out_time || 'N/A'}`);
    console.log(`   Status:    ${record.status}`);
    console.log(`   On Time:   ${record.on_time ? 'Yes' : 'No'}`);
    
    if (record.late_by_minutes > 0) {
      console.log(`   ⏱️  LATE BY: ${record.late_by_minutes} minutes`);
    } else {
      console.log(`   ✅ On Time (0 minutes late)`);
    }

    console.log(`\n   ⏳ Working Time:`);
    console.log(`      • Gross:     ${record.gross_working_time_minutes} minutes (${(record.gross_working_time_minutes / 60).toFixed(2)} hours)`);
    console.log(`      • Net:       ${record.net_working_time_minutes} minutes (${(record.net_working_time_minutes / 60).toFixed(2)} hours)`);
    console.log(`      • Breaks:    ${record.total_break_duration_minutes} minutes`);
    
    if (record.overtime_hours > 0 || record.overtime_minutes > 0) {
      console.log(`   ⏲️  OVERTIME: ${record.overtime_hours}h (${record.overtime_minutes} minutes) 🚀`);
    } else {
      console.log(`   ⏲️  Overtime: None`);
    }

    console.log(`   Break Details:`);
    console.log(`      • Smoke: ${record.smoke_break_count} breaks (${record.smoke_break_duration_minutes} min)`);
    console.log(`      • Dinner: ${record.dinner_break_count} breaks (${record.dinner_break_duration_minutes} min)`);
    console.log(`      • Washroom: ${record.washroom_break_count} breaks (${record.washroom_break_duration_minutes} min)`);
    console.log(`      • Prayer: ${record.prayer_break_count} breaks (${record.prayer_break_duration_minutes} min)`);
  });

  console.log('\n' + '='.repeat(120));
}

// Calculate expected values for debugging
function debugCalculations(records) {
  console.log('\n' + '='.repeat(120));
  console.log('🔍 DEBUG: Expected vs Actual Calculations');
  console.log('='.repeat(120));

  records.forEach((record, index) => {
    const dateObj = new Date(record.attendance_date);
    const formattedDate = dateObj.toLocaleDateString('en-US', { 
      year: 'numeric', 
      month: '2-digit', 
      day: '2-digit' 
    });

    console.log(`\n📅 Record ${index + 1}: ${formattedDate}`);
    console.log('-'.repeat(120));

    // Parse times
    const [inH, inM] = record.check_in_time.split(':').map(Number);
    const inTotalMin = inH * 60 + inM;
    
    console.log(`   Check-in: ${record.check_in_time} = ${inTotalMin} minutes from midnight`);
    
    if (record.check_out_time) {
      const [outH, outM] = record.check_out_time.split(':').map(Number);
      const outTotalMin = outH * 60 + outM;
      
      console.log(`   Check-out: ${record.check_out_time} = ${outTotalMin} minutes from midnight`);
      
      // Night shift logic
      if (inTotalMin >= 21 * 60) { // Check-in after 21:00
        console.log(`   ℹ️  Check-in is after 21:00 (evening)`);
        
        if (outTotalMin < 6 * 60) { // Check-out before 06:00
          console.log(`   ℹ️  Check-out is before 06:00 (next day morning)`);
          
          const minUntilMidnight = (24 * 60) - inTotalMin;
          const minAfterMidnight = outTotalMin;
          const expectedGross = minUntilMidnight + minAfterMidnight;
          
          console.log(`   📊 Expected Calculation:`);
          console.log(`      • Minutes until midnight: (1440 - ${inTotalMin}) = ${minUntilMidnight} min`);
          console.log(`      • Minutes after midnight: ${minAfterMidnight} min`);
          console.log(`      • Expected gross: ${minUntilMidnight} + ${minAfterMidnight} = ${expectedGross} min`);
          console.log(`      • Actual gross: ${record.gross_working_time_minutes} min`);
          
          if (expectedGross === record.gross_working_time_minutes) {
            console.log(`      ✅ CORRECT`);
          } else {
            console.log(`      ❌ MISMATCH! Expected ${expectedGross} but got ${record.gross_working_time_minutes}`);
          }
        }
      }

      // Late arrival check
      const gracePeriodEnd = 22 * 60 + 15; // 22:15 = 1335 minutes
      if (inTotalMin > gracePeriodEnd) {
        const expectedLate = inTotalMin - gracePeriodEnd;
        console.log(`   ⏱️  Late Arrival Check:`);
        console.log(`      • Grace period ends at: 22:15 (${gracePeriodEnd} min)`);
        console.log(`      • Check-in time: ${inTotalMin} min`);
        console.log(`      • Expected late by: ${expectedLate} minutes`);
        console.log(`      • Actual late by: ${record.late_by_minutes} minutes`);
        
        if (expectedLate === record.late_by_minutes) {
          console.log(`      ✅ CORRECT`);
        } else {
          console.log(`      ❌ MISMATCH!`);
        }
      } else {
        console.log(`   ✅ On time (checked in before or at grace period end)`);
        console.log(`      • Grace period ends at: 22:15 (${gracePeriodEnd} min)`);
        console.log(`      • Check-in time: ${inTotalMin} min`);
        console.log(`      • Late by: ${record.late_by_minutes} minutes (should be 0)`);
        if (record.late_by_minutes === 0) {
          console.log(`      ✅ CORRECT`);
        } else {
          console.log(`      ❌ MISMATCH!`);
        }
      }

      // Overtime check
      const netWorking = record.net_working_time_minutes;
      const expectedWorking = 540; // 9 hours
      if (outH >= 6 && netWorking > expectedWorking) {
        const expectedOvertimeMin = netWorking - expectedWorking;
        const expectedOvertimeHrs = (expectedOvertimeMin / 60).toFixed(2);
        
        console.log(`   ⏲️  Overtime Check:`);
        console.log(`      • Net working time: ${netWorking} minutes`);
        console.log(`      • Expected working time: ${expectedWorking} minutes`);
        console.log(`      • Checkout after 6 AM: Yes`);
        console.log(`      • Expected overtime: ${expectedOvertimeMin} min (${expectedOvertimeHrs}h)`);
        console.log(`      • Actual overtime: ${record.overtime_minutes} min (${record.overtime_hours}h)`);
        
        if (expectedOvertimeMin === record.overtime_minutes && expectedOvertimeHrs == record.overtime_hours) {
          console.log(`      ✅ CORRECT`);
        } else {
          console.log(`      ❌ MISMATCH!`);
        }
      } else {
        console.log(`   ⏲️  Overtime Check:`);
        console.log(`      • Expected overtime: 0 min (0h) [net: ${netWorking} vs required: ${expectedWorking}]`);
        console.log(`      • Actual overtime: ${record.overtime_minutes} min (${record.overtime_hours}h)`);
        
        if (record.overtime_minutes === 0 && record.overtime_hours == 0) {
          console.log(`      ✅ CORRECT`);
        } else {
          console.log(`      ❌ MISMATCH!`);
        }
      }
    }
  });

  console.log('\n' + '='.repeat(120));
}

// Main execution
async function main() {
  try {
    await login();
    const records = await getAttendanceData(2025, 12);
    
    if (records.length === 0) {
      console.log('❌ No attendance records found');
      return;
    }

    analyzeAttendance(records);
    debugCalculations(records);

    console.log('\n✅ Analysis complete!\n');
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

main();
