#!/bin/bash

# Test script to verify employee ID mapping is correct

echo "╔════════════════════════════════════════╗"
echo "║  Employee ID Mapping Verification     ║"
echo "╚════════════════════════════════════════╝"
echo ""

BASE_URL="http://localhost:5000/api/v1"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "═══════════════════════════════════════"
echo "  1. LOGIN TEST FOR RAFFAY AHMED"
echo "═══════════════════════════════════════"

echo -e "${YELLOW}Logging in raffay.ahmed@digious.com...${NC}"
login_response=$(curl -s -w "\n%{http_code}" -X POST \
  -H "Content-Type: application/json" \
  -d '{"email":"raffay.ahmed@digious.com","password":"Test@1234"}' \
  "$BASE_URL/auth/login")

login_code=$(echo "$login_response" | tail -n1)
login_body=$(echo "$login_response" | sed '$d')

if [ "$login_code" -eq 200 ]; then
    echo -e "${GREEN}✓ Login successful${NC}"
    
    # Extract token
    token=$(echo "$login_body" | jq -r '.data.token')
    userId=$(echo "$login_body" | jq -r '.data.userId')
    echo "Token: ${token:0:20}..."
    echo "Response:"
    echo "$login_body" | jq '.'
    
    echo ""
    echo "═══════════════════════════════════════"
    echo "  2. CHECK-IN TEST WITH JWT TOKEN"
    echo "═══════════════════════════════════════"
    
    echo -e "${YELLOW}Attempting check-in for Raffay Ahmed...${NC}"
    checkin_response=$(curl -s -w "\n%{http_code}" -X POST \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $token" \
      -d '{
        "employee_id": 6,
        "email": "raffay.ahmed@digious.com",
        "name": "Raffay Ahmed"
      }' \
      "$BASE_URL/attendance/check-in")
    
    checkin_code=$(echo "$checkin_response" | tail -n1)
    checkin_body=$(echo "$checkin_response" | sed '$d')
    
    if [ "$checkin_code" -eq 200 ] || [ "$checkin_code" -eq 409 ]; then
        echo -e "${GREEN}✓ Check-in processed (HTTP $checkin_code)${NC}"
        echo "$checkin_body" | jq '.'
        
        # Check the actual employee_id used
        if echo "$checkin_body" | grep -q '"employee_id":12'; then
            echo -e "${GREEN}✅ CORRECT: Used employee_id=12 (from JWT)${NC}"
        elif echo "$checkin_body" | grep -q '"employee_id":6'; then
            echo -e "${RED}✗ WRONG: Used employee_id=6 instead of 12${NC}"
        fi
    else
        echo -e "${RED}✗ Check-in failed (HTTP $checkin_code)${NC}"
        echo "$checkin_body" | jq '.'
        
        # Check for foreign key error
        if echo "$checkin_body" | grep -q "foreign key constraint"; then
            echo -e "${RED}   ❌ Foreign key error - still using wrong employee_id${NC}"
        fi
    fi
else
    echo -e "${RED}✗ Login failed (HTTP $login_code)${NC}"
    echo "$login_body" | jq '.'
fi

echo ""
echo "═══════════════════════════════════════"
echo "  3. DATABASE VERIFICATION"
echo "═══════════════════════════════════════"

echo -e "${YELLOW}Verifying employee IDs in database...${NC}"
echo "Raffay Ahmed should have:"
echo "  - user_as_employees.id = 6"
echo "  - user_as_employees.employee_id = 12"
echo "  - employee_onboarding.id = 12"
echo "  - Employee_Attendance.employee_id = 12"