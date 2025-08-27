-- Analysis: Transaction Frequency Segmentation
-- Objective: Categorize customers into frequency segments (High, Medium, Low) 
-- based on their average number of savings transactions per active month.
-- Rationale: Helps identify customer engagement patterns for retention strategies.

SELECT 
  frequency_category,
  COUNT(*) AS customer_count,
  ROUND(AVG(avg_txn_per_month), 1) AS avg_transactions_per_month

FROM (
  SELECT 
    u.id AS customer_id,
    COUNT(s.id) AS total_txns,

    -- Calculate the number of active months between first and last transaction
    -- GREATEST ensures we don’t divide by 0 if all transactions happened in the same month
    GREATEST(TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), MAX(s.transaction_date)), 1) AS active_months,

    -- Calculate average monthly transaction frequency
    COUNT(s.id) / GREATEST(TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), MAX(s.transaction_date)), 1) AS avg_txn_per_month,

    -- Categorize based on monthly frequency
    CASE 
      WHEN COUNT(s.id) / GREATEST(TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), MAX(s.transaction_date)), 1) >= 10 THEN 'High Frequency'
      WHEN COUNT(s.id) / GREATEST(TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), MAX(s.transaction_date)), 1) BETWEEN 3 AND 9 THEN 'Medium Frequency'
      ELSE 'Low Frequency'
    END AS frequency_category

  FROM users_customuser AS u
  JOIN savings_savingsaccount AS s ON u.id = s.owner_id
  WHERE s.transaction_date IS NOT NULL
  GROUP BY u.id
) AS frequency_summary

GROUP BY frequency_category
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');
