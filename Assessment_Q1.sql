-- Q1: Identify customers with at least one funded savings plan AND one funded investment plan
-- Sort the results by total deposit amount in naira

SELECT 
    u.id AS owner_id,
    u.name,
    COUNT(DISTINCT s.id) AS savings_count,
    COUNT(DISTINCT p.id) AS investment_count,

    -- Convert kobo to naira and sum deposits from both savings and investment plans
    ROUND(SUM(COALESCE(s.confirmed_amount, 0) + COALESCE(p.amount, 0)) / 100.0, 2) AS total_deposits

FROM users_customuser AS u

-- Join with savings accounts that have confirmed (non-zero) amounts
LEFT JOIN savings_savingsaccount AS s 
    ON u.id = s.owner_id 
    AND s.confirmed_amount > 0

-- Join with investment plans that are funded (amount > 0) and marked as investment
LEFT JOIN plans_plan AS p  
    ON u.id = p.owner_id 
    AND p.amount > 0 
    AND p.is_a_fund = 1

GROUP BY u.id, u.name

-- Only include customers who have at least one funded savings and one funded investment
HAVING COUNT(DISTINCT s.id) > 0 AND COUNT(DISTINCT p.id) > 0

ORDER BY total_deposits DESC;
