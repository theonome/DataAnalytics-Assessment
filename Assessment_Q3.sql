-- Q3: Account Inactivity Alert
-- Identify active accounts (savings or investments) with no inflow transactions in the last 1 year (365 days).
-- Savings activity is based on confirmed transactions; investment activity is estimated using last_charge_date or created_on

-- Savings accounts with no confirmed inflow in the last 365 days
SELECT 
  s.id AS plan_id,
  s.owner_id,
  'Savings' AS type,
  MAX(s.transaction_date) AS last_transaction_date,
  DATEDIFF(CURDATE(), MAX(s.transaction_date)) AS inactivity_days
FROM savings_savingsaccount AS s
WHERE s.transaction_date IS NOT NULL
  AND s.confirmed_amount > 0
GROUP BY s.id, s.owner_id
HAVING MAX(s.transaction_date) < (CURDATE() - INTERVAL 365 DAY)

UNION ALL

-- Investment plans with no inflow activity (via last_charge_date or created_on) in the last 365 days
SELECT 
  p.id AS plan_id,
  p.owner_id,
  'Investment' AS type,
  MAX(COALESCE(p.last_charge_date, p.created_on)) AS last_transaction_date,
  DATEDIFF(CURDATE(), MAX(COALESCE(p.last_charge_date, p.created_on))) AS inactivity_days
FROM plans_plan AS p
WHERE p.amount > 0 
  AND p.is_a_fund = 1
GROUP BY p.id, p.owner_id
HAVING MAX(COALESCE(p.last_charge_date, p.created_on)) < (CURDATE() - INTERVAL 365 DAY)

-- Final output: all inactive accounts sorted by longest inactivity
ORDER BY inactivity_days DESC;
