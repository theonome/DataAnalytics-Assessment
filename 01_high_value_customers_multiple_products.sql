-- Analysis: High-Value Customers with Multiple Products
-- Objective: Identify customers who have both a funded savings plan and a funded investment plan.
-- Rationale: Multi-product customers tend to be more loyal and generate higher lifetime value.
-- Output: Customer details and total deposit amount, sorted in descending order (₦).

SELECT 
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,  -- Combine first and last name
    COUNT(DISTINCT s.id) AS savings_count,
    COUNT(DISTINCT p.id) AS investment_count,

    -- Convert kobo to naira and sum deposits from both savings and investment plans
    ROUND(SUM(COALESCE(s.confirmed_amount, 0) + COALESCE(p.amount, 0)) / 100.0, 2) AS total_deposits

FROM users_customuser AS u

-- Join funded savings accounts
LEFT JOIN savings_savingsaccount AS s 
    ON u.id = s.owner_id 
    AND s.confirmed_amount > 0
    -- confirmed_amount is used here instead of amount to ensure only actual inflows are included

-- Join funded investment plans
LEFT JOIN plans_plan AS p 
    ON u.id = p.owner_id 
    AND p.amount > 0 
    AND p.is_a_fund = 1

GROUP BY u.id, name

-- Only include users with at least one savings and one investment
HAVING COUNT(DISTINCT s.id) > 0 AND COUNT(DISTINCT p.id) > 0
ORDER BY total_deposits DESC;
