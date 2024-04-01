const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');

const app = express();
const port = 3500;

// Create MySQL connection pool
const pool = mysql.createPool({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'test'
});

// Middleware to parse JSON bodies
app.use(bodyParser.json());

// Route to get user balance
app.get('/user/:username/balance', (req, res) => {
  const username = req.params.username;
  pool.query('SELECT balance FROM users WHERE username = ?', [username], (err, results) => {
    if (err) {
      console.error('Error getting user balance:', err);
      return res.status(500).json({ error: 'Internal server error' });
    }
    if (results.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json({ balance: results[0].balance });
  });
});

// Route to update user balance
app.put('/user/:username/balance', (req, res) => {
  const username = req.params.username;
  const { balance } = req.body;
  if (isNaN(balance) || balance < 0) {
    return res.status(400).json({ error: 'Invalid balance value' });
  }
  pool.query('UPDATE users SET balance = ? WHERE username = ?', [balance, username], (err, results) => {
    if (err) {
      console.error('Error updating user balance:', err);
      return res.status(500).json({ error: 'Internal server error' });
    }
    if (results.affectedRows === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json({ message: 'User balance updated successfully' });
  });
});


// Route to update win, loss, and tie for a specific user
app.put('/users/:username/results', (req, res) => {
    const { wins, losses, ties } = req.body;
    const username = req.params.username;
    const query = 'UPDATE users SET wins = ?, losses = ?, ties = ? WHERE username = ?';
    pool.query(query, [wins, losses, ties, username], (error, results, fields) => {
      if (error) {
        console.error('Error updating user results:', error);
        res.status(500).send('Internal server error');
        return;
      }
      res.sendStatus(200);
    });
  });
  
  // Route to fetch win, loss, and tie for a specific user
  app.get('/users/:username/results', (req, res) => {
    const username = req.params.username;
    const query = 'SELECT wins, losses, ties FROM users WHERE username = ?';
    pool.query(query, [username], (error, results, fields) => {
      if (error) {
        console.error('Error fetching user results:', error);
        res.status(500).send('Internal server error');
        return;
      }
      if (results.length === 0) {
        res.status(404).send('User not found');
        return;
      }
      const { wins, losses, ties } = results[0];
      res.json({ wins, losses, ties });
    });
  });



  app.post('/api/results', (req, res) => {
    const { username, amount, iesResult, amountWon } = req.body;
    const insertQuery = `INSERT INTO results (username, amount, ies_result, amount_won) VALUES (?, ?, ?, ?)`;
    pool.query(insertQuery, [username, amount, iesResult, amountWon], (err, result) => {
      if (err) {
        console.error('Error storing result in MySQL: ', err);
        res.status(500).send('Error storing result.');
        return;
      }
      res.status(201).send('Result stored successfully.');
    });
  });
  
  // API endpoint to fetch all results for a specific username
  app.get('/api/results/:username', (req, res) => {
    const { username } = req.params;
    const selectQuery = `SELECT * FROM results WHERE username = ?`;
    pool.query(selectQuery, [username], (err, results) => {
      if (err) {
        console.error('Error fetching results from MySQL: ', err);
        res.status(500).send('Error fetching results.');
        return;
      }
      res.status(200).json(results);
    });
  });
    
app.listen(port, () => {
  console.log(`API server listening at http://localhost:${port}`);
});
