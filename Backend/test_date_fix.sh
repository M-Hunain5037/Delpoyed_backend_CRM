#!/bin/bash

echo "============================================"
echo "Testing Date Fix - Current Time Info"
echo "============================================"
echo "System time: $(date)"
echo "System hour: $(date +%H)"
echo ""

echo "============================================"
echo "Expected Behavior:"
echo "============================================"
echo "Current time: 1:XX AM on Jan 4th"
echo "Since hour is 1 (between 0-5), this is early morning"
echo "Should belong to YESTERDAY's shift = Jan 3rd"
echo ""

echo "============================================"
echo "Testing JavaScript Date Logic"
echo "============================================"
node -e "
const now = new Date();
const getLocalDateString = (date) => {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return \`\${year}-\${month}-\${day}\`;
};

const checkInHour = now.getHours();
let attendanceDate;
if (checkInHour >= 0 && checkInHour < 6) {
  const yesterday = new Date(now);
  yesterday.setDate(yesterday.getDate() - 1);
  attendanceDate = getLocalDateString(yesterday);
  console.log('✅ CORRECT: Hour', checkInHour, '→ Early morning → Using date:', attendanceDate);
} else {
  attendanceDate = getLocalDateString(now);
  console.log('Hour', checkInHour, '→ Normal hours → Using date:', attendanceDate);
}
"

echo ""
echo "============================================"
echo "Checking Database for Ron (employee_id=14)"
echo "============================================"
node -e "
const pool = require('./config/database');
(async () => {
  const conn = await pool.getConnection();
  try {
    const [records] = await conn.query(
      \`SELECT id, DATE(attendance_date) as date, check_in_time, check_out_time, status
       FROM Employee_Attendance 
       WHERE employee_id = 14 
       ORDER BY id DESC LIMIT 3\`
    );
    console.log('Recent attendance records:');
    records.forEach(r => {
      const d = new Date(r.date);
      const dateStr = \`\${d.getFullYear()}-\${String(d.getMonth()+1).padStart(2,'0')}-\${String(d.getDate()).padStart(2,'0')}\`;
      console.log(\`  \${dateStr}: Check-in \${r.check_in_time || 'N/A'}, Check-out \${r.check_out_time || 'OPEN'}, Status: \${r.status}\`);
    });
  } finally {
    conn.release();
    process.exit(0);
  }
})();
" 2>&1 | grep -v "Ignoring"

echo ""
echo "============================================"
echo "Test Complete"
echo "============================================"
