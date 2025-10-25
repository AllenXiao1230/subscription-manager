-- ./db_init/init.sql

-- 1. 建立資料表
CREATE TABLE IF NOT EXISTS members (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE
);

CREATE TABLE IF NOT EXISTS subscriptions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    billing_cycle VARCHAR(50) DEFAULT 'monthly',
    next_payment_date DATE,
    payment_owner_id INTEGER REFERENCES members(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS subscription_members (
    subscription_id INTEGER REFERENCES subscriptions(id) ON DELETE CASCADE,
    member_id INTEGER REFERENCES members(id) ON DELETE CASCADE,
    share_amount DECIMAL(10, 2),
    PRIMARY KEY (subscription_id, member_id)
);

CREATE TABLE IF NOT EXISTS payments (
    id SERIAL PRIMARY KEY,
    subscription_id INTEGER REFERENCES subscriptions(id) ON DELETE CASCADE,
    member_id INTEGER REFERENCES members(id) ON DELETE CASCADE,
    amount_paid DECIMAL(10, 2) NOT NULL,
    payment_date DATE NOT NULL,
    billing_period VARCHAR(7) NOT NULL,
    UNIQUE(subscription_id, member_id, billing_period)
);

-- 2. 清空舊資料
TRUNCATE members, subscriptions, subscription_members, payments RESTART IDENTITY CASCADE;

-- 3. 插入基礎資料
INSERT INTO members (id, name, email) VALUES
(1, '您自己', 'your@email.com'),
(2, '陳小花', 'flower@email.com'),
(3, '張大明', 'david@email.com')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, email = EXCLUDED.email;

INSERT INTO subscriptions (id, name, total_price, billing_cycle, payment_owner_id, next_payment_date) VALUES
(1, 'Netflix 家庭方案', 390.00, 'monthly', 1, '2025-11-05'),
(2, 'Office 365 家庭版', 3190.00, 'yearly', 1, '2026-01-15')
ON CONFLICT (id) DO UPDATE SET 
  name = EXCLUDED.name, 
  total_price = EXCLUDED.total_price, 
  billing_cycle = EXCLUDED.billing_cycle, 
  payment_owner_id = EXCLUDED.payment_owner_id, 
  next_payment_date = EXCLUDED.next_payment_date;

INSERT INTO subscription_members (subscription_id, member_id, share_amount) VALUES
(1, 1, 130.00), (1, 2, 130.00), (1, 3, 130.00)
ON CONFLICT DO NOTHING;

INSERT INTO subscription_members (subscription_id, member_id, share_amount) VALUES
(2, 1, 638.00), (2, 3, 638.00)
ON CONFLICT DO NOTHING;

INSERT INTO payments (subscription_id, member_id, amount_paid, payment_date, billing_period) VALUES
(1, 1, 130.00, '2025-09-06', '2025-09'),
(1, 2, 130.00, '2025-09-07', '2025-09'),
(1, 3, 130.00, '2025-09-05', '2025-09'),
(1, 1, 130.00, '2025-10-06', '2025-10'),
(1, 3, 130.00, '2025-10-05', '2025-10')
ON CONFLICT DO NOTHING;


-- --- (*** (NEW) 4. 手動同步自動增長(SERIAL)計數器 ***) ---
-- (因為我們手動插入了 ID，所以必須重置計數器，讓下一個 ID 從 MAX(id) + 1 開始)
SELECT setval('members_id_seq', (SELECT MAX(id) FROM members));
SELECT setval('subscriptions_id_seq', (SELECT MAX(id) FROM subscriptions));
-- (payments 我們雖然沒有手動插 ID，但為了保險起見也同步一下)
SELECT setval('payments_id_seq', (SELECT MAX(id) FROM payments), false);