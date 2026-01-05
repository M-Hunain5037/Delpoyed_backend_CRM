# ✅ COMPLETE AUTHENTICATION SETUP - ALL CREDENTIALS & ENDPOINTS

## 📋 User Credentials

### Admin User
```
Email: admin@digious.com
Password: admin123
Role: Super Admin
Table: admin_users
```

### Employee Users
```
Email: muhammad.hunain@digious.com (DIG-001)
Password: karachi123
Department: Production
Table: user_as_employees

Email: MH@gmail.com (DIG-OO2)
Password: karachi123
Department: Production
Table: user_as_employees

Email: HR@gmail.com (DIG-004)
Password: karachi123
Department: HR
Table: user_as_employees

Email: helper@gmail.com (DIG-005)
Password: karachi123
Department: Marketing
Table: user_as_employees
```

---

## 🔄 Data Flow - Complete Journey

### 1️⃣ Employee Onboarding
```sql
INSERT INTO employee_onboarding 
(employee_id, name, email, password_temp, department, position, ...)
VALUES ('DIG-005', 'Helper', 'helper@gmail.com', '$hash', 'Marketing', 'MD', ...)

-- Result in DB
✓ Record created in employee_onboarding table with numeric ID = 9
✓ Trigger fires automatically
```

### 2️⃣ Trigger Auto-Sync
```sql
-- Trigger: after_employee_insert
-- Automatically runs after INSERT into employee_onboarding
INSERT INTO user_as_employees 
(employee_id, name, email, password, department, position, ...)
VALUES (9, 'Helper', 'helper@gmail.com', '$hash', 'Marketing', 'MD', ...)

-- Result in user_as_employees
✓ New record created for authentication
✓ request_password_change = 1 (force change on first login)
```

### 3️⃣ Password Reset by Admin
```sql
UPDATE employee_onboarding 
SET password_temp = '$newhash'
WHERE employee_id = 'DIG-005'

-- Trigger fires: after_employee_update
UPDATE user_as_employees
SET password = '$newhash',
    request_password_change = 1
WHERE employee_id = 9

-- Result
✓ Password updated in auth table
✓ User will be forced to change password
```

### 4️⃣ Login Process
```
POST /api/auth/login
  Body: {email: "helper@gmail.com", password: "karachi123"}
    ↓
  Query: SELECT * FROM user_as_employees WHERE email = ?
    ↓
  bcrypt.compare(password, user.password)
    ↓
  Generate JWT token
    ↓
  Return token + user data + requestPasswordChange flag
    ↓
  Frontend checks requestPasswordChange
    ├─ If TRUE  → Show password change form
    └─ If FALSE → Allow normal access
```

### 5️⃣ Password Change
```
PUT /api/auth/password
  Body: {newPassword: "newpass123"}
  Header: Authorization: Bearer TOKEN
    ↓
  Hash new password
    ↓
  UPDATE user_as_employees 
  SET password = '$hash', request_password_change = FALSE
    ↓
  User can login normally next time
```

---

## 🧪 Testing with cURL

### Start API Server First
```bash
cd /home/hunain/Desktop/Office/Digious_CRM/Backend
npm start

# Wait for:
# ✅ MySQL Database connected successfully
# 🚀 Server running on port 3001
```

### Test 1: Admin Login
```bash
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@digious.com","password":"admin123"}'

# Expected: 200 OK with token
```

### Test 2: Employee Login (HR)
```bash
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"HR@gmail.com","password":"karachi123"}'

# Expected: 200 OK with token
```

### Test 3: Employee Login (MH)
```bash
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"MH@gmail.com","password":"karachi123"}'

# Expected: 200 OK with token
```

### Test 4: Employee Login (DIG-001)
```bash
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"muhammad.hunain@digious.com","password":"karachi123"}'

# Expected: 200 OK with token
```

### Test 5: Employee Login (DIG-005)
```bash
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"helper@gmail.com","password":"karachi123"}'

# Expected: 200 OK with token
# NOTE: requestPasswordChange should be TRUE
```

### Test 6: Wrong Password (Should Fail)
```bash
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"HR@gmail.com","password":"wrongpassword"}'

# Expected: 401 Unauthorized
```

### Test 7: Password Change
```bash
# First get a token from login
TOKEN=$(curl -s -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"HR@gmail.com","password":"karachi123"}' | jq -r '.data.token')

# Then change password
curl -X PUT http://localhost:3001/api/auth/password \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"newPassword":"newpassword123"}'

# Expected: 200 OK
```

### Run All Tests Automatically
```bash
bash /home/hunain/Desktop/Office/Digious_CRM/Backend/test_all_endpoints.sh
```

---

## 📊 Database Structure

### admin_users Table
```
id              INT            Primary Key
email           VARCHAR(100)   Unique
password        VARCHAR(255)   bcrypt hash
full_name       VARCHAR(100)
phone           VARCHAR(20)
role            ENUM           admin, super_admin
status          ENUM           Active, Inactive
created_at      TIMESTAMP
updated_at      TIMESTAMP
```

