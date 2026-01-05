#!/bin/bash
# Quick Attendance API Testing
# Make sure backend is running on http://localhost:5000

echo "========================================="
echo "  Attendance API - cURL Test Commands"
echo "========================================="
echo ""

# Step 1: Login
echo "1️⃣  LOGIN (Get Token)"
echo "-----------------------------------"
echo "curl -X POST http://localhost:5000/api/v1/auth/login \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"email\": \"muhammad.hunain@digious.com\", \"password\": \"karachi123\"}'"
echo ""

TOKEN=$(curl -s -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "muhammad.hunain@digious.com", "password": "karachi123"}' | jq -r '.data.token')

if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
  echo "❌ Login failed!"
  exit 1
fi

echo "✅ Token: ${TOKEN:0:50}..."
echo ""
echo ""

# Step 2: Get Today's Attendance
echo "2️⃣  GET TODAY'S ATTENDANCE"
echo "-----------------------------------"
echo "curl -X GET http://localhost:5000/api/v1/attendance/today/1 \\"
echo "  -H 'Authorization: Bearer TOKEN'"
echo ""
curl -s -X GET "http://localhost:5000/api/v1/attendance/today/1" \
  -H "Authorization: Bearer $TOKEN" | jq '{
    success,
    attendance: .data | {
      date: .attendance_date,
      checkIn: .check_in_time,
      checkOut: .check_out_time,
      status,
      netWorkingMinutes: .net_working_time_minutes,
      overtimeHours: .overtime_hours,
      totalBreaks: .total_breaks_taken,
      breakDuration: .total_break_duration_minutes
    }
  }'
echo ""
echo ""

# Step 3: Check In (will fail if already checked in today)
echo "3️⃣  CHECK IN"
echo "-----------------------------------"
echo "curl -X POST http://localhost:5000/api/v1/attendance/check-in \\"
echo "  -H 'Authorization: Bearer TOKEN' \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{...}'"
echo ""
echo "Note: This will fail if already checked in today. Response:"
curl -s -X POST "http://localhost:5000/api/v1/attendance/check-in" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "employee_id": 1,
    "email": "muhammad.hunain@digious.com",
    "name": "Muhammad Hunain",
    "device_info": "Test Script",
    "ip_address": "127.0.0.1"
  }' | jq '.'
echo ""
echo ""

# Step 4: Record Break
echo "4️⃣  RECORD SMOKE BREAK (5 min)"
echo "-----------------------------------"
NOW=$(date +%H:%M:%S)
END=$(date -d "+5 minutes" +%H:%M:%S 2>/dev/null || date -v +5M +%H:%M:%S)
echo "curl -X POST http://localhost:5000/api/v1/attendance/break \\"
echo "  -H 'Authorization: Bearer TOKEN' \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{...}'"
echo ""
curl -s -X POST "http://localhost:5000/api/v1/attendance/break" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"employee_id\": 1,
    \"break_type\": \"Smoke\",
    \"break_start_time\": \"$NOW\",
    \"break_end_time\": \"$END\",
    \"break_duration_minutes\": 5
  }" | jq '.'
echo ""
echo ""

# Step 5: Get Monthly Attendance
echo "5️⃣  GET MONTHLY ATTENDANCE (January 2026)"
echo "-----------------------------------"
echo "curl -X GET http://localhost:5000/api/v1/attendance/monthly/1?year=2026&month=1 \\"
echo "  -H 'Authorization: Bearer TOKEN'"
echo ""
curl -s -X GET "http://localhost:5000/api/v1/attendance/monthly/1?year=2026&month=1" \
  -H "Authorization: Bearer $TOKEN" | jq '{
    success,
    totalRecords: (.data | length),
    records: .data | map({
      date: .attendance_date,
      status,
      checkIn: .check_in_time,
      checkOut: .check_out_time,
      hoursWorked: (.net_working_time_minutes / 60 | floor),
      overtime: .overtime_hours
    })
  }'
echo ""
echo ""

# Step 6: Check Out
echo "6️⃣  CHECK OUT"
echo "-----------------------------------"
echo "curl -X POST http://localhost:5000/api/v1/attendance/check-out \\"
echo "  -H 'Authorization: Bearer TOKEN' \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"employee_id\": 1}'"
echo ""
echo "Note: This will fail if already checked out. Response:"
curl -s -X POST "http://localhost:5000/api/v1/attendance/check-out" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"employee_id": 1}' | jq '.'
echo ""
echo ""

echo "========================================="
echo "✅ Test Complete!"
echo "========================================="
echo ""
echo "Available Break Types:"
echo "  - Smoke (5 min)"
echo "  - Dinner (60 min)"
echo "  - Washroom (10 min)"
echo "  - Prayer (10 min)"
echo ""
