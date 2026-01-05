#!/bin/bash

# Attendance API Testing Script
# Usage: ./test_attendance_api.sh

BASE_URL="http://localhost:5000/api/v1/attendance"
EMPLOYEE_ID=2

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Attendance API Testing${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# First, login to get token
echo -e "${YELLOW}Step 1: Login to get authentication token${NC}"
echo "curl -X POST http://localhost:5000/api/v1/auth/login"
echo ""

LOGIN_RESPONSE=$(curl -s -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "ron@digious.com",
    "password": "Pass@123"
  }')

echo "$LOGIN_RESPONSE" | jq '.'

TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.token // .data.token // empty')

if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
  echo -e "${RED}❌ Login failed. Please check credentials.${NC}"
  echo ""
  echo "Try with your actual credentials:"
  echo "curl -X POST http://localhost:5000/api/v1/auth/login -H \"Content-Type: application/json\" -d '{\"email\":\"your@email.com\",\"password\":\"yourpassword\"}'"
  echo ""
  exit 1
fi

echo -e "${GREEN}✅ Login successful! Token obtained.${NC}"
echo ""
sleep 1

# Test 1: Get Today's Attendance
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}Test 1: Get Today's Attendance${NC}"
echo "curl -X GET ${BASE_URL}/today/${EMPLOYEE_ID}"
echo ""

curl -s -X GET "${BASE_URL}/today/${EMPLOYEE_ID}" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" | jq '.'

echo ""
sleep 1

# Test 2: Check In
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}Test 2: Check In${NC}"
echo "curl -X POST ${BASE_URL}/check-in"
echo ""

curl -s -X POST "${BASE_URL}/check-in" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{
    \"employee_id\": ${EMPLOYEE_ID},
    \"email\": \"ron@digious.com\",
    \"name\": \"Ron\",
    \"device_info\": \"Test Device\",
    \"ip_address\": \"127.0.0.1\"
  }" | jq '.'

echo ""
sleep 1

# Test 3: Get Today's Attendance (after check-in)
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}Test 3: Get Today's Attendance (after check-in)${NC}"
echo ""

curl -s -X GET "${BASE_URL}/today/${EMPLOYEE_ID}" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" | jq '.'

echo ""
sleep 1

# Test 4: Record Smoke Break
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}Test 4: Record Smoke Break (5 min)${NC}"
echo ""

NOW=$(date +%H:%M:%S)
BREAK_END=$(date -d "+5 minutes" +%H:%M:%S)

curl -s -X POST "${BASE_URL}/break" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{
    \"employee_id\": ${EMPLOYEE_ID},
    \"break_type\": \"Smoke\",
    \"break_start_time\": \"${NOW}\",
    \"break_end_time\": \"${BREAK_END}\",
    \"break_duration_minutes\": 5
  }" | jq '.'

echo ""
sleep 1

# Test 5: Record Dinner Break
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}Test 5: Record Dinner Break (60 min)${NC}"
echo ""

NOW=$(date +%H:%M:%S)
BREAK_END=$(date -d "+60 minutes" +%H:%M:%S)

curl -s -X POST "${BASE_URL}/break" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{
    \"employee_id\": ${EMPLOYEE_ID},
    \"break_type\": \"Dinner\",
    \"break_start_time\": \"${NOW}\",
    \"break_end_time\": \"${BREAK_END}\",
    \"break_duration_minutes\": 60
  }" | jq '.'

echo ""
sleep 1

# Test 6: Get Today's Attendance (after breaks)
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}Test 6: Get Today's Attendance (after breaks)${NC}"
echo ""

curl -s -X GET "${BASE_URL}/today/${EMPLOYEE_ID}" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" | jq '.'

echo ""
sleep 1

# Test 7: Check Out
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}Test 7: Check Out${NC}"
echo ""

curl -s -X POST "${BASE_URL}/check-out" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{
    \"employee_id\": ${EMPLOYEE_ID}
  }" | jq '.'

echo ""
sleep 1

# Test 8: Get Monthly Attendance
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}Test 8: Get Monthly Attendance${NC}"
echo ""

CURRENT_YEAR=$(date +%Y)
CURRENT_MONTH=$(date +%-m)

curl -s -X GET "${BASE_URL}/monthly/${EMPLOYEE_ID}?year=${CURRENT_YEAR}&month=${CURRENT_MONTH}" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" | jq '.'

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ All tests completed!${NC}"
echo -e "${BLUE}========================================${NC}"