**Current Data:**
| Email | Name | Role | Password |
|-------|------|------|----------|
| admin@digious.com | Administrator | super_admin | $2a$12$... (admin123) |

### employee_onboarding Table
```
id              INT            Primary Key (auto_increment)
employee_id     VARCHAR(20)    Unique (DIG-001, DIG-002, etc.)
name            VARCHAR(100)
email           VARCHAR(255)
password_temp   VARCHAR(255)   bcrypt hash
department      VARCHAR(100)
position        VARCHAR(100)
designation     VARCHAR(100)
status          ENUM           Active, Inactive
request_password_change TINYINT(1)
created_at      TIMESTAMP
updated_at      TIMESTAMP
```

**Current Data:**
| ID | Employee ID | Name | Email | Department | Password |
|----|-------------|------|-------|------------|----------|
| 1 | DIG-001 | Muhammad Hunain | muhammad.hunain@digious.com | Production | $2a$10$... (karachi123) |
| 2 | DIG-OO2 | MH | MH@gmail.com | Production | $2a$10$... (karachi123) |
| 3 | DIG-004 | HR | HR@gmail.com | HR | $2a$10$... (karachi123) |
| 9 | DIG-005 | Helper | helper@gmail.com | Marketing | $2a$10$... (karachi123) |

### user_as_employees Table (Authentication)
```
id              INT            Primary Key
employee_id     INT            FK to employee_onboarding.id
name            VARCHAR(100)   Synced from onboarding
email           VARCHAR(255)   Synced from onboarding
password        VARCHAR(255)   Synced from onboarding
department      VARCHAR(100)   Synced from onboarding
position        VARCHAR(100)   Synced from onboarding
designation     VARCHAR(100)   Synced from onboarding
status          ENUM           Synced from onboarding
request_password_change TINYINT(1) Force password change
login_count     INT            Number of logins
last_login_time DATETIME       Last login timestamp
created_at      TIMESTAMP
updated_at      TIMESTAMP
```

**Current Data (after sync):**
| ID | Employee ID (FK) | Name | Email | Department | Request Pwd Change |
|----|------------------|------|-------|------------|-------------------|
| 1 | 2 | MH | MH@gmail.com | Production | NO |
| 2 | 1 | Muhammad Hunain | muhammad.hunain@digious.com | Production | YES |
| 3 | 3 | HR | HR@gmail.com | HR | NO |
| 5 | 9 | Helper | helper@gmail.com | Marketing | YES |

---

## 🔐 Authentication Flow

### Step 1: Client sends login request
```
POST /api/auth/login
Content-Type: application/json

{
  "email": "HR@gmail.com",
  "password": "karachi123"
}
```

### Step 2: Backend validates credentials
```javascript
// authController.js - login function
1. Check if admin → Query admin_users table
2. If not admin → Query user_as_employees table
3. bcrypt.compare(password, hash) → Validate password
4. Generate JWT token
5. Record login info
6. Return token + user data
```

### Step 3: Response with token
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "userId": 3,
    "employeeId": 3,
    "name": "HR",
    "email": "HR@gmail.com",
    "department": "HR",
    "position": "HR",
    "role": "HR",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "requestPasswordChange": false
  }
}
```

### Step 4: Client stores token
```javascript
localStorage.setItem('authToken', response.data.token);
```

### Step 5: Check password change requirement
```javascript
if (response.data.requestPasswordChange) {
  // Redirect to change password page
  navigate('/change-password');
} else {
  // Allow normal access
  navigate('/dashboard');
}
```

---

## 🎯 Key Points

✅ **Dual Authentication System:**
- Admins authenticate via `admin_users` table
- Employees authenticate via `user_as_employees` table
- Automatic routing based on email

✅ **Automatic Data Sync:**
- Triggers automatically sync employee data
- No manual code needed for syncing
- Runs at database level (atomic)

✅ **Password Management:**
- All passwords hashed with bcrypt
- Temporary passwords set on onboarding
- Force password change on first login
- Admin can reset passwords anytime

✅ **Status & Tracking:**
- Request password change flag
- Login count tracking
- Last login timestamp
- Session token management

---

## 🚀 Quick Commands

### Start API
```bash
npm start
```

### Test All Endpoints
```bash
bash test_all_endpoints.sh
```

### Check Database Status
```bash
node check_database_structure.js
```

### Verify DIG-005 Sync
```bash
node verify_dig005_sync.js
```

### Reset All Passwords
```bash
node reset_all_passwords.js
```

---

## 📝 Summary

- ✅ All 4 employees synced to user_as_employees
- ✅ All passwords reset to working credentials
- ✅ Triggers active and working
- ✅ Admin user configured separately
- ✅ Authentication endpoints ready
- ✅ Password change flow implemented
- ✅ All endpoints tested with cURL

**System is fully operational and ready for login testing!**
