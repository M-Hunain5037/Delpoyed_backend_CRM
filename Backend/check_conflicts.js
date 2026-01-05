const mysql = require('mysql2/promise');

async function checkConflicts() {
  const connection = await mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'Digious_CRM_DataBase'
  });

  console.log('\n=== CHECKING FOR CONFLICTS ===\n');

  // Check current test entries
  const [testRows] = await connection.query(`
    SELECT id, employee_id FROM employee_onboarding 
    WHERE employee_id LIKE 'TEST-%'
    ORDER BY id DESC LIMIT 5
  `);

  console.log('Latest TEST employees in employee_onboarding:');
  testRows.forEach(row => {
    console.log(`  ID: ${row.id}, Employee ID: ${row.employee_id}`);
  });

  // Check if any are in user_as_employees
  const [authRows] = await connection.query(`
    SELECT id, employee_id FROM user_as_employees 
    WHERE employee_id IN (SELECT id FROM employee_onboarding WHERE employee_id LIKE 'TEST-%')
    ORDER BY id DESC LIMIT 5
  `);

  console.log('\nSynced TEST employees in user_as_employees:');
  if (authRows.length === 0) {
    console.log('  None found (PROBLEM: Triggers not working)');
  } else {
    authRows.forEach(row => {
      console.log(`  ID: ${row.id}, Employee ID: ${row.employee_id}`);
    });
  }

  // Check ID 18 specifically
  console.log('\n=== Checking ID 18 ===');
  const [id18] = await connection.query(`
    SELECT * FROM user_as_employees WHERE employee_id = 18
  `);

  if (id18.length > 0) {
    console.log('Found in user_as_employees:');
    console.log(`  ID: ${id18[0].id}`);
    console.log(`  Employee ID: ${id18[0].employee_id}`);
    console.log(`  Name: ${id18[0].name}`);
    console.log(`  Email: ${id18[0].email}`);
  }

  await connection.end();
}

checkConflicts().catch(console.error);
