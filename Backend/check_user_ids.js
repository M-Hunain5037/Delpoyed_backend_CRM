const pool = require('./config/database');

async function checkUserIds() {
  const connection = await pool.getConnection();
  try {
    // Check the user_as_employees table
    const [users] = await connection.query(
      `SELECT id, employee_id, email, name FROM user_as_employees WHERE email = 'test1@gmail.com'`
    );
    
    console.log('\n📊 user_as_employees table:');
    console.log(users);
    
    // Check the employee_onboarding table
    if (users.length > 0 && users[0].employee_id) {
      const [employee] = await connection.query(
        `SELECT id, first_name, last_name, email FROM employee_onboarding WHERE id = ?`,
        [users[0].employee_id]
      );
      console.log('\n📊 employee_onboarding table (referenced):');
      console.log(employee);
    }
  } finally {
    connection.release();
    process.exit(0);
  }
}

checkUserIds().catch(err => {
  console.error('Error:', err);
  process.exit(1);
});
