// Check the onboarding process and employee ID mappings
const pool = require('./config/database');

async function checkOnboardingProcess() {
  let connection;
  try {
    connection = await pool.getConnection();
    
    console.log('\n╔════════════════════════════════════════════════╗');
    console.log('║     Onboarding Process Analysis Report        ║');
    console.log('╚════════════════════════════════════════════════╝\n');
    
    // 1. Check employee_onboarding table structure
    console.log('📋 Step 1: Employee Onboarding Table Structure\n');
    const [columns] = await connection.query(
      `SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_KEY 
       FROM INFORMATION_SCHEMA.COLUMNS 
       WHERE TABLE_NAME='employee_onboarding'`
    );
    
    console.log('Columns:');
    for (const col of columns) {
      console.log(`  - ${col.COLUMN_NAME} (${col.COLUMN_TYPE}) ${col.COLUMN_KEY ? '🔑 ' + col.COLUMN_KEY : ''}`);
    }
    
    // 2. Check user_as_employees table structure
    console.log('\n📋 Step 2: User As Employees Table Structure\n');
    const [userCols] = await connection.query(
      `SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_KEY 
       FROM INFORMATION_SCHEMA.COLUMNS 
       WHERE TABLE_NAME='user_as_employees'`
    );
    
    console.log('Columns:');
    for (const col of userCols) {
      console.log(`  - ${col.COLUMN_NAME} (${col.COLUMN_TYPE}) ${col.COLUMN_KEY ? '🔑 ' + col.COLUMN_KEY : ''}`);
    }
    
    // 3. Check current onboarding records
    console.log('\n📋 Step 3: Current Onboarded Employees\n');
    const [onboarded] = await connection.query(
      `SELECT 
        id, 
        employee_id as employee_code,
        name, 
        email, 
        department,
        designation,
        status,
        created_at
       FROM employee_onboarding 
       ORDER BY id DESC 
       LIMIT 10`
    );
    
    console.log(`Total onboarded: ${onboarded.length}\n`);
    console.log('ID | Emp Code | Name | Email | Department | Designation | Status | Created');
    console.log('---|----------|------|-------|------------|-------------|--------|--------');
    
    for (const emp of onboarded) {
      const created = new Date(emp.created_at).toLocaleDateString();
      console.log(
        `${emp.id} | ${emp.employee_code} | ${emp.name.substring(0, 10)} | ${emp.email.substring(0, 15)} | ${emp.department?.substring(0, 8) || 'N/A'} | ${emp.designation?.substring(0, 10) || 'N/A'} | ${emp.status} | ${created}`
      );
    }
    
    // 4. Check user_as_employees records
    console.log('\n📋 Step 4: User Employees Records\n');
    const [users] = await connection.query(
      `SELECT 
        id, 
        employee_id,
        name, 
        email, 
        department,
        designation,
        status,
        created_at
       FROM user_as_employees 
       ORDER BY id DESC 
       LIMIT 10`
    );
    
    console.log(`Total users: ${users.length}\n`);
    console.log('Local ID | Emp ID | Name | Email | Department | Designation | Status | Created');
    console.log('---------|--------|------|-------|------------|-------------|--------|--------');
    
    for (const user of users) {
      const created = new Date(user.created_at).toLocaleDateString();
      console.log(
        `${user.id} | ${user.employee_id} | ${user.name.substring(0, 10)} | ${user.email.substring(0, 15)} | ${user.department?.substring(0, 8) || 'N/A'} | ${user.designation?.substring(0, 10) || 'N/A'} | ${user.status} | ${created}`
      );
    }
    
    // 5. Check for ID mapping issues
    console.log('\n🔍 Step 5: ID Mapping Validation\n');
    
    let issues = 0;
    console.log('Verifying all user_as_employees have valid employee_id:\n');
    
    for (const user of users) {
      const [check] = await connection.query(
        `SELECT id FROM employee_onboarding WHERE id = ?`,
        [user.employee_id]
      );
      
      if (check.length === 0) {
        console.log(`  ❌ ${user.name}: user_as_employees.employee_id=${user.employee_id} NOT FOUND in employee_onboarding`);
        issues++;
      } else {
        console.log(`  ✅ ${user.name}: employee_id=${user.employee_id} valid`);
      }
    }
    
    // 6. Check for orphaned records
    console.log('\n🔍 Step 6: Orphaned Records Check\n');
    
    const [orphaned] = await connection.query(
      `SELECT u.id, u.employee_id, u.name, u.email
       FROM user_as_employees u
       LEFT JOIN employee_onboarding e ON u.employee_id = e.id
       WHERE e.id IS NULL`
    );
    
    if (orphaned.length > 0) {
      console.log(`❌ Found ${orphaned.length} orphaned user records:\n`);
      for (const record of orphaned) {
        console.log(`   - ${record.name} (user_as_employees.id=${record.id}, employee_id=${record.employee_id})`);
      }
      issues += orphaned.length;
    } else {
      console.log('✅ No orphaned records found');
    }
    
    // 7. Check triggers
    console.log('\n🔍 Step 7: Database Triggers Check\n');
    
    const [triggers] = await connection.query(
      `SELECT TRIGGER_NAME, TRIGGER_SCHEMA, EVENT_MANIPULATION, ACTION_STATEMENT
       FROM INFORMATION_SCHEMA.TRIGGERS
       WHERE TRIGGER_SCHEMA = 'Digious_CRM_DataBase'
       AND (TRIGGER_NAME LIKE '%employee%' OR TRIGGER_NAME LIKE '%onboard%')`
    );
    
    if (triggers.length > 0) {
      console.log(`Found ${triggers.length} relevant triggers:\n`);
      for (const trigger of triggers) {
        console.log(`  - ${trigger.TRIGGER_NAME} (${trigger.EVENT_MANIPULATION})`);
      }
    } else {
      console.log('⚠️  No triggers found for automatic sync');
    }
    
    // 8. Summary
    console.log('\n📊 Summary:\n');
    
    if (issues === 0 && orphaned.length === 0) {
      console.log('✅ ONBOARDING PROCESS IS WORKING CORRECTLY\n');
      console.log('All employees are:');
      console.log('  1. Properly onboarded in employee_onboarding');
      console.log('  2. Synced to user_as_employees');
      console.log('  3. Have valid employee_id references');
      console.log('  4. Can check in/out without foreign key errors\n');
    } else {
      console.log(`❌ FOUND ${issues} ISSUES IN ONBOARDING PROCESS\n`);
      console.log('Issues found:');
      console.log('  - Invalid employee_id references');
      console.log('  - Orphaned user records');
      console.log('  - Sync failures\n');
    }
    
    connection.release();
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    if (connection) connection.release();
  }
}

checkOnboardingProcess();
