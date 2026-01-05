#!/bin/bash

# Test Script for Checkout Bug Fix and Absent Record Generation
echo "╔════════════════════════════════════════╗"
echo "║  Testing Checkout Bug Fix & Absent    ║"
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
echo "  1. TEST SAME-DAY CHECKOUT BUG FIX"
echo "═══════════════════════════════════════"

echo -e "${YELLOW}Step 1: Check-in for employee 2...${NC}"
checkin_response=$(curl -s -w "\n%{http_code}" -X POST \
  -H "Content-Type: application/json" \
  -d '{"employee_id":2,"email":"ahmed.ali@digious.com","name":"Ahmed Ali"}' \
  "$BASE_URL/attendance/check-in")

checkin_code=$(echo "$checkin_response" | tail -n1)
checkin_body=$(echo "$checkin_response" | sed '$d')

if [ "$checkin_code" -eq 200 ]; then
    echo -e "${GREEN}✓ Check-in successful${NC}"
    echo "$checkin_body" | jq '.'
else
    echo -e "${RED}✗ Check-in failed (HTTP $checkin_code)${NC}"
    echo "$checkin_body"
fi

echo ""
echo -e "${YELLOW}Step 2: Immediate checkout (within seconds)...${NC}"
sleep 2  # Wait 2 seconds

checkout_response=$(curl -s -w "\n%{http_code}" -X POST \
  -H "Content-Type: application/json" \
  -d '{"employee_id":2}' \
  "$BASE_URL/attendance/check-out")

checkout_code=$(echo "$checkout_response" | tail -n1)
checkout_body=$(echo "$checkout_response" | sed '$d')

if [ "$checkout_code" -eq 200 ]; then
    echo -e "${GREEN}✓ Check-out successful${NC}"
    
    # Extract working time from response
    working_minutes=$(echo "$checkout_body" | jq -r '.data.gross_working_time_minutes')
    working_hours=$(echo "scale=2; $working_minutes / 60" | bc)
    
    echo "$checkout_body" | jq '.'
    echo ""
    echo -e "${BLUE}Analysis:${NC}"
    echo -e "   Working Time: ${working_minutes} minutes (${working_hours} hours)"
    
    # Check if it's reasonable (should be just a few minutes, not 24 hours)
    if [ "$working_minutes" -lt 60 ]; then
        echo -e "   ${GREEN}✓ BUG FIXED: Same-day checkout calculated correctly${NC}"
    else
        echo -e "   ${RED}✗ BUG STILL EXISTS: Working time too high for immediate checkout${NC}"
    fi
else
    echo -e "${RED}✗ Check-out failed (HTTP $checkout_code)${NC}"
    echo "$checkout_body"
fi

echo ""
echo "═══════════════════════════════════════"
echo "  2. GENERATE ABSENT RECORDS"
echo "═══════════════════════════════════════"

echo -e "${YELLOW}Generating absent records from joining dates...${NC}"
absent_response=$(curl -s -w "\n%{http_code}" -X POST \
  -H "Content-Type: application/json" \
  "$BASE_URL/attendance/generate-absent")

absent_code=$(echo "$absent_response" | tail -n1)
absent_body=$(echo "$absent_response" | sed '$d')

if [ "$absent_code" -eq 200 ]; then
    echo -e "${GREEN}✓ Absent records generated successfully${NC}"
    echo "$absent_body" | jq '.'
    
    # Extract stats
    processed=$(echo "$absent_body" | jq -r '.data.processed')
    created=$(echo "$absent_body" | jq -r '.data.created')
    
    echo ""
    echo -e "${BLUE}Summary:${NC}"
    echo -e "   Employees Processed: ${processed}"
    echo -e "   Absent Records Created: ${created}"
else
    echo -e "${RED}✗ Failed to generate absent records (HTTP $absent_code)${NC}"
    echo "$absent_body"
fi

echo ""
echo "═══════════════════════════════════════"
echo "  3. VERIFY ABSENT RECORDS IN DATABASE"
echo "═══════════════════════════════════════"

echo -e "${YELLOW}Checking total absent records...${NC}"
all_attendance=$(curl -s "$BASE_URL/attendance/all?limit=1000")
absent_count=$(echo "$all_attendance" | jq '[.data[] | select(.status == "Absent")] | length')
present_count=$(echo "$all_attendance" | jq '[.data[] | select(.status == "Present")] | length')
total_count=$(echo "$all_attendance" | jq '.data | length')

echo -e "${BLUE}Database Statistics:${NC}"
echo -e "   Present Records: ${present_count}"
echo -e "   Absent Records: ${absent_count}"
echo -e "   Total Records: ${total_count}"

if [ "$absent_count" -gt 0 ]; then
    echo -e "   ${GREEN}✓ Absent records found in database${NC}"
    
    # Show sample absent records
    echo ""
    echo -e "${YELLOW}Sample Absent Records:${NC}"
    echo "$all_attendance" | jq '.data[] | select(.status == "Absent") | {employee_id, name, attendance_date, status}' | head -20
else
    echo -e "   ${YELLOW}! No absent records found${NC}"
fi

echo ""
echo "═══════════════════════════════════════"
echo "  TEST COMPLETE"
echo "═══════════════════════════════════════"