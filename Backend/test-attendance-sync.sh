#!/bin/bash

# ============================================================
# ATTENDANCE DATA SYNC TEST SCRIPT
# ============================================================
# This script tests the attendance API endpoints
# Update: API_URL, TOKEN, and EMPLOYEE_ID as needed
# ============================================================

# Configuration
API_URL="http://localhost:5000/api/v1"
EMPLOYEE_ID="3"  # Your employee ID (Fatima Khan)
TOKEN="your_jwt_token_here"  # Replace with your actual JWT token

echo "============================================================"
echo "ATTENDANCE API TEST - Data Sync Verification"
echo "============================================================"
echo ""
echo "Configuration:"
echo "  - API URL: $API_URL"
echo "  - Employee ID: $EMPLOYEE_ID"
echo "  - Token: ${TOKEN:0:20}... (truncated)"
echo ""

# ============================================================
# Test 1: Get Today's Attendance Record
# ============================================================
echo "Test 1: Fetching Today's Attendance Record"
echo "----------"
echo "Endpoint: GET /attendance/today/:employee_id"
echo "Command:"
echo "curl -X GET \"$API_URL/attendance/today/$EMPLOYEE_ID\" \\"
echo "  -H \"Authorization: Bearer $TOKEN\" \\"
echo "  -H \"Content-Type: application/json\""
echo ""
echo "Response:"
curl -s -X GET "$API_URL/attendance/today/$EMPLOYEE_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | jq '.'
echo ""
echo ""

# ============================================================
# Test 2: Get All Attendance Records (for this employee)
# ============================================================
echo "Test 2: Getting All Attendance Records"
echo "----------"
echo "Endpoint: GET /attendance/all"
echo "Command:"
echo "curl -s -X GET \"$API_URL/attendance/all\" | jq '.data[] | select(.employee_id == $EMPLOYEE_ID)'"
echo ""
echo "Response (filtered for your employee):"
curl -s -X GET "$API_URL/attendance/all" | jq '.data[] | select(.employee_id == '$EMPLOYEE_ID')' | head -50
echo ""
echo ""

# ============================================================
# Test 3: Get Monthly Attendance
# ============================================================
echo "Test 3: Getting Monthly Attendance (January 2026)"
echo "----------"
echo "Endpoint: GET /attendance/monthly/:employee_id"
echo "Command:"
echo "curl -s -X GET \"$API_URL/attendance/monthly/$EMPLOYEE_ID\" \\"
echo "  -H \"Authorization: Bearer $TOKEN\""
echo ""
echo "Response:"
curl -s -X GET "$API_URL/attendance/monthly/$EMPLOYEE_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | jq '.'
echo ""
echo ""

# ============================================================
# Test 4: Get Attendance Summary
# ============================================================
echo "Test 4: Getting Attendance Summary"
echo "----------"
echo "Endpoint: GET /attendance/summary"
echo "Command:"
echo "curl -s -X GET \"$API_URL/attendance/summary\" \\"
echo "  -H \"Authorization: Bearer $TOKEN\""
echo ""
echo "Response:"
curl -s -X GET "$API_URL/attendance/summary" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | jq '.data[] | select(.employee_id == '$EMPLOYEE_ID')' | head -30
echo ""
echo ""

# ============================================================
# Database Direct Check (optional - requires database access)
# ============================================================
echo "Test 5: Direct Database Check (if database is accessible)"
echo "----------"
echo "Run this SQL query to check the database:"
echo ""
echo "SELECT * FROM Employee_Attendance"
echo "WHERE employee_id = $EMPLOYEE_ID"
echo "AND attendance_date = DATE(CURDATE())"
echo "ORDER BY created_at DESC;"
echo ""
echo "============================================================"
echo "END OF TESTS"
echo "============================================================"
