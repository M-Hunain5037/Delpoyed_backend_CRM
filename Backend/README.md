# Digious CRM Backend

Employee CRM with onboarding system built with Node.js and Express.

## Setup Instructions

### 1. Install Dependencies
```bash
cd Backend
npm install
```

### 2. Configure Database
- Create database: `Digious_CRM_DataBase`
- Import SQL file: `Database/Digious_CRM_DataBase.sql`
- Update `.env` file with your database credentials

### 3. Environment Configuration
Create `.env` file in Backend directory:
```
DB_HOST=localhost
DB_PORT=3306
DB_NAME=Digious_CRM_DataBase
DB_USER=root
DB_PASSWORD=

PORT=5000
NODE_ENV=development
CORS_ORIGIN=http://localhost:3000

JWT_SECRET=your_secret_key
JWT_EXPIRY=24h

API_VERSION=v1
API_TIMEOUT=30000
```

### 4. Start Server
```bash
# Development (with nodemon)
npm run dev

# Production
npm start
```

Server will run on `http://localhost:5000`

## API Endpoints

### Base URL
```
http://localhost:5000/api/v1
```

### Employee Onboarding

#### 1. Create Employee (Onboard)
**POST** `/employees`

Request body:
```json
{
  "employeeId": "EMP001",
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "phone": "+1234567890",
  "cnic": "12345-6789012-3",
  "department": "Sales",
  "position": "Sales Executive",
  "joinDate": "2025-01-15",
  "baseSalary": 50000,
  "allowances": [
    {
      "name": "Housing",
      "amount": 5000
    },
    {
      "name": "Transportation",
      "amount": 2000
    }
  ],
  "address": "123 Main St, City",
  "emergencyContact": "+1987654321",
  "bankAccount": "123456789",
  "taxId": "TAX123",
  "designation": "Senior Executive",
  "laptop": true,
  "laptopSerial": "DELL123",
  "charger": true,
  "chargerSerial": "CHAR001",
  "mouse": true,
  "mouseSerial": "MOUSE001",
  "mobile": true,
  "mobileSerial": "MOB001",
  "keyboard": false,
  "monitor": true,
  "monitorSerial": "MON001",
  "dynamicResources": [
    {
      "name": "Headphones",
      "serial": "HEAD001"
    }
  ],
  "resourcesNote": "Resources issued on joining"
}
```

Response:
```json
{
  "success": true,
  "message": "Employee onboarded successfully",
  "data": {
    "id": 1,
    "employeeId": "EMP001",
    "name": "John Doe",
    "email": "john@example.com",
    "department": "Sales",
    "position": "Sales Executive",
    "status": "Active"
  }
}
```

#### 2. Get All Employees
**GET** `/employees`

Response:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "employee_id": "EMP001",
      "name": "John Doe",
      "email": "john@example.com",
      "department": "Sales",
      "position": "Sales Executive",
      "base_salary": 50000,
      "total_salary": 57000,
      "status": "Active",
      "created_at": "2025-01-15T10:00:00Z"
    }
  ],
  "total": 1
}
```

#### 3. Get Employee by ID
**GET** `/employees/:id`

Response:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "employee_id": "EMP001",
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1234567890",
    "cnic": "12345-6789012-3",
    "department": "Sales",
    "position": "Sales Executive",
    "join_date": "2025-01-15",
    "address": "123 Main St, City",
    "base_salary": 50000,
    "total_salary": 57000,
    "allowances": [
      {
        "name": "Housing",
        "amount": 5000
      },
      {
        "name": "Transportation",
        "amount": 2000
      }
    ],
    "resources": {
      "laptop": true,
      "laptop_serial": "DELL123",
      "charger": true,
      "mouse": true,
      "mobile": true,
      "monitor": true,
      "resources_note": "Resources issued on joining"
    },
    "dynamicResources": [
      {
        "id": 1,
        "name": "Headphones",
        "serial": "HEAD001"
      }
    ],
    "onboardingProgress": {
      "employee_id": 1,
      "is_completed": true,
      "overall_completion_percentage": 100
    }
  }
}
```

#### 4. Update Employee
**PUT** `/employees/:id`

Request body:
```json
{
  "phone": "+1111111111",
  "address": "New Address",
  "status": "Inactive"
}
```

Response:
```json
{
  "success": true,
  "message": "Employee updated successfully"
}
```

#### 5. Delete Employee
**DELETE** `/employees/:id`

Response:
```json
{
  "success": true,
  "message": "Employee deleted successfully"
}
```

#### 6. Get Onboarding Progress
**GET** `/employees/:id/progress`

Response:
```json
{
  "success": true,
  "data": {
    "employee_id": 1,
    "step_1_basic_info": true,
    "step_2_security_setup": true,
    "step_3_job_details": true,
    "step_4_allowances": true,
    "step_5_additional_info": true,
    "step_6_review_confirm": true,
    "is_completed": true,
    "overall_completion_percentage": 100,
    "completed_at": "2025-01-15T10:00:00Z"
  }
}
```

## Folder Structure

```
Backend/
├── index.js                          # Main server file
├── package.json                      # Dependencies
├── .env                              # Environment variables
├── config/
│   └── database.js                   # Database connection
├── middleware/
│   └── auth.js                       # Authentication middleware
├── routes/
│   ├── onboarding.js                # Onboarding routes
│   └── controllers/
│       └── onboardingController.js   # Onboarding logic
├── utils/
│   └── helpers.js                    # Helper functions
└── Database/
    └── Digious_CRM_DataBase.sql      # Database schema
```

## Database Schema

### Tables
- `employee_onboarding` - Main employee data
- `employee_salary` - Salary and compensation
- `employee_allowances` - Employee allowances
- `employee_resources` - Predefined resources (laptop, mouse, etc.)
- `employee_dynamic_resources` - Custom resources
- `onboarding_progress` - Onboarding progress tracking

## Technologies Used

- **Node.js** - Runtime environment
- **Express.js** - Web framework
- **MySQL2** - Database driver
- **bcryptjs** - Password hashing
- **jsonwebtoken** - JWT authentication
- **cors** - CORS handling
- **dotenv** - Environment variables

## Error Handling

All endpoints return standardized error responses:

```json
{
  "success": false,
  "message": "Error message",
  "error": "Detailed error (only in development)"
}
```

## Development

Run with nodemon for auto-reload:
```bash
npm run dev
```

## Testing

Test endpoint connectivity:
```bash
curl http://localhost:5000/api/health
```

## Notes

- Passwords are hashed using bcryptjs before storing
- Foreign key constraints ensure data integrity
- All employee deletions cascade to related records
- Onboarding progress is automatically tracked
