const pool = require('./config/database');

async function checkTableStructure() {
  let connection;
  try {
    connection = await pool.getConnection();
    
    const [constraints] = await connection.query(`
      SELECT CONSTRAINT_NAME, COLUMN_NAME, CONSTRAINT_TYPE
      FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
      WHERE TABLE_NAME = 'Employee_Attendance' AND TABLE_SCHEMA = 'Digious_CRM_DataBase'
    `);
    
    console.log('🔍 Employee_Attendance Constraints:');
    console.log(JSON.stringify(constraints, null, 2));
    
    connection.release();
  } catch (error) {
    console.error('Error:', error);
  }
}

checkTableStructure();