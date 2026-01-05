#!/bin/bash

echo "=========================================="
echo "Attendance API Verification Script"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test 1: Get all attendance records
echo -e "${BLUE}Test 1: Fetching all attendance records...${NC}"
RESPONSE=$(curl -s "http://localhost:5000/api/v1/attendance/all?limit=1000")
TOTAL_RECORDS=$(echo $RESPONSE | jq -r '.data | length')
echo -e "${GREEN}✓ Total Records: $TOTAL_RECORDS${NC}"
echo ""

# Test 2: Get today's attendance
echo -e "${BLUE}Test 2: Fetching today's attendance...${NC}"
TODAY=$(date +%Y-%m-%d)
TODAY_COUNT=$(echo $RESPONSE | jq -r "[.data[] | select(.attendance_date | startswith(\"$TODAY\"))] | length")
echo -e "${GREEN}✓ Today's Records: $TODAY_COUNT${NC}"
echo ""

# Test 3: Count by status
echo -e "${BLUE}Test 3: Count by attendance status...${NC}"
PRESENT=$(echo $RESPONSE | jq -r '[.data[] | select(.status == "Present")] | length')
ABSENT=$(echo $RESPONSE | jq -r '[.data[] | select(.status == "Absent")] | length')
LATE=$(echo $RESPONSE | jq -r '[.data[] | select(.late_by_minutes > 0)] | length')
ON_TIME=$(echo $RESPONSE | jq -r '[.data[] | select(.on_time == 1)] | length')

echo -e "${GREEN}✓ Present: $PRESENT${NC}"
echo -e "${RED}✓ Absent: $ABSENT${NC}"
echo -e "${YELLOW}✓ Late: $LATE${NC}"
echo -e "${GREEN}✓ On Time: $ON_TIME${NC}"
echo ""

# Test 4: Active vs Inactive
echo -e "${BLUE}Test 4: Active vs Inactive employees...${NC}"
ACTIVE=$(echo $RESPONSE | jq -r '[.data[] | select(.check_out_time == null and .status == "Present")] | length')
INACTIVE=$(echo $RESPONSE | jq -r '[.data[] | select(.check_out_time != null or .status == "Absent")] | length')
echo -e "${GREEN}✓ Active (Currently Working): $ACTIVE${NC}"
echo -e "${YELLOW}✓ Inactive (Checked Out/Absent): $INACTIVE${NC}"
echo ""

# Test 5: Break statistics
echo -e "${BLUE}Test 5: Break statistics...${NC}"
TOTAL_BREAKS=$(echo $RESPONSE | jq -r '[.data[] | .total_breaks_taken] | add')
AVG_BREAKS=$(echo $RESPONSE | jq -r '[.data[] | .total_breaks_taken] | add / length | floor')
echo -e "${GREEN}✓ Total Breaks Taken: $TOTAL_BREAKS${NC}"
echo -e "${GREEN}✓ Average Breaks per Employee: $AVG_BREAKS${NC}"
echo ""

# Test 6: Working time statistics
echo -e "${BLUE}Test 6: Working time statistics...${NC}"
AVG_WORK_MINUTES=$(echo $RESPONSE | jq -r '[.data[] | .net_working_time_minutes] | add / length | floor')
AVG_WORK_HOURS=$(echo "scale=1; $AVG_WORK_MINUTES / 60" | bc)
echo -e "${GREEN}✓ Average Working Time: $AVG_WORK_HOURS hours${NC}"
echo ""

# Test 7: Data integrity checks
echo -e "${BLUE}Test 7: Data integrity checks...${NC}"
ORPHANED_BREAKS=$(echo $RESPONSE | jq -r '[.data[] | select(.total_breaks_taken > 0 and (.breaks | length == 0))] | length')
BREAK_COUNT_MISMATCH=$(echo $RESPONSE | jq -r '[.data[] | select(.total_breaks_taken != (.smoke_break_count + .dinner_break_count + .washroom_break_count + .prayer_break_count))] | length')
BREAK_DURATION_MISMATCH=$(echo $RESPONSE | jq -r '[.data[] | select(.total_break_duration_minutes != (.smoke_break_duration_minutes + .dinner_break_duration_minutes + .washroom_break_duration_minutes + .prayer_break_duration_minutes))] | length')
WORK_TIME_MISMATCH=$(echo $RESPONSE | jq -r '[.data[] | select(.net_working_time_minutes != (.gross_working_time_minutes - .total_break_duration_minutes))] | length')

if [ $ORPHANED_BREAKS -eq 0 ] && [ $BREAK_COUNT_MISMATCH -eq 0 ] && [ $BREAK_DURATION_MISMATCH -eq 0 ] && [ $WORK_TIME_MISMATCH -eq 0 ]; then
    echo -e "${GREEN}✓ All data integrity checks PASSED${NC}"
    echo -e "${GREEN}  - No orphaned breaks: $ORPHANED_BREAKS${NC}"
    echo -e "${GREEN}  - No break count mismatches: $BREAK_COUNT_MISMATCH${NC}"
    echo -e "${GREEN}  - No break duration mismatches: $BREAK_DURATION_MISMATCH${NC}"
    echo -e "${GREEN}  - No working time mismatches: $WORK_TIME_MISMATCH${NC}"
else
    echo -e "${RED}✗ Data integrity issues found:${NC}"
    echo -e "${RED}  - Orphaned breaks: $ORPHANED_BREAKS${NC}"
    echo -e "${RED}  - Break count mismatches: $BREAK_COUNT_MISMATCH${NC}"
    echo -e "${RED}  - Break duration mismatches: $BREAK_DURATION_MISMATCH${NC}"
    echo -e "${RED}  - Working time mismatches: $WORK_TIME_MISMATCH${NC}"
fi
echo ""

# Test 8: Sample records
echo -e "${BLUE}Test 8: Sample attendance records...${NC}"
echo $RESPONSE | jq -r '.data[0:3] | .[] | "Employee: \(.name), Date: \(.attendance_date), Status: \(.status), Check-in: \(.check_in_time), Check-out: \(.check_out_time // "Not yet"), Breaks: \(.total_breaks_taken)"'
echo ""

# Test 9: Attendance by date range
echo -e "${BLUE}Test 9: This week's attendance count...${NC}"
WEEK_START=$(date -d "last monday" +%Y-%m-%d 2>/dev/null || date -v-monday +%Y-%m-%d 2>/dev/null || echo "2026-01-01")
THIS_WEEK=$(echo $RESPONSE | jq -r "[.data[] | select(.attendance_date >= \"$WEEK_START\")] | length")
echo -e "${GREEN}✓ This Week's Records: $THIS_WEEK${NC}"
echo ""

# Test 10: Department breakdown (if available)
echo -e "${BLUE}Test 10: Unique employees...${NC}"
UNIQUE_EMPLOYEES=$(echo $RESPONSE | jq -r '[.data[] | .name] | unique | length')
echo -e "${GREEN}✓ Unique Employees: $UNIQUE_EMPLOYEES${NC}"
echo ""

echo "=========================================="
echo -e "${GREEN}API Verification Complete!${NC}"
echo "=========================================="
