// Test the checkout time calculation fix directly
const pool = require('./config/database');

async function testCheckoutCalculation() {
  console.log('🧮 Testing checkout time calculation logic...\n');
  
  // Test scenarios
  const testCases = [
    {
      name: 'Same-day quick checkout (Night shift)',
      checkInTime: '21:56:49',
      checkOutTime: '21:56:58',
      isNightShift: true,
      expected: 'few seconds'
    },
    {
      name: 'Normal night shift',
      checkInTime: '21:00:00',
      checkOutTime: '05:30:00',
      isNightShift: true,
      expected: '8.5 hours'
    },
    {
      name: 'Day shift',
      checkInTime: '09:00:00',
      checkOutTime: '17:30:00',
      isNightShift: false,
      expected: '8.5 hours'
    }
  ];
  
  for (const testCase of testCases) {
    console.log(`📊 ${testCase.name}:`);
    console.log(`   Check-in: ${testCase.checkInTime}`);
    console.log(`   Check-out: ${testCase.checkOutTime}`);
    
    // Simulate the calculation logic from our fixed code
    const [checkInHour, checkInMin] = testCase.checkInTime.split(':').map(Number);
    const [checkOutHour, checkOutMin] = testCase.checkOutTime.split(':').map(Number);
    
    const checkInTotalMinutes = checkInHour * 60 + checkInMin;
    const checkOutTotalMinutes = checkOutHour * 60 + checkOutMin;
    
    let grossWorkingMinutes = 0;
    const isNightShift = checkInTotalMinutes >= 21 * 60; // 21:00 or later
    
    if (isNightShift) {
      // Use the fixed logic from our controller
      const isSameDay = true; // Simulate same day scenario
      const timeDifferenceMinutes = checkOutTotalMinutes - checkInTotalMinutes;
      
      if (isSameDay && timeDifferenceMinutes >= 0) {
        // Same calendar day checkout with positive time difference
        grossWorkingMinutes = timeDifferenceMinutes;
        console.log(`   ✅ FIXED: Same-Day Night Shift = ${grossWorkingMinutes}min (${(grossWorkingMinutes/60).toFixed(2)}h)`);
      } else if (checkOutTotalMinutes >= 6 * 60) {
        // Next day afternoon checkout
        const minutesUntilMidnight = (24 * 60) - checkInTotalMinutes;
        const minutesAfterMidnight = checkOutTotalMinutes;
        grossWorkingMinutes = minutesUntilMidnight + minutesAfterMidnight;
        console.log(`   📊 Next-Day Checkout = ${grossWorkingMinutes}min (${(grossWorkingMinutes/60).toFixed(1)}h)`);
      } else {
        // Normal night shift ending early morning
        const minutesUntilMidnight = (24 * 60) - checkInTotalMinutes;
        const minutesAfterMidnight = checkOutTotalMinutes;
        grossWorkingMinutes = minutesUntilMidnight + minutesAfterMidnight;
        console.log(`   📊 Normal Night Shift = ${grossWorkingMinutes}min (${(grossWorkingMinutes/60).toFixed(1)}h)`);
      }
    } else {
      // Day shift
      grossWorkingMinutes = checkOutTotalMinutes - checkInTotalMinutes;
      console.log(`   📊 Day Shift = ${grossWorkingMinutes}min (${(grossWorkingMinutes/60).toFixed(1)}h)`);
    }
    
    console.log(`   Expected: ${testCase.expected}`);
    console.log();
  }
  
  console.log('✅ Checkout calculation test completed');
}

// Test absent record generation endpoint
async function testAbsentEndpoint() {
  console.log('\n🔄 Testing absent record generation...');
  
  try {
    const response = await fetch('http://localhost:5000/api/v1/attendance/generate-absent', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    if (response.ok) {
      const data = await response.json();
      console.log('✅ Absent records generated:', data);
    } else {
      console.log('❌ Request failed:', response.status, await response.text());
    }
  } catch (error) {
    console.log('❌ Connection error:', error.message);
  }
}

// Run tests
async function runTests() {
  await testCheckoutCalculation();
  await testAbsentEndpoint();
}

runTests();