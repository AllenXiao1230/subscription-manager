// ./backend/src/server.js
const { spawn } = require('child_process');
const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const fs = require('fs');         // (NEW) 用於刪除暫存檔
const multer = require('multer'); // (NEW) 用於處理上傳

const app = express();
const port = 3000;

const upload = multer({ dest: '/tmp/uploads/' });

app.use(cors());
app.use(express.json());

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

// --- Members API ---
app.get('/api/members', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM members ORDER BY id');
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching members:', err);
    res.status(500).json({ error: 'Error fetching members' });
  }
});
app.post('/api/members', async (req, res) => {
  const { name } = req.body;
  if (!name || name.trim() === '') {
    return res.status(400).json({ error: 'Member name is required.' });
  }
  try {
    // 插入新成員 (允許同名，但 email 是 null)
    const result = await pool.query(
      'INSERT INTO members (name) VALUES ($1) RETURNING *',
      [name.trim()]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating member:', err);
    res.status(500).json({ error: 'Error creating member' });
  }
});
// --- Subscriptions API ---

// (READ) 獲取所有訂閱項目
app.get('/api/subscriptions', async (req, res) => {
  try {
    const query = `
      SELECT s.*, m.name as owner_name, 
             TO_CHAR(s.next_payment_date, 'YYYY-MM-DD') as next_payment_date
      FROM subscriptions s
      LEFT JOIN members m ON s.payment_owner_id = m.id
      ORDER BY s.id
    `;
    const result = await pool.query(query);
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching subscriptions:', err);
    res.status(500).json({ error: '查詢資料庫時發生錯誤' });
  }
});

// (CREATE) 新增訂閱項目
app.post('/api/subscriptions', async (req, res) => {
  const { name, total_price, billing_cycle, next_payment_date, payment_owner_id } = req.body;
  if (!name || total_price === undefined) {
    return res.status(400).json({ error: '名稱和價格為必填項。' });
  }
  const nextPaymentDate = next_payment_date || null;
  const ownerId = payment_owner_id || null;
  try {
    const result = await pool.query(
      `INSERT INTO subscriptions (name, total_price, billing_cycle, next_payment_date, payment_owner_id) 
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [name, total_price, billing_cycle, nextPaymentDate, ownerId]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error adding subscription:', err);
    res.status(500).json({ error: '新增資料時發生錯誤' });
  }
});

// (UPDATE) 更新訂閱項目
app.put('/api/subscriptions/:id', async (req, res) => {
  const { id } = req.params;
  const { name, total_price, billing_cycle, next_payment_date, payment_owner_id } = req.body;
  const nextPaymentDate = next_payment_date || null;
  const ownerId = payment_owner_id || null;
  try {
    const result = await pool.query(
      `UPDATE subscriptions 
       SET name = $1, total_price = $2, billing_cycle = $3, next_payment_date = $4, payment_owner_id = $5
       WHERE id = $6 RETURNING *`,
      [name, total_price, billing_cycle, nextPaymentDate, ownerId, id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Subscription not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error updating subscription:', err);
    res.status(500).json({ error: '更新資料時發生錯誤' });
  }
});

// (DELETE) 刪除訂閱項目
app.delete('/api/subscriptions/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM subscriptions WHERE id = $1', [id]);
    res.status(204).send();
  } catch (err) {
    console.error('Error deleting subscription:', err);
    res.status(500).json({ error: '刪除資料時發生錯誤' });
  }
});

// --- Subscription Members API ---

// (READ) 獲取特定訂閱的所有成員
app.get('/api/subscriptions/:id/members', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(
      `SELECT m.id, m.name, sm.share_amount 
       FROM members m
       JOIN subscription_members sm ON m.id = sm.member_id
       WHERE sm.subscription_id = $1
       ORDER BY m.id`,
      [id]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Error fetching members' });
  }
});

// (CREATE) 新增成員到訂閱中 (UPDATED: 不再需要 share_amount)
app.post('/api/subscriptions/:id/members', async (req, res) => {
  const { id: subscription_id } = req.params;
  const { member_id } = req.body; // 不再需要 share_amount
  if (!member_id) {
    return res.status(400).json({ error: 'Member ID is required.' });
  }
  try {
    // 插入時，share_amount 預設為 0
    const result = await pool.query(
      'INSERT INTO subscription_members (subscription_id, member_id, share_amount) VALUES ($1, $2, 0) RETURNING *',
      [subscription_id, member_id]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    if (err.code === '23505') { // 23505 = unique_violation
      return res.status(409).json({ error: 'Member is already in this subscription.' });
    }
    console.error('Error adding member to subscription:', err);
    res.status(500).json({ error: 'Error adding member' });
  }
});

// (DELETE) 從訂閱中移除成員
app.delete('/api/subscriptions/:id/members/:member_id', async (req, res) => {
  const { id: subscription_id, member_id } = req.params;
  try {
    await pool.query(
      'DELETE FROM subscription_members WHERE subscription_id = $1 AND member_id = $2',
      [subscription_id, member_id]
    );
    res.status(204).send();
  } catch (err) {
    console.error('Error removing member from subscription:', err);
    res.status(500).json({ error: 'Error removing member' });
  }
});

// --- (NEW) 自動均分 API ---
app.post('/api/subscriptions/:id/recalculate', async (req, res) => {
  const { id: subscription_id } = req.params;
  const client = await pool.connect(); // 使用 transaction 確保資料一致性
  try {
    await client.query('BEGIN');

    // 1. 取得總價格
    const subRes = await client.query('SELECT total_price FROM subscriptions WHERE id = $1', [subscription_id]);
    if (subRes.rows.length === 0) {
      throw new Error('Subscription not found');
    }
    const total_price = parseFloat(subRes.rows[0].total_price);

    // 2. 計算總人數
    const countRes = await client.query('SELECT COUNT(*) as member_count FROM subscription_members WHERE subscription_id = $1', [subscription_id]);
    const member_count = parseInt(countRes.rows[0].member_count, 10);

    if (member_count === 0) {
      await client.query('COMMIT');
      return res.status(200).json({ message: 'No members to update.' });
    }

    // 3. 計算新均分金額 (保留 2 位小數)
    const new_share_amount = (total_price / member_count).toFixed(2);

    // 4. 更新所有成員的均分金額
    await client.query(
      'UPDATE subscription_members SET share_amount = $1 WHERE subscription_id = $2',
      [new_share_amount, subscription_id]
    );

    await client.query('COMMIT');
    res.status(200).json({ new_share_amount: new_share_amount });

  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Error recalculating shares:', err);
    res.status(500).json({ error: 'Error recalculating shares' });
  } finally {
    client.release();
  }
});


// --- Payments API (無變動) ---

app.get('/api/subscriptions/:id/payments', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(
      'SELECT * FROM payments WHERE subscription_id = $1',
      [id]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Error fetching payments' });
  }
});

app.post('/api/payments', async (req, res) => {
  const { subscription_id, member_id, amount_paid, billing_period } = req.body;
  if (!subscription_id || !member_id || !amount_paid || !billing_period) {
    return res.status(400).json({ error: 'Missing required fields' });
  }
  try {
    const result = await pool.query(
      `INSERT INTO payments (subscription_id, member_id, amount_paid, payment_date, billing_period)
       VALUES ($1, $2, $3, CURRENT_DATE, $4) 
       ON CONFLICT (subscription_id, member_id, billing_period) DO NOTHING 
       RETURNING *`,
      [subscription_id, member_id, amount_paid, billing_period]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error logging payment:', err);
    res.status(500).json({ error: 'Error logging payment' });
  }
});

app.delete('/api/payments', async (req, res) => {
  const { subscription_id, member_id, billing_period } = req.body;
  if (!subscription_id || !member_id || !billing_period) {
    return res.status(400).json({ error: 'Missing required fields' });
  }
  try {
    await pool.query(
      'DELETE FROM payments WHERE subscription_id = $1 AND member_id = $2 AND billing_period = $3',
      [subscription_id, member_id, billing_period]
    );
    res.status(204).send();
  } catch (err) {
    console.error('Error deleting payment:', err);
    res.status(500).json({ error: 'Error deleting payment' });
  }
});

app.get('/api/export', (req, res) => {
  // 設定回應標頭，告訴瀏覽器這是一個要下載的檔案
  const filename = `backup_${new Date().toISOString().slice(0, 10)}.sql`;
  res.setHeader('Content-Type', 'application/octet-stream');
  res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);

  // 設定 pg_dump 需要的環境變數 (密碼必須透過環境變數傳遞)
  const env = { ...process.env, PGPASSWORD: process.env.DB_PASSWORD };

  // 執行 pg_dump 指令
  const pg_dump = spawn('pg_dump', [
    '-h', process.env.DB_HOST,
    '-U', process.env.DB_USER,
    '-d', process.env.DB_NAME,
    '--clean' // 加入 DROP TABLE 指令，方便還原
  ], { env });

  // 將 pg_dump 的輸出直接 "串流" (pipe) 到 HTTP 回應中
  pg_dump.stdout.pipe(res);

  // 錯誤處理
  pg_dump.stderr.on('data', (data) => {
    console.error(`pg_dump error: ${data}`);
  });
  pg_dump.on('error', (err) => {
    console.error('Failed to spawn pg_dump:', err);
    if (!res.headersSent) res.status(500).send('Export failed');
  });
});

// (IMPORT) 匯入資料庫 SQL
// 'backup_file' 必須與前端 FormData 的欄位名稱一致
app.post('/api/import', upload.single('backup_file'), async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No file uploaded' });
  }

  console.log(`Starting import from file: ${req.file.path}`);

  // 設定環境變數 (密碼)
  const env = { ...process.env, PGPASSWORD: process.env.DB_PASSWORD };

  // 執行 psql 指令
  const psql = spawn('psql', [
    '-h', process.env.DB_HOST,
    '-U', process.env.DB_USER,
    '-d', process.env.DB_NAME,
    // '-f' 參數讓 psql 直接讀取檔案
    '-f', req.file.path
  ], { env });

  // 監聽執行結果
  psql.on('close', (code) => {
    // 無論成功失敗，都刪除暫存的上傳檔案
    fs.unlink(req.file.path, (err) => {
      if (err) console.error('Failed to delete temp file:', err);
    });

    if (code === 0) {
      console.log('Database import successful');
      res.json({ message: 'Import successful' });
    } else {
      console.error(`psql exited with code ${code}`);
      res.status(500).json({ error: 'Import failed' });
    }
  });

  // 捕捉錯誤輸出
  psql.stderr.on('data', (data) => {
    console.error(`psql error: ${data}`);
  });
});

// 啟動伺服器
app.listen(port, '0.0.0.0', () => {
  console.log(`後端伺服器正在 http://localhost:${port} 運行`);
});

