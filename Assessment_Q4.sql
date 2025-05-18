-- Q4: Customer Lifetime Value (CLV) Estimation
-- CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction
-- avg_profit_per_transaction = 0.1% of confirmed inflow per transaction

SELECT 
  u.id AS customer_id,
  CONCAT(u.first_name, ' ', u.last_name) AS name,

  -- How long they've had the account (in months)
  TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,

  -- Number of confirmed savings transactions
  COUNT(s.id) AS total_transactions,

  -- Apply the CLV formula using average 0.1% of transaction amount as profit
  ROUND(
    (COUNT(s.id) / GREATEST(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 1)) 
    * 12 
    * AVG(0.001 * s.confirmed_amount) / 100,  -- divide by 100 to convert from kobo to naira
    2
  ) AS estimated_clv

FROM users_customuser AS u

-- Only include confirmed savings transactions
LEFT JOIN savings_savingsaccount AS s 
  ON u.id = s.owner_id
  AND s.confirmed_amount > 0
  AND s.transaction_date IS NOT NULL

GROUP BY u.id, name, u.date_joined
ORDER BY estimated_clv DESC;
