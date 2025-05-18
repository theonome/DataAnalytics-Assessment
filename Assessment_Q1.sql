-- Q1: Customers with both funded savings and investment plans

SELECT 
    u.id AS owner_id,
    u.name,
    COUNT(DISTINCT s.id) AS savings_count,
    COUNT(DISTINCT p.id) AS investment_count,
    ROUND(SUM(COALESCE(s.confirmed_amount, 0) + COALESCE(p.amount, 0)) / 100, 2) AS total_deposits
FROM users_customuser AS u
LEFT JOIN savings_savingsaccount AS s 
    ON u.id = s.owner_id 
    AND s.confirmed_amount > 0
LEFT JOIN plans_plan AS p 
    ON u.id = p.owner_id 
    AND p.amount > 0 
    AND p.is_a_fund = 1
GROUP BY u.id, u.name
HAVING COUNT(DISTINCT s.id) > 0 AND COUNT(DISTINCT p.id) > 0
ORDER BY total_deposits DESC;
