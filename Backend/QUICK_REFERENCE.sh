#!/bin/bash

# ========================================
# QUICK REFERENCE - ALL LOGIN CREDENTIALS
# ========================================

cat << 'EOF'

╔═══════════════════════════════════════════════════════════════════════╗
║         AUTHENTICATION SYSTEM - QUICK REFERENCE CARD                  ║
╚═══════════════════════════════════════════════════════════════════════╝

┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ ADMIN LOGIN                                                          ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃ Email:    admin@digious.com                                         ┃
┃ Password: admin123                                                  ┃
┃ Role:     Super Admin                                               ┃
┃ Status:   ✅ Active                                                 ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃ cURL:                                                                ┃
┃ curl -X POST http://localhost:3001/api/auth/login \                 ┃
┃   -H "Content-Type: application/json" \                             ┃
┃   -d '{"email":"admin@digious.com","password":"admin123"}'           ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ EMPLOYEE LOGIN #1 - DIG-001                                          ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃ Employee ID:  DIG-001                                               ┃
┃ Name:         Muhammad Hunain                                       ┃
┃ Email:        muhammad.hunain@digious.com                           ┃
┃ Password:     karachi123                                            ┃
┃ Department:   Production                                            ┃
┃ Status:       ✅ Active | ⚠️ Pwd Change Required                     ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃ cURL:                                                                ┃
┃ curl -X POST http://localhost:3001/api/auth/login \                 ┃
┃   -H "Content-Type: application/json" \                             ┃
┃   -d '{"email":"muhammad.hunain@digious.com","password":"karachi123"}' ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ EMPLOYEE LOGIN #2 - DIG-OO2 (MH)                                     ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃ Employee ID:  DIG-OO2                                               ┃
┃ Name:         MH                                                    ┃
┃ Email:        MH@gmail.com                                          ┃
┃ Password:     karachi123                                            ┃
┃ Department:   Production                                            ┃
┃ Status:       ✅ Active                                             ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃ cURL:                                                                ┃
┃ curl -X POST http://localhost:3001/api/auth/login \                 ┃
┃   -H "Content-Type: application/json" \                             ┃
┃   -d '{"email":"MH@gmail.com","password":"karachi123"}'             ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ EMPLOYEE LOGIN #3 - DIG-004 (HR)                                     ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃ Employee ID:  DIG-004                                               ┃
┃ Name:         HR                                                    ┃
┃ Email:        HR@gmail.com                                          ┃
┃ Password:     karachi123                                            ┃
┃ Department:   HR                                                    ┃
┃ Status:       ✅ Active                                             ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃ cURL:                                                                ┃
┃ curl -X POST http://localhost:3001/api/auth/login \                 ┃
┃   -H "Content-Type: application/json" \                             ┃
┃   -d '{"email":"HR@gmail.com","password":"karachi123"}'             ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ EMPLOYEE LOGIN #4 - DIG-005 (Helper)                                 ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃ Employee ID:  DIG-005                                               ┃
┃ Name:         Helper                                                ┃
┃ Email:        helper@gmail.com                                      ┃
┃ Password:     karachi123                                            ┃
┃ Department:   Marketing                                             ┃
┃ Status:       ✅ Active | ⚠️ Pwd Change Required                     ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃ cURL:                                                                ┃
┃ curl -X POST http://localhost:3001/api/auth/login \                 ┃
┃   -H "Content-Type: application/json" \                             ┃
┃   -d '{"email":"helper@gmail.com","password":"karachi123"}'         ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

╔═══════════════════════════════════════════════════════════════════════╗
║ QUICK START STEPS                                                     ║
╠═══════════════════════════════════════════════════════════════════════╣
║                                                                       ║
║ 1. Start API Server:                                                 ║
║    cd /home/hunain/Desktop/Office/Digious_CRM/Backend                ║
║    npm start                                                         ║
║                                                                       ║
║ 2. Test One Login (Example - HR):                                    ║
║    curl -X POST http://localhost:3001/api/auth/login \               ║
║      -H "Content-Type: application/json" \                           ║
║      -d '{"email":"HR@gmail.com","password":"karachi123"}'           ║
║                                                                       ║
║ 3. Run All Tests (Automated):                                        ║
║    bash test_all_endpoints.sh                                        ║
║                                                                       ║
║ 4. View Detailed Documentation:                                      ║
║    CREDENTIALS_AND_ENDPOINTS.md                                      ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝

EOF
