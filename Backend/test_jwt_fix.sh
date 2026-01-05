#!/bin/bash

# Quick test to verify the fix works

echo "Testing Employee ID Mapping Fix"
echo "================================"
echo ""

BASE_URL="http://localhost:5000/api/v1"

# Test 1: Login with existing employee
echo "TEST 1: Login with Muhammad Hunain (employee_id=1)"
login=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{"email":"muhammad.hunain@digious.com","password":"Hunain@1234"}' \
  "$BASE_URL/auth/login")

token=$(echo "$login" | jq -r '.data.token // empty')
if [ -z "$token" ]; then
  echo "❌ Login failed"
  echo "$login" | jq '.'
  exit 1
fi

echo "✅ Login successful"
echo "JWT Token contains:"
echo "$login" | jq '.data | {userId, name, email}'

# Extract employeeId from token (decode JWT)
payload=$(echo "$token" | cut -d'.' -f2 | base64 -d 2>/dev/null | jq '.')
echo ""
echo "JWT Payload:"
echo "$payload" | jq '.'

# Test 2: Check-in with JWT token (should use employeeId from JWT, not request body)
echo ""
echo "TEST 2: Check-in with request body employee_id=999 (should be ignored)"
echo "Expected: Should use employeeId from JWT token"

checkin=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $token" \
  -d '{
    "employee_id": 999,
    "email": "muhammad.hunain@digious.com",
    "name": "Muhammad Hunain"
  }' \
  "$BASE_URL/attendance/check-in")

echo "Response:"
echo "$checkin" | jq '.'

# Check if it succeeded
if echo "$checkin" | jq -e '.success' > /dev/null 2>&1; then
  echo ""
  echo "✅ Check-in successful!"
  echo "The system correctly handled the employee_id mapping"
else
  if echo "$checkin" | jq -e '.error | contains("foreign key")' > /dev/null 2>&1; then
    echo ""
    echo "❌ Foreign key error - still using wrong employee_id from request"
    echo "Need to ensure middleware is extracting JWT correctly"
  fi
fi
