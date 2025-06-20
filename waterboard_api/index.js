const express = require('express');
const sql = require('mssql');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// SQL Server config
const config = {
  user: 'sa',
  password: '123456',
  server: 'PRASAD_CHANDIMA\\SQLEXPRESS',
  database: 'waterDB',
  options: {
    encrypt: false, // Set to true if using Azure
    trustServerCertificate: true,
  },
};

// Signup endpoint
app.post('/signup', async (req, res) => {
  const { customerId, name, mobile, password } = req.body;
  try {
    await sql.connect(config);
    const result = await sql.query`
      INSERT INTO [user] (customer_id, name, mobile, password)
      VALUES (${customerId}, ${name}, ${mobile}, ${password})
    `;
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// Login endpoint
app.post('/login', async (req, res) => {
  const { userInput, password } = req.body;
  try {
    await sql.connect(config);
    const result = await sql.query`
      SELECT * FROM [user]
      WHERE (customer_id = ${userInput} OR mobile = ${userInput}) AND password = ${password}
    `;
    if (result.recordset.length > 0) {
      res.json({ success: true, user: result.recordset[0] });
    } else {
      res.json({ success: false, message: 'Invalid credentials' });
    }
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.listen(3000, () => console.log('API running on port 3000'));