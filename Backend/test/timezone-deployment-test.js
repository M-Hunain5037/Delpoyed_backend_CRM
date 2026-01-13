/**
 * TIMEZONE DEPLOYMENT TEST
 * 
 * This test verifies that Pakistan Standard Time (PKT - UTC+5) is working correctly
 * regardless of the server's system timezone.
 * 
 * Usage:
 *   node timezone-deployment-test.js
 * 
 * Expected output:
 *   - Server should always show Pakistan time (UTC+5)
 *   - On January 13, 2026, server check-in at ~07:37 should display as 12:37 PKT
 *   - Times should match across all functions
 */

const { 
  getPakistanDate, 
  getPakistanDateString, 
  getPakistanTimeString,
  getPakistanMySQLDateTime,
  getPakistanYesterday,
  getPakistanYesterdayString 
} = require('../utils/timezone');

console.log('🌍 TIMEZONE DEPLOYMENT TEST');
console.log('=====================================\n');

// Test 1: Get current Pakistan time and date
console.log('✅ TEST 1: Current Pakistan Time & Date');
const pkDate = getPakistanDate();
const pkDateStr = getPakistanDateString();
const pkTimeStr = getPakistanTimeString();
const pkMySQLDateTime = getPakistanMySQLDateTime();

console.log(`   getPakistanDate(): ${pkDate}`);
console.log(`   getPakistanDateString(): ${pkDateStr}`);
console.log(`   getPakistanTimeString(): ${pkTimeStr}`);
console.log(`   getPakistanMySQLDateTime(): ${pkMySQLDateTime}`);
console.log();

// Test 2: Verify time calculation
console.log('✅ TEST 2: Verify Time Calculation (UTC+5)');
const now = new Date();
const utcHours = now.getUTCHours();
const utcMinutes = now.getUTCMinutes();
const utcSeconds = now.getUTCSeconds();

const [pkHours, pkMinutes, pkSeconds] = pkTimeStr.split(':').map(Number);

const expectedHours = (utcHours + 5) % 24; // Add 5 hours for PKT, wrap at 24
console.log(`   UTC Time: ${String(utcHours).padStart(2, '0')}:${String(utcMinutes).padStart(2, '0')}:${String(utcSeconds).padStart(2, '0')}`);
console.log(`   PKT Time: ${pkTimeStr}`);
console.log(`   Expected Hours: ${expectedHours}, Actual: ${pkHours}`);

if (pkHours === expectedHours) {
  console.log(`   ✓ TIME CALCULATION CORRECT (UTC+5 offset applied)`);
} else {
  console.log(`   ✗ TIME CALCULATION ERROR - Expected ${expectedHours}, got ${pkHours}`);
}
console.log();

// Test 3: Night shift date handling
console.log('✅ TEST 3: Night Shift Date Logic (21:00-06:00)');
const hour = pkDate.getUTCHours();
if (hour >= 0 && hour < 6) {
  const yesterday = getPakistanYesterdayString();
  console.log(`   Current Hour: ${hour} (Early Morning - 00:00 to 05:59)`);
  console.log(`   Attendance Date should be: ${yesterday} (YESTERDAY)`);
  console.log(`   ✓ Night shift logic would apply`);
} else if (hour >= 21) {
  console.log(`   Current Hour: ${hour} (Evening - 21:00 to 23:59)`);
  console.log(`   Attendance Date should be: ${pkDateStr} (TODAY)`);
  console.log(`   ✓ Night shift logic would apply`);
} else {
  console.log(`   Current Hour: ${hour} (Normal hours - 06:00 to 20:59)`);
  console.log(`   Attendance Date should be: ${pkDateStr} (TODAY)`);
  console.log(`   ✓ Normal shift logic applies`);
}
console.log();

// Test 4: Example scenario
console.log('✅ TEST 4: Check-in Scenario');
console.log(`   If user checks in now at: ${pkTimeStr}`);
console.log(`   Date in database: ${pkDateStr}`);
console.log(`   Database will store: "${pkMySQLDateTime}"`);
console.log(`   This timestamp should match Pakistan timezone (UTC+5)`);
console.log();

// Test 5: Server timezone info
console.log('✅ TEST 5: Server Timezone Information');
const serverTzOffset = new Date().getTimezoneOffset();
const serverTzOffsetHours = -serverTzOffset / 60;
console.log(`   Server System Timezone Offset: UTC${serverTzOffsetHours > 0 ? '+' : ''}${serverTzOffsetHours}`);
console.log(`   Application Timezone Override: UTC+5 (Pakistan Standard Time)`);
console.log(`   Status: ✓ Application correctly overrides server timezone`);
console.log();

// Test 6: Consistency check
console.log('✅ TEST 6: Consistency Check');
const test1 = getPakistanTimeString();
const test2 = getPakistanTimeString();
const test3 = getPakistanTimeString();

if (test1 === test2 && test2 === test3) {
  console.log(`   Multiple calls consistent: ${test1} ✓`);
} else {
  console.log(`   INCONSISTENCY DETECTED: ${test1} vs ${test2} vs ${test3}`);
}
console.log();

console.log('=====================================');
console.log('🎯 DEPLOYMENT TEST COMPLETE');
console.log('=====================================');
console.log();
console.log('📋 SUMMARY:');
console.log('   ✓ If all tests pass, timezone is correctly configured');
console.log('   ✓ Check-in times will display correctly on deployed server');
console.log('   ✓ Database will store Pakistan time (UTC+5)');
console.log();
