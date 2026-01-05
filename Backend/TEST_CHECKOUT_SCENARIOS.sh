#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BASE_URL="http://localhost:3000/api/v1"
EMPLOYEE_ID=8
EMAIL="ron@digious.com"
NAME="Ron"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   CHECKOUT SCENARIOS TEST${NC}"
echo -e "${BLUE}================================================${NC}\n"

# Step 1: Login first to get token
echo -e "${YELLOW}Step 1: Logging in...${NC}"
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "ron@digious.com",
    "password": "Ron@12345"
  }')

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)
if [ -z "$TOKEN" ]; then
  echo -e "${RED}❌ Login failed${NC}"
  echo $LOGIN_RESPONSE
  exit 1
fi
echo -e "${GREEN}✅ Login successful${NC}"
echo -e "Token: $TOKEN\n"

# Step 2: Check current attendance status
echo -e "${YELLOW}Step 2: Checking current attendance status...${NC}"
curl -s -X GET "$BASE_URL/attendance/status/$EMPLOYEE_ID" \
  -H "Authorization: Bearer $TOKEN" | jq '.'
echo -e ""

# Step 3: Check in
echo -e "${YELLOW}Step 3: Checking in...${NC}"
CHECKIN_RESPONSE=$(curl -s -X POST "$BASE_URL/attendance/check-in" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"employee_id\": $EMPLOYEE_ID,
    \"email\": \"$EMAIL\",
    \"name\": \"$NAME\",
    \"device_info\": \"PC\",
    \"ip_address\": \"127.0.0.1\"
  }")

echo $CHECKIN_RESPONSE | jq '.'
echo -e ""

# Step 4: Check attendance after check-in
echo -e "${YELLOW}Step 4: Checking attendance after check-in...${NC}"
curl -s -X GET "$BASE_URL/attendance/status/$EMPLOYEE_ID" \
  -H "Authorization: Bearer $TOKEN" | jq '.'
echo -e ""

# Step 5: Logout WITHOUT checkout
echo -e "${YELLOW}Step 5: Logging out WITHOUT checkout (logout-no-checkout)...${NC}"
LOGOUT_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/logout-no-checkout" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"token\": \"$TOKEN\"}")

echo $LOGOUT_RESPONSE | jq '.'
echo -e ""

# Step 6: Check attendance after logout (should still be checked in)
echo -e "${YELLOW}Step 6: Checking attendance after logout (should STILL be checked in)...${NC}"
curl -s -X GET "$BASE_URL/attendance/status/$EMPLOYEE_ID" \
  -H "Authorization: Bearer $TOKEN" | jq '.'
echo -e ""

# Step 7: Login again
echo -e "${YELLOW}Step 7: Logging in again...${NC}"
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "ron@digious.com",
    "password": "Ron@12345"
  }')

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)
echo -e "${GREEN}✅ Login successful${NC}"
echo -e ""

# Step 8: Check attendance - THIS IS WHERE AUTO-CHECKOUT HAPPENS
echo -e "${YELLOW}Step 8: Checking attendance after second login...${NC}"
echo -e "${RED}⚠️ THIS IS WHERE AUTO-CHECKOUT HAPPENS (if stale record detected)${NC}"
curl -s -X GET "$BASE_URL/attendance/status/$EMPLOYEE_ID" \
  -H "Authorization: Bearer $TOKEN" | jq '.'
echo -e ""

# Step 9: Explicit checkout
echo -e "${YELLOW}Step 9: Performing explicit checkout...${NC}"
CHECKOUT_RESPONSE=$(curl -s -X POST "$BASE_URL/attendance/check-out" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"employee_id\": $EMPLOYEE_ID}")

echo $CHECKOUT_RESPONSE | jq '.'
echo -e ""

# Step 10: Final status
echo -e "${YELLOW}Step 10: Final attendance status...${NC}"
curl -s -X GET "$BASE_URL/attendance/status/$EMPLOYEE_ID" \
  -H "Authorization: Bearer $TOKEN" | jq '.'
echo -e ""

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   CHECKOUT SCENARIOS TEST COMPLETED${NC}"
echo -e "${BLUE}================================================${NC}"
