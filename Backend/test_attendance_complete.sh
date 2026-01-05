#!/bin/bash

# Comprehensive Attendance API Test Script
# Tests all endpoints with proper error handling

echo "╔════════════════════════════════════════╗"
echo "║  Attendance API Comprehensive Test    ║"
echo "╚════════════════════════════════════════╝"
echo ""

BASE_URL="http://localhost:5000/api/v1"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to test endpoint
test_endpoint() {
    local test_name=$1
    local endpoint=$2
    local method=${3:-GET}
    local data=$4
    
    echo -e "${YELLOW}Testing:${NC} $test_name"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "$BASE_URL$endpoint")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" \
            -H "Content-Type: application/json" \
            -d "$data" \
            "$BASE_URL$endpoint")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        echo -e "${GREEN}✓ PASS${NC} (HTTP $http_code)"
        echo "$body" | jq '.' 2>/dev/null | head -20
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL${NC} (HTTP $http_code)"
        echo "$body" | jq '.' 2>/dev/null || echo "$body"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    echo ""
}

echo "═══════════════════════════════════════"
echo "  1. GET ALL ATTENDANCE RECORDS"
echo "═══════════════════════════════════════"
test_endpoint "Get all attendance (no filters)" "/attendance/all"
test_endpoint "Get all attendance (limit 10)" "/attendance/all?limit=10"
test_endpoint "Get all attendance (today)" "/attendance/all?date=$(date +%Y-%m-%d)"

echo "═══════════════════════════════════════"
echo "  2. GET TODAY'S ATTENDANCE"
echo "═══════════════════════════════════════"
test_endpoint "Get today's attendance for employee 1" "/attendance/today/1"
test_endpoint "Get today's attendance for employee 2" "/attendance/today/2"
test_endpoint "Get today's attendance for employee 3" "/attendance/today/3"

echo "═══════════════════════════════════════"
echo "  3. DATA INTEGRITY CHECKS"
echo "═══════════════════════════════════════"

echo -e "${YELLOW}Checking for orphaned breaks...${NC}"
orphaned=$(curl -s "$BASE_URL/attendance/all?limit=1000" | jq '[.data[] | select(.total_breaks_taken > 0 and (.breaks | length == 0))] | length')
if [ "$orphaned" -eq 0 ]; then
    echo -e "${GREEN}✓ No orphaned breaks found${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗ Found $orphaned orphaned break records${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
echo ""

echo -e "${YELLOW}Checking break count consistency...${NC}"
inconsistent=$(curl -s "$BASE_URL/attendance/all?limit=1000" | jq '[.data[] | select(.total_breaks_taken != (.smoke_break_count + .dinner_break_count + .washroom_break_count + .prayer_break_count))] | length')
if [ "$inconsistent" -eq 0 ]; then
    echo -e "${GREEN}✓ All break counts are consistent${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗ Found $inconsistent records with inconsistent break counts${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
echo ""

echo -e "${YELLOW}Checking break duration consistency...${NC}"
duration_issues=$(curl -s "$BASE_URL/attendance/all?limit=1000" | jq '[.data[] | select(.total_break_duration_minutes != (.smoke_break_duration_minutes + .dinner_break_duration_minutes + .washroom_break_duration_minutes + .prayer_break_duration_minutes))] | length')
if [ "$duration_issues" -eq 0 ]; then
    echo -e "${GREEN}✓ All break durations are consistent${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗ Found $duration_issues records with inconsistent break durations${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
echo ""

echo -e "${YELLOW}Checking working time calculations...${NC}"
working_time_issues=$(curl -s "$BASE_URL/attendance/all?limit=1000" | jq '[.data[] | select(.net_working_time_minutes != (.gross_working_time_minutes - .total_break_duration_minutes))] | length')
if [ "$working_time_issues" -eq 0 ]; then
    echo -e "${GREEN}✓ All working time calculations are correct${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗ Found $working_time_issues records with incorrect working time${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
echo ""

echo "═══════════════════════════════════════"
echo "  4. STATISTICS SUMMARY"
echo "═══════════════════════════════════════"

echo -e "${YELLOW}Generating statistics...${NC}"
curl -s "$BASE_URL/attendance/all?limit=1000" | jq '{
  total_records: (.data | length),
  present: [.data[] | select(.status == "Present")] | length,
  absent: [.data[] | select(.status == "Absent")] | length,
  late: [.data[] | select(.late_by_minutes > 0)] | length,
  on_time: [.data[] | select(.on_time == 1)] | length,
  total_breaks: [.data[] | .total_breaks_taken] | add,
  avg_working_hours: ([.data[] | .net_working_time_minutes] | add / length / 60 | floor * 100 / 100)
}'
echo ""

echo "═══════════════════════════════════════"
echo "  TEST SUMMARY"
echo "═══════════════════════════════════════"
echo -e "${GREEN}Tests Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Tests Failed: $TESTS_FAILED${NC}"
echo -e "Total Tests: $((TESTS_PASSED + TESTS_FAILED))"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}╔═══════════════════════════════╗${NC}"
    echo -e "${GREEN}║   ALL TESTS PASSED! ✓         ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════╝${NC}"
    exit 0
else
    echo -e "\n${RED}╔═══════════════════════════════╗${NC}"
    echo -e "${RED}║   SOME TESTS FAILED! ✗        ║${NC}"
    echo -e "${RED}╚═══════════════════════════════╝${NC}"
    exit 1
fi
