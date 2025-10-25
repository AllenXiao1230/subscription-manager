// ./backend/src/server.js

const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

// 測試 API
app.get('/api', (req, res) => {
  res.send('後端 API 運作中! 資料庫已連線。');
});

// --- 新增 API 端點 ---

// 獲取所有訂閱項目
app.get('/api/subscriptions', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM subscriptions');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send('查詢資料庫時發生錯誤');
  }
});

// 新增一個訂閱項目
app.post('/api/subscriptions', async (req, res) => {
  const { name, total_price, payment_owner_id } = req.body;
  if (!name || !total_price) {
    return res.status(400).send('名稱和價格為必填項。');
  }

  try {
    const result = await pool.query(
      'INSERT INTO subscriptions (name, total_price, payment_owner_id) VALUES ($1, $2, $3) RETURNING *',
      [name, total_price, payment_owner_id || 1] // 預設 owner 是 1
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).send('新增資料時發生錯誤');
  }
});

app.listen(port, () => {
  console.log(`後端伺服器正在 http://localhost:${port} 運行`);
});