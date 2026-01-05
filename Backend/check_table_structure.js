const mysql = require('mysql2/promise');

async function checkTableStructure() {
  const connection = await mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'Digious_CRM_DataBase'
  });

  console.log('\n=== EMPLOYEE_ONBOARDING TABLE ===');
  const [onboardingCols] = await connection.query(`
    SHOW COLUMNS FROM employee_onboarding
  `);
  console.table(onboardingCols);

  console.log('\n=== USER_AS_EMPLOYEES TABLE ===');
  const [authCols] = await connection.query(`
    SHOW COLUMNS FROM user_as_employees
  `);
  console.table(authCols);

  console.log('\n=== UNIQUE CONSTRAINTS/KEYS ===');
  const [constraints] = await connection.query(`
    SELECT CONSTRAINT_NAME, COLUMN_NAME 
    FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE TABLE_NAME IN ('employee_onboarding', 'user_as_employees')
    AND CONSTRAINT_NAME NOT IN ('PRIMARY')
    ORDER BY TABLE_NAME
  `);
  console.table(constraints);

  await connection.end();
}

checkTableStructure().catch(console.error);
