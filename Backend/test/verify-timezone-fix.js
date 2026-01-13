// Quick test to verify timezone fix
const { getPakistanDate, getPakistanTimeString, getPakistanDateString } = require('../utils/timezone');

console.log('='.repeat(60));
console.log('TIMEZONE FIX VERIFICATION TEST');
console.log('='.repeat(60));

const now = new Date();
const pkDate = getPakistanDate();
const pkTime = getPakistanTimeString();
const pkDateStr = getPakistanDateString();

console.log('\n📅 Server System Time:');
console.log('   Date Object:', now.toString());
console.log('   UTC:', now.toUTCString());
console.log('   Timezone Offset:', now.getTimezoneOffset(), 'minutes');

console.log('\n🇵🇰 Pakistan Time Functions:');
console.log('   getPakistanDate():', pkDate.toString());
console.log('   getPakistanTimeString():', pkTime);
console.log('   getPakistanDateString():', pkDateStr);

console.log('\n✅ Expected Behavior:');
console.log('   - Server is in PKT (UTC+5)');
console.log('   - getPakistanDate() should return current server time');
console.log('   - getPakistanTimeString() should match current hour/min/sec');
console.log('   - NO double conversion (+10 hours)');

console.log('\n✨ Result:');
if (now.getHours() === pkDate.getHours() && 
    now.getMinutes() === pkDate.getMinutes()) {
  console.log('   ✅ PASS: Times match correctly!');
  console.log('   ✅ No double conversion issue');
} else {
  console.log('   ❌ FAIL: Times do not match');
  console.log('   Server hours:', now.getHours(), 'vs Pakistan hours:', pkDate.getHours());
}

console.log('\n' + '='.repeat(60));
