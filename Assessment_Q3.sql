-- Q3: Account Inactivity Alert
-- This query identifies savings and investment accounts with no inflow activity in the last 365 days.
-- For savings, we use `transaction_date`. For investments, we use COALESCE of `last_charge_date` and `created_on`.

-- Inactive Savings Accounts
SELECT 
  s.id AS plan_id,
  s.owner_id,
  'Savings' AS type,
  MAX(s.transaction_date) AS last_transaction_date,
  DATEDIFF(CURDATE(), MAX(s.transaction_date)) AS inactivity_days
FROM savings_savingsaccount s
WHERE s.transaction_date IS NOT NULL
  AND s.confirmed_amount > 0
GROUP BY s.id, s.owner_id
HAVING MAX(s.transaction_date) < (CURDATE() - INTERVAL 365 DAY)

UNION ALL

-- Inactive Investment Accounts (using last_charge_date if available, otherwise created_on)
SELECT 
  p.id AS plan_id,
  p.owner_id,
  'Investment' AS type,
  MAX(COALESCE(p.last_charge_date, p.created_on)) AS last_transaction_date,
  DATEDIFF(CURDATE(), MAX(COALESCE(p.last_charge_date, p.created_on))) AS inactivity_days
FROM plans_plan p
WHERE p.amount > 0 
  AND p.is_a_fund = 1
GROUP BY p.id, p.owner_id
HAVING MAX(COALESCE(p.last_charge_date, p.created_on)) < (CURDATE() - INTERVAL 365 DAY);
