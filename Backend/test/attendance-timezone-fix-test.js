// ============================================================
// ATTENDANCE TIMEZONE FIX - DEEP TESTING SCRIPT
// ============================================================
// This script tests the timezone fix for check-in/check-out times
// Tests with LIVE database to ensure times are stored and retrieved correctly
// ============================================================

const mysql = require('mysql2/promise');
const { getPakistanDate, getPakistanDateString, getPakistanTimeString } = require('../utils/timezone');
require('dotenv').config();

// Color codes for console output
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
  magenta: '\x1b[35m'
};

// Database connection pool
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  timezone: '+05:00' // Pakistan timezone
});

async function testDatabaseConnection() {
  console.log(`\n${colors.cyan}========================================`);
  console.log(`TEST 1: Database Connection`);
  console.log(`========================================${colors.reset}`);
  
  try {
    const connection = await pool.getConnection();
    console.log(`${colors.green}✅ Database connected successfully${colors.reset}`);
    console.log(`   Host: ${process.env.DB_HOST}`);
    console.log(`   Database: ${process.env.DB_NAME}`);
    console.log(`   Timezone: +05:00 (Pakistan)`);
    connection.release();
    return true;
  } catch (error) {
    console.log(`${colors.red}❌ Database connection failed: ${error.message}${colors.reset}`);
    return false;
  }
}

async function testTimezoneUtilities() {
  console.log(`\n${colors.cyan}========================================`);
  console.log(`TEST 2: Timezone Utility Functions`);
  console.log(`========================================${colors.reset}`);
  
  const pkDate = getPakistanDate();
  const pkDateStr = getPakistanDateString();
  const pkTimeStr = getPakistanTimeString();
  const systemDate = new Date();
  
  console.log(`${colors.blue}Pakistan Time (Expected):${colors.reset}`);
  console.log(`   Date: ${pkDateStr}`);
  console.log(`   Time: ${pkTimeStr}`);
  console.log(`   Full: ${pkDate.toISOString()}`);
  
  console.log(`${colors.blue}System Time (for comparison):${colors.reset}`);
  console.log(`   Date: ${systemDate.toLocaleDateString()}`);
  console.log(`   Time: ${systemDate.toLocaleTimeString()}`);
  console.log(`   Full: ${systemDate.toISOString()}`);
  
  // Verify the time is reasonable
  const pkHour = pkDate.getHours();
  console.log(`\n${colors.blue}Verification:${colors.reset}`);
  console.log(`   Pakistan Hour: ${pkHour}`);
  
  if (pkHour >= 0 && pkHour <= 23) {
    console.log(`${colors.green}✅ Pakistan time is valid (0-23 hours)${colors.reset}`);
    return true;
  } else {
    console.log(`${colors.red}❌ Pakistan time is invalid${colors.reset}`);
    return false;
  }
}

async function testCheckInTimeStorage() {
  console.log(`\n${colors.cyan}========================================`);
  console.log(`TEST 3: Check-In Time Storage (Live Test)`);
  console.log(`========================================${colors.reset}`);
  
  const connection = await pool.getConnection();
  
  try {
    // Get current Pakistan time
    const currentPkTime = getPakistanTimeString();
    const currentPkDate = getPakistanDateString();
    
    console.log(`${colors.blue}Current Pakistan Time:${colors.reset} ${currentPkTime}`);
    console.log(`${colors.blue}Current Pakistan Date:${colors.reset} ${currentPkDate}`);
    
    // Create a test attendance record
    const testEmployeeId = 1; // Using employee ID 1 for test
    const testEmail = 'test@timezone.com';
    const testName = 'Timezone Test User';
    
    // First, clean up any existing test records from today
    await connection.query(
      `DELETE FROM Employee_Attendance WHERE email = ? AND attendance_date = ?`,
      [testEmail, currentPkDate]
    );
    
    console.log(`\n${colors.yellow}Inserting test record...${colors.reset}`);
    
    // Insert test record with current Pakistan time
    const [insertResult] = await connection.query(
      `INSERT INTO Employee_Attendance 
       (employee_id, email, name, attendance_date, check_in_time, status, on_time, late_by_minutes)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [testEmployeeId, testEmail, testName, currentPkDate, currentPkTime, 'Present', 1, 0]
    );
    
    const insertedId = insertResult.insertId;
    console.log(`   Inserted ID: ${insertedId}`);
    console.log(`   Stored check_in_time: ${currentPkTime}`);
    
    // Retrieve the record to verify
    const [retrievedRecords] = await connection.query(
      `SELECT id, check_in_time, attendance_date, created_at FROM Employee_Attendance WHERE id = ?`,
      [insertedId]
    );
    
    if (retrievedRecords.length > 0) {
      const record = retrievedRecords[0];
      console.log(`\n${colors.yellow}Retrieved from database:${colors.reset}`);
      console.log(`   check_in_time: ${record.check_in_time}`);
      console.log(`   attendance_date: ${record.attendance_date}`);
      console.log(`   created_at: ${record.created_at}`);
      
      // Compare stored vs retrieved
      const storedTime = currentPkTime;
      const retrievedTime = record.check_in_time;
      
      console.log(`\n${colors.blue}Comparison:${colors.reset}`);
      console.log(`   Stored:    ${storedTime}`);
      console.log(`   Retrieved: ${retrievedTime}`);
      
      if (storedTime === retrievedTime) {
        console.log(`${colors.green}✅ SUCCESS: Times match exactly!${colors.reset}`);
        console.log(`${colors.green}✅ No timezone conversion issues detected${colors.reset}`);
      } else {
        console.log(`${colors.red}❌ FAIL: Times don't match!${colors.reset}`);
        console.log(`${colors.red}   Difference: ${calculateTimeDifference(storedTime, retrievedTime)}${colors.reset}`);
      }
      
      // Clean up test record
      await connection.query(`DELETE FROM Employee_Attendance WHERE id = ?`, [insertedId]);
      console.log(`\n${colors.yellow}Test record cleaned up${colors.reset}`);
      
      return storedTime === retrievedTime;
    } else {
      console.log(`${colors.red}❌ FAIL: Could not retrieve test record${colors.reset}`);
      return false;
    }
  } catch (error) {
    console.log(`${colors.red}❌ Test failed: ${error.message}${colors.reset}`);
    return false;
  } finally {
    connection.release();
  }
}

async function testCheckOutTimeStorage() {
  console.log(`\n${colors.cyan}========================================`);
  console.log(`TEST 4: Check-Out Time Storage (Live Test)`);
  console.log(`========================================${colors.reset}`);
  
  const connection = await pool.getConnection();
  
  try {
    const currentPkTime = getPakistanTimeString();
    const currentPkDate = getPakistanDateString();
    const testEmail = 'test-checkout@timezone.com';
    
    console.log(`${colors.blue}Current Pakistan Time:${colors.reset} ${currentPkTime}`);
    
    // Clean up
    await connection.query(
      `DELETE FROM Employee_Attendance WHERE email = ?`,
      [testEmail]
    );
    
    // Insert check-in record
    const checkInTime = '16:17:00'; // 4:17 PM as mentioned in user's issue
    const [insertResult] = await connection.query(
      `INSERT INTO Employee_Attendance 
       (employee_id, email, name, attendance_date, check_in_time, status, on_time, late_by_minutes)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [1, testEmail, 'Checkout Test User', currentPkDate, checkInTime, 'Present', 1, 0]
    );
    
    const recordId = insertResult.insertId;
    console.log(`\n${colors.yellow}Created check-in record:${colors.reset}`);
    console.log(`   ID: ${recordId}`);
    console.log(`   Check-in time: ${checkInTime}`);
    
    // Update with check-out time
    const checkOutTime = currentPkTime;
    await connection.query(
      `UPDATE Employee_Attendance SET check_out_time = ? WHERE id = ?`,
      [checkOutTime, recordId]
    );
    
    console.log(`   Check-out time: ${checkOutTime}`);
    
    // Retrieve and verify
    const [records] = await connection.query(
      `SELECT check_in_time, check_out_time FROM Employee_Attendance WHERE id = ?`,
      [recordId]
    );
    
    if (records.length > 0) {
      const record = records[0];
      console.log(`\n${colors.yellow}Retrieved from database:${colors.reset}`);
      console.log(`   check_in_time:  ${record.check_in_time}`);
      console.log(`   check_out_time: ${record.check_out_time}`);
      
      const checkInMatch = checkInTime === record.check_in_time;
      const checkOutMatch = checkOutTime === record.check_out_time;
      
      console.log(`\n${colors.blue}Verification:${colors.reset}`);
      console.log(`   Check-in:  ${checkInMatch ? colors.green + '✅ Match' : colors.red + '❌ Mismatch'}${colors.reset}`);
      console.log(`   Check-out: ${checkOutMatch ? colors.green + '✅ Match' : colors.red + '❌ Mismatch'}${colors.reset}`);
      
      // Clean up
      await connection.query(`DELETE FROM Employee_Attendance WHERE id = ?`, [recordId]);
      
      return checkInMatch && checkOutMatch;
    }
    
    return false;
  } catch (error) {
    console.log(`${colors.red}❌ Test failed: ${error.message}${colors.reset}`);
    return false;
  } finally {
    connection.release();
  }
}

async function testRealAttendanceRecords() {
  console.log(`\n${colors.cyan}========================================`);
  console.log(`TEST 5: Real Attendance Records Check`);
  console.log(`========================================${colors.reset}`);
  
  const connection = await pool.getConnection();
  
  try {
    const todayDate = getPakistanDateString();
    
    // Get recent attendance records
    const [records] = await connection.query(
      `SELECT id, name, attendance_date, check_in_time, check_out_time, created_at 
       FROM Employee_Attendance 
       WHERE attendance_date >= DATE_SUB(?, INTERVAL 7 DAY)
       ORDER BY created_at DESC 
       LIMIT 10`,
      [todayDate]
    );
    
    console.log(`${colors.blue}Recent attendance records (last 7 days):${colors.reset}\n`);
    
    if (records.length === 0) {
      console.log(`${colors.yellow}No attendance records found in last 7 days${colors.reset}`);
      return true;
    }
    
    records.forEach((record, index) => {
      console.log(`${colors.magenta}Record ${index + 1}:${colors.reset}`);
      console.log(`   ID: ${record.id}`);
      console.log(`   Name: ${record.name}`);
      console.log(`   Date: ${record.attendance_date}`);
      console.log(`   Check-in:  ${record.check_in_time || 'N/A'}`);
      console.log(`   Check-out: ${record.check_out_time || 'N/A'}`);
      console.log(`   Created:   ${record.created_at}`);
      
      // Check if times look reasonable
      if (record.check_in_time) {
        const [hour] = record.check_in_time.split(':').map(Number);
        if (hour < 0 || hour > 23) {
          console.log(`   ${colors.red}⚠️ WARNING: Invalid hour detected!${colors.reset}`);
        } else if (hour >= 6 && hour <= 12) {
          console.log(`   ${colors.yellow}⚠️ Unusual check-in time (6 AM - 12 PM)${colors.reset}`);
        }
      }
      console.log('');
    });
    
    return true;
  } catch (error) {
    console.log(`${colors.red}❌ Test failed: ${error.message}${colors.reset}`);
    return false;
  } finally {
    connection.release();
  }
}

function calculateTimeDifference(time1, time2) {
  const [h1, m1, s1] = time1.split(':').map(Number);
  const [h2, m2, s2] = time2.split(':').map(Number);
  
  const totalSeconds1 = h1 * 3600 + m1 * 60 + s1;
  const totalSeconds2 = h2 * 3600 + m2 * 60 + s2;
  
  const diffSeconds = Math.abs(totalSeconds1 - totalSeconds2);
  const hours = Math.floor(diffSeconds / 3600);
  const minutes = Math.floor((diffSeconds % 3600) / 60);
  const seconds = diffSeconds % 60;
  
  return `${hours}h ${minutes}m ${seconds}s`;
}

// Main test runner
async function runAllTests() {
  console.log(`${colors.magenta}`);
  console.log(`╔════════════════════════════════════════════════════════╗`);
  console.log(`║   ATTENDANCE TIMEZONE FIX - COMPREHENSIVE TEST SUITE   ║`);
  console.log(`║                  Testing with LIVE Database             ║`);
  console.log(`╚════════════════════════════════════════════════════════╝`);
  console.log(`${colors.reset}`);
  
  const results = {
    total: 5,
    passed: 0,
    failed: 0
  };
  
  // Run all tests
  const test1 = await testDatabaseConnection();
  results.passed += test1 ? 1 : 0;
  results.failed += test1 ? 0 : 1;
  
  if (!test1) {
    console.log(`\n${colors.red}Cannot proceed with remaining tests - database connection failed${colors.reset}`);
    await pool.end();
    process.exit(1);
  }
  
  const test2 = await testTimezoneUtilities();
  results.passed += test2 ? 1 : 0;
  results.failed += test2 ? 0 : 1;
  
  const test3 = await testCheckInTimeStorage();
  results.passed += test3 ? 1 : 0;
  results.failed += test3 ? 0 : 1;
  
  const test4 = await testCheckOutTimeStorage();
  results.passed += test4 ? 1 : 0;
  results.failed += test4 ? 0 : 1;
  
  const test5 = await testRealAttendanceRecords();
  results.passed += test5 ? 1 : 0;
  results.failed += test5 ? 0 : 1;
  
  // Summary
  console.log(`\n${colors.magenta}========================================`);
  console.log(`TEST SUMMARY`);
  console.log(`========================================${colors.reset}`);
  console.log(`${colors.blue}Total Tests:  ${results.total}${colors.reset}`);
  console.log(`${colors.green}Passed:       ${results.passed}${colors.reset}`);
  console.log(`${colors.red}Failed:       ${results.failed}${colors.reset}`);
  
  if (results.failed === 0) {
    console.log(`\n${colors.green}╔═══════════════════════════════════╗${colors.reset}`);
    console.log(`${colors.green}║   ✅ ALL TESTS PASSED! ✅         ║${colors.reset}`);
    console.log(`${colors.green}║   Timezone fix is working correctly║${colors.reset}`);
    console.log(`${colors.green}╚═══════════════════════════════════╝${colors.reset}\n`);
  } else {
    console.log(`\n${colors.red}╔═══════════════════════════════════╗${colors.reset}`);
    console.log(`${colors.red}║   ❌ SOME TESTS FAILED ❌         ║${colors.reset}`);
    console.log(`${colors.red}║   Please review the output above   ║${colors.reset}`);
    console.log(`${colors.red}╚═══════════════════════════════════╝${colors.reset}\n`);
  }
  
  // Close pool
  await pool.end();
  process.exit(results.failed === 0 ? 0 : 1);
}

// Run tests
runAllTests().catch(error => {
  console.error(`${colors.red}Fatal error:${colors.reset}`, error);
  process.exit(1);
});
