const pool = require('./config/database');

async function check() {
  let connection;
  try {
    connection = await pool.getConnection();
    
    const [users] = await connection.query(
      `SELECT id, employee_id, email, name FROM user_as_employees WHERE name LIKE '%Raffay%'`
    );
    
    console.log('User found:', users[0]);
    
    connection.release();
  } catch (error) {
    console.error('Error:', error.message);
    if (connection) connection.release();
  }
}

check();
