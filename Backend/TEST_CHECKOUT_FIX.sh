#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

BASE_URL="http://localhost:3000/api/v1"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          AUTO-CHECKOUT BUG FIX - COMPREHENSIVE TEST             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}\n"

# Test Case 1: Login
echo -e "${CYAN}═══ TEST 1: LOGIN WITH EMPLOYEE 8 (RON) ═══${NC}\n"
LOGIN=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "ron@digious.com",
    "password": "karachi123"
  }')

TOKEN=$(echo $LOGIN | jq -r '.data.token // empty')
EMPLOYEE_ID=$(echo $LOGIN | jq -r '.data.userId // empty')

if [ -z "$TOKEN" ]; then
  echo -e "${RED}❌ LOGIN FAILED${NC}"
  echo $LOGIN | jq '.'
  exit 1
fi

echo -e "${GREEN}✅ LOGIN SUCCESSFUL${NC}"
echo -e "Employee ID: $EMPLOYEE_ID"
echo -e "Token: ${TOKEN:0:20}...${TOKEN: -10}\n"

# Test Case 2: Check current status
echo -e "${CYAN}═══ TEST 2: CHECK CURRENT ATTENDANCE STATUS ═══${NC}\n"
STATUS=$(curl -s -X GET "$BASE_URL/attendance/status/$EMPLOYEE_ID" \
  -H "Authorization: Bearer $TOKEN")
echo $STATUS | jq '.'
echo ""

# Test Case 3: Check In
echo -e "${CYAN}═══ TEST 3: CHECK IN ═══${NC}\n"
CHECKIN=$(curl -s -X POST "$BASE_URL/attendance/check-in" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"employee_id\": $EMPLOYEE_ID,
    \"email\": \"ron@digious.com\",
    \"name\": \"Ron\",
    \"device_info\": \"PC\",
    \"ip_address\": \"127.0.0.1\"
  }")

CHECKIN_SUCCESS=$(echo $CHECKIN | jq -r '.success')
CHECKIN_ID=$(echo $CHECKIN | jq -r '.data.id // empty')

if [ "$CHECKIN_SUCCESS" = "true" ]; then
  echo -e "${GREEN}✅ CHECK IN SUCCESSFUL${NC}"
  echo -e "Record ID: $CHECKIN_ID"
  echo $CHECKIN | jq '.data'
else
  echo -e "${RED}❌ CHECK IN FAILED${NC}"
  echo $CHECKIN | jq '.'
fi
echo ""

# Test Case 4: Logout WITHOUT checkout
echo -e "${CYAN}═══ TEST 4: LOGOUT WITHOUT CHECKOUT (logout-no-checkout) ═══${NC}\n"
LOGOUT=$(curl -s -X POST "$BASE_URL/auth/logout-no-checkout" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"token\": \"$TOKEN\"}")

echo $LOGOUT | jq '.'
echo ""

# Test Case 5: Try to check in WITHOUT proper checkout
echo -e "${CYAN}═══ TEST 5: ATTEMPT RE-LOGIN & CHECK-IN (SHOULD FAIL WITH NEW MESSAGE) ═══${NC}\n"
echo -e "${YELLOW}Attempting to check in again without checking out...${NC}\n"

# Re-login
LOGIN2=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "ron@digious.com",
    "password": "karachi123"
  }')

TOKEN2=$(echo $LOGIN2 | jq -r '.data.token // empty')
if [ -z "$TOKEN2" ]; then
  echo -e "${RED}❌ RE-LOGIN FAILED${NC}"
  exit 1
fi
echo -e "${GREEN}✅ RE-LOGIN SUCCESSFUL${NC}\n"

# Try to check in again - THIS SHOULD FAIL NOW (NOT auto-checkout)
CHECKIN2=$(curl -s -X POST "$BASE_URL/attendance/check-in" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN2" \
  -d "{
    \"employee_id\": $EMPLOYEE_ID,
    \"email\": \"ron@digious.com\",
    \"name\": \"Ron\",
    \"device_info\": \"PC\",
    \"ip_address\": \"127.0.0.1\"
  }")

CHECKIN2_SUCCESS=$(echo $CHECKIN2 | jq -r '.success')
CHECKIN2_MESSAGE=$(echo $CHECKIN2 | jq -r '.message')

echo -e "${YELLOW}Response:${NC}"
echo $CHECKIN2 | jq '.'
echo ""

if [ "$CHECKIN2_SUCCESS" = "false" ]; then
  echo -e "${GREEN}✅ CORRECT! Check-in FAILED as expected${NC}"
  echo -e "${GREEN}   Message: $CHECKIN2_MESSAGE${NC}"
  echo -e "${GREEN}   This prevents auto-checkout - user MUST check out first${NC}\n"
else
  echo -e "${RED}❌ ERROR! Check-in succeeded when it should have failed${NC}"
  echo -e "${RED}   Auto-checkout may have occurred${NC}\n"
fi

# Test Case 6: Explicit checkout
echo -e "${CYAN}═══ TEST 6: EXPLICIT CHECKOUT ═══${NC}\n"
CHECKOUT=$(curl -s -X POST "$BASE_URL/attendance/check-out" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN2" \
  -d "{\"employee_id\": $EMPLOYEE_ID}")

CHECKOUT_SUCCESS=$(echo $CHECKOUT | jq -r '.success')
echo $CHECKOUT | jq '.'

if [ "$CHECKOUT_SUCCESS" = "true" ]; then
  echo -e "${GREEN}✅ CHECKOUT SUCCESSFUL${NC}"
else
  echo -e "${RED}❌ CHECKOUT FAILED${NC}"
fi
echo ""

# Test Case 7: Verify final status
echo -e "${CYAN}═══ TEST 7: VERIFY FINAL STATUS (SHOULD SHOW CHECKED OUT) ═══${NC}\n"
FINAL_STATUS=$(curl -s -X GET "$BASE_URL/attendance/status/$EMPLOYEE_ID" \
  -H "Authorization: Bearer $TOKEN2")
echo $FINAL_STATUS | jq '.'
echo ""

# Summary
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                      TEST SUMMARY                              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}\n"

echo -e "${MAGENTA}Expected Behavior:${NC}"
echo -e "  ✅ Test 1: Login succeeds"
echo -e "  ✅ Test 2: Status shows not checked in"
echo -e "  ✅ Test 3: Check-in succeeds"
echo -e "  ✅ Test 4: Logout without checkout succeeds"
echo -e "  ✅ Test 5: Re-login & check-in attempt FAILS (prevents auto-checkout!)"
echo -e "  ✅ Test 6: Explicit checkout succeeds"
echo -e "  ✅ Test 7: Final status shows checked out\n"

echo -e "${MAGENTA}Key Points:${NC}"
echo -e "  • Auto-checkout only happens if record is 24+ hours old"
echo -e "  • User logging out and back in same shift will NOT auto-checkout"
echo -e "  • User MUST call explicit checkout endpoint"
echo -e "  • Next day check-in will auto-complete previous day if still open\n"

echo -e "${GREEN}✅ AUTO-CHECKOUT BUG FIX TEST COMPLETE${NC}\n"
