#!/bin/bash

TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjgsImVtcGxveWVlSWQiOjE0LCJlbWFpbCI6InJvbkBkaWdpb3VzLmNvbSIsIm5hbWUiOiJSb24iLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiTUQyIiwiaWF0IjoxNzY3NDQxNDYxLCJleHAiOjE3Njc1Mjc4NjF9.OUh0N5VIh8zNovZIg6LV8gU3YhP4NtzoVcS07N-gzKg"

curl -X POST http://localhost:5000/api/v1/attendance/check-in \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"email":"ron@digious.com","name":"Ron","employee_id":14,"device_info":"Mobile","ip_address":"192.168.1.100"}'
