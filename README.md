# Cowrywise SQL Assessment: README.md

This document outlines the logic, approach, and SQL implementation for the Cowrywise SQL Assessment, which contains four business-related SQL tasks.

Each solution:

- Uses realistic assumptions based on schema and business logic  
- Prioritizes clarity, data integrity, and analytical value  
- Includes in-line SQL comments to meet code quality expectations  

---

## Q1: Customers with Funded Savings and Investment Plans

### Objective

Identify customers who have at least one funded savings plan and one funded investment plan, and report:

- owner_id  
- full name  
- number of funded savings and investment plans  
- total deposits in naira

### Approach

1. Joined `users_customuser` with both `savings_savingsaccount` and `plans_plan` using `owner_id`
2. Filtered savings where `confirmed_amount > 0`  
3. Filtered investment plans where `amount > 0 AND is_a_fund = 1`  
4. Used `COALESCE` to protect nulls during total deposit calculations  
5. Converted total from kobo to naira by dividing by 100  
6. Grouped by user ID and name  
7. Used `HAVING` clause to restrict output to only users with both investment and savings plans  
8. Sorted result by total deposit in descending order  
9. Used `CONCAT(first_name, ' ', last_name)` instead of `u.name`, because the `name` field was often NULL in the dataset

#### Why `COUNT(DISTINCT s.id)` instead of alias?

In SQL, aliases created in the `SELECT` clause cannot be reused in the `HAVING` clause. The raw aggregate expression must be used directly.

---

## Q2: Transaction Frequency Analysis

### Objective

Categorize customers based on their average number of monthly savings transactions:

- High Frequency (≥10/month)  
- Medium Frequency (3–9/month)  
- Low Frequency (≤2/month)

### Approach

1. Joined `users_customuser` with `savings_savingsaccount` using `owner_id`  
2. Filtered out NULL `transaction_date` values  
3. Grouped by user  
4. Calculated tenure in months using `TIMESTAMPDIFF(MONTH, MIN(transaction_date), MAX(transaction_date))`  
5. Used `GREATEST(..., 1)` to prevent divide-by-zero  
6. Derived average transactions per month as `total_txns / months`  
7. Categorized users using `CASE WHEN` logic  
8. Grouped results by frequency category and reported average per group

#### Why did I use `TIMESTAMPDIFF` instead of counting distinct months?

`TIMESTAMPDIFF` more accurately reflects the active span of a user’s transaction history.  
It avoids overestimating users who transacted heavily in just one month, and `GREATEST(..., 1)` ensures clean division logic.

---

## Q3: Account Inactivity Alert

### Objective

Find all active accounts (savings or investments) with no confirmed inflow in the past 365 days.

### Approach

1. Queried savings accounts with `confirmed_amount > 0`  
2. Queried investment plans with `amount > 0 AND is_a_fund = 1`  
3. Calculated last inflow date for savings using `MAX(transaction_date)`  
4. Used `COALESCE(last_charge_date, created_on)` for investment inflow  
5. Calculated inactivity in days using `DATEDIFF(CURDATE(), last_transaction_date)`  
6. Filtered for `inactivity_days >= 365`  
7. Combined both queries using `UNION ALL`  
8. Labeled account types as 'Savings' or 'Investment'  
9. Sorted by `inactivity_days` descending

#### Why did I use `COALESCE(last_charge_date, created_on)`?

Many records had `NULL` in `last_charge_date`.  
`COALESCE` lets us fall back to `created_on` so we don’t miss plans with missing charge data.  
It ensures every plan has a fallback for inactivity tracking, while prioritizing real transaction activity.

---

## Q4: Customer Lifetime Value (CLV) Estimation

### Objective

Estimate customer lifetime value using the formula:  
**CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction**

Where profit is defined as **0.1% of each transaction's confirmed amount**

### Approach

1. Joined `users_customuser` with `savings_savingsaccount`  
2. Filtered confirmed inflow with `confirmed_amount > 0`  
3. Calculated tenure using `TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE())`  
4. Counted total transactions per user  
5. Calculated profit per transaction as `AVG(0.001 * confirmed_amount)`  
6. Converted kobo to naira by dividing by 100  
7. Used `GREATEST(..., 1)` to avoid divide-by-zero  
8. Calculated final CLV using the formula and rounded to 2 decimal places

#### What unit is `estimated_clv`?

CLV is in **naira (₦)**. Since confirmed_amount is in kobo, we divide by 100 to convert.

---
## Challenges

**Handling missing last_charge_date values in investment plans:**
Many records in the plans_plan table had NULL in the last_charge_date field, making it difficult to determine when a plan last received inflow. To solve this, I used COALESCE(last_charge_date, created_on) as a fallback. This ensured plans without charge dates still had a valid reference point for inactivity analysis.

**Avoiding divide-by-zero errors in tenure-based calculations:**
Some users had very short tenures or multiple transactions within a single month. To avoid dividing by zero when calculating metrics like average transactions per month or CLV, I used GREATEST(..., 1) to enforce a minimum of 1 month. This preserved data integrity without skewing the output.

**Querying large SQL files locally:**
The original .sql file provided for database setup was over 70MB and exceeded phpMyAdmin’s default upload limits. I adjusted the upload_max_filesize and post_max_size settings in php.ini, restarted Apache through XAMPP, and successfully imported the file for use in phpMyAdmin.

**Interpreting business logic in CLV calculation:**
In Q4, the phrase “profit per transaction is 0.1% of the transaction value” required careful interpretation. I calculated profit dynamically using 0.1% of each user's actual inflow value. This produced a realistic customer lifetime value.

---

## Summary

Each solution:

- Handles nulls, edge cases, and schema-specific conditions  
- Aligns with business logic and real-world expectations  
- Returns accurate, readable, and fully explained output  
- Uses clean SQL design, with formatting and comments  

All queries were tested on phpMyAdmin using the `adashi_assessment` database.
