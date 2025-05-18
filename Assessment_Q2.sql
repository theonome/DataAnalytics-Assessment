-- Q2: Transaction Frequency Analysis
-- Categorize customers by their average number of savings transactions per month:
--   - High Frequency (≥10)
--   - Medium Frequency (3–9)
--   - Low Frequency (≤2)

SELECT 
  frequency_category,
  COUNT(*) AS customer_count,
  ROUND(AVG(avg_txn_per_month), 1) AS avg_transactions_per_month

FROM (
  SELECT 
    u.id AS customer_id,
    COUNT(s.id) AS total_txns,

    -- Calculate the active span in months between first and last transaction (minimum 1)
    GREATEST(TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), MAX(s.transaction_date)), 1) AS active_months,

    -- Derive average monthly transaction frequency
    COUNT(s.id) / GREATEST(TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), MAX(s.transaction_date)), 1) AS avg_txn_per_month,

    -- Categorize based on average monthly frequency
    CASE 
      WHEN COUNT(s.id) / GREATEST(TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), MAX(s.transaction_date)), 1) >= 10 THEN 'High Frequency'
      WHEN COUNT(s.id) / GREATEST(TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), MAX(s.transaction_date)), 1) BETWEEN 3 AND 9 THEN 'Medium Frequency'
      ELSE 'Low Frequency'
    END AS frequency_category

  FROM users_customuser u
  JOIN savings_savingsaccount s ON u.id = s.owner_id
  WHERE s.transaction_date IS NOT NULL
  GROUP BY u.id
) AS frequency_summary

GROUP BY frequency_category
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');
