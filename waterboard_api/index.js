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
  server: 'PRASAD_CHANDIMA\\SQLEXPRESS', // e.g., 'localhost'
  database: 'waterDB',
  options: {
    encrypt: false, // true for Azure
    trustServerCertificate: true,
  },
};

// Signup endpoint
app.post('/signup', async (req, res) => {
  const { customerId, name, mobile, password } = req.body;
  try {
    await sql.connect(config);
    await sql.query`
      INSERT INTO [user] (customer_id, name, mobile, password)
      VALUES (${parseInt(customerId)}, ${name}, ${mobile}, ${password})
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

// Submit meter endpoint
app.post('/submit-meter', async (req, res) => {
  const { customerId, currentMeter } = req.body;
  try {
    await sql.connect(config);

    // Check if record exists
    const checkResult = await sql.query`
      SELECT * FROM user_lstmonth_details WHERE customer_id = ${parseInt(customerId)}
    `;

    if (checkResult.recordset.length > 0) {
      // Save the current_meter as previous_meter before updating
      const prevCurrent = checkResult.recordset[0].current_meter || 0;
      await sql.query`
        UPDATE user_lstmonth_details
        SET previous_meter = ${prevCurrent}, current_meter = ${currentMeter}
        WHERE customer_id = ${parseInt(customerId)}
      `;
      res.json({ success: true, message: 'Meter updated' });
    } else {
      // Insert new record
      await sql.query`
        INSERT INTO user_lstmonth_details (customer_id, previous_meter, current_meter)
        VALUES (${parseInt(customerId)}, 0, ${currentMeter})
      `;
      res.json({ success: true, message: 'Meter inserted' });
    }
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// Get meter details endpoint
app.get('/meter-details/:customerId', async (req, res) => {
  const customerId = req.params.customerId;
  try {
    await sql.connect(config);
    const result = await sql.query`
      SELECT previous_meter, current_meter
      FROM user_lstmonth_details
      WHERE customer_id = ${parseInt(customerId)}
    `;
    if (result.recordset.length > 0) {
      res.json({ success: true, data: result.recordset[0] });
    } else {
      res.json({ success: true, data: null });
    }
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.listen(3000, () => console.log('API running on port 3000'));

