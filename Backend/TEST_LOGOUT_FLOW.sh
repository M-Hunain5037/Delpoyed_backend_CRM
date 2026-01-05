#!/bin/bash

BASE_URL="http://localhost:5000/api/v1"
EMAIL="ron@digious.com"
PASSWORD="karachi123"

echo "Logging in as $EMAIL..."
LOGIN=$(curl -s -X POST "$BASE_URL/auth/login" -H "Content-Type: application/json" -d "{\"email\": \"$EMAIL\", \"password\": \"$PASSWORD\"}")
TOKEN=$(echo "$LOGIN" | jq -r '.data.token // empty')
USERID=$(echo "$LOGIN" | jq -r '.data.userId // empty')

if [ -z "$TOKEN" ]; then
  echo "Login failed:"; echo "$LOGIN" | jq '.'; exit 1
fi

echo "✅ Login successful. Token: ${TOKEN:0:20}..."

# Call logout-no-checkout
echo "Calling logout-no-checkout..."
LOGOUT=$(curl -s -X POST "$BASE_URL/auth/logout-no-checkout" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "{\"token\": \"$TOKEN\"}")
echo "$LOGOUT" | jq '.'

# Try to call a protected endpoint with the same token after logout - should fail
echo "\nAttempting protected call (attendance status) with the SAME token after logout - should be rejected..."
PROTECTED_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$BASE_URL/attendance/status/$USERID" -H "Authorization: Bearer $TOKEN")
echo "Protected call HTTP status: $PROTECTED_RESPONSE"

# Check DB for user_system_info latest record
echo "Checking DB for latest user_system_info entry for userId $USERID..."
node -e "const pool=require('./config/database');(async()=>{const conn=await pool.getConnection();const [r]=await conn.query('SELECT id,session_token,login_time,logout_time,is_active FROM user_system_info WHERE employee_id = ? ORDER BY id DESC LIMIT 1',[${USERID}]);console.log(r);conn.release();process.exit(0);})();"
