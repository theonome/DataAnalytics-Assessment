# Cowrywise SQL Assessment: README.md

This document outlines the logic, approach, and SQL implementation for the Cowrywise SQL Assessment, which contains four business-related SQL tasks.

Each solution:

- Uses realistic assumptions based on schema and business logic  
- Prioritizes clarity, data integrity, and analytical value  
- Includes in-line SQL comments to meet code quality expectations

---

## Q1: High-Value Customers with Multiple Products

### Objective

Identify customers who have at least one funded savings plan and one funded investment plan, then display:

- Their owner_id  
- Full name  
- Count of savings and investment plans  
- Total amount deposited (in naira)

### Assumptions & Logic

- A funded savings account has `confirmed_amount > 0`  
- An investment plan must have `is_a_fund = 1` and `amount > 0`  
- `confirmed_amount` is used instead of `amount` to ensure only confirmed inflows are counted  
- Used `COALESCE` to protect against nulls when summing deposits  
- Converted kobo to naira by dividing by 100  
- Joined `users_customuser`, `savings_savingsaccount`, and `plans_plan`  
- Grouped by user ID and name  
- Used `HAVING` to ensure only users with at least one savings and one investment plan are returned  
- Sorted by `total_deposits` in descending order

### Question?? Why `COUNT(DISTINCT s.id)` instead of alias?

In SQL, aliases from the `SELECT` clause aren't available in `HAVING`, so we use the full aggregate expression instead.

---

## Q2: Transaction Frequency Analysis

### Objective

Categorize customers based on their average number of savings transactions per month, using the following categories:

- High Frequency (>= 10/month)  
- Medium Frequency (3–9/month)  
- Low Frequency (<= 2/month)

### Assumptions & Logic

- Each row in `savings_savingsaccount` represents a confirmed transaction (`transaction_date IS NOT NULL`)  
- Calculated tenure span using `TIMESTAMPDIFF(MONTH, MIN(...), MAX(...))`  
- Used `GREATEST(..., 1)` to avoid dividing by zero  
- Calculated average transactions per month as `COUNT(txns) / active_months`  
- Used `CASE WHEN` to assign frequency categories  
- Grouped final result by `frequency_category` and calculated average frequency per group

### Question?? Why use `TIMESTAMPDIFF` instead of counting distinct months?

Using `TIMESTAMPDIFF(MONTH, MIN(transaction_date), MAX(transaction_date))` gives a more accurate span of activity over time, regardless of gaps between months. This avoids overcounting users who transacted heavily in a single month and then stopped.  
`GREATEST(..., 1)` is used to protect against divide-by-zero errors for users with activity in only one month.

---

## Q3: Account Inactivity Alert

### Objective

Identify active savings or investment accounts with no inflow activity in the last 365 days.

### Assumptions & Logic

- For savings: inflow is based on `confirmed_amount > 0` and `transaction_date`  
- For investments: used `COALESCE(last_charge_date, created_on)` as a proxy for last activity  
- Calculated inactivity using `DATEDIFF(CURDATE(), last_transaction_date)`  
- Filtered for rows where `inactivity_days >= 365`  
- Combined both account types using `UNION ALL`  
- Added `type` labels to distinguish savings vs investment accounts  
- Sorted final result by `inactivity_days DESC`

### Question?? Why use `COALESCE(last_charge_date, created_on)`?

In the `plans_plan` table, many records had `NULL` in the `last_charge_date` field. Since this field most accurately reflects the most recent inflow or funding activity, I used it as my first choice.

To ensure no plan was excluded due to a missing `last_charge_date`, I used `COALESCE(last_charge_date, created_on)` — this ensures I fall back to the plan’s creation date if no charge date is available.

While `created_on` may not always reflect true inflow, this approach guarantees a complete view of inactive accounts while prioritizing actual transaction-based timestamps when available.

---

## Q4: Customer Lifetime Value (CLV) Estimation

### Objective

Estimate each customer’s CLV using the formula:

**CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction**

Where:

- Profit per transaction = 0.1% of each transaction’s `confirmed_amount`  
- Tenure = months between `date_joined` and current date

### Assumptions & Logic

- Used only confirmed savings transactions (`confirmed_amount > 0`)  
- Calculated average profit per transaction as `AVG(0.001 * confirmed_amount)` and divided by 100 to convert from kobo to naira  
- Applied `GREATEST(..., 1)` on tenure to prevent division by zero  
- Used `ROUND(..., 2)` for naira-style currency formatting  
- Final result includes customer ID, name, tenure, transaction count, and estimated CLV

### Question?? What unit is `estimated_clv`?

Naira (₦). We calculate 0.1% of each transaction in kobo, then divide by 100 to convert to naira.

---
### Challenges

#### Handling missing last_charge_date values in investment plans:
Many records in the plans_plan table had NULL in the last_charge_date field, making it difficult to determine when a plan last received inflow. To solve this, I used COALESCE(last_charge_date, created_on) as a fallback. This ensured plans without charge dates still had a valid reference point for inactivity analysis.

#### Avoiding divide-by-zero errors in tenure-based calculations:
Some users had very short tenures or multiple transactions within a single month. To avoid dividing by zero when calculating metrics like average transactions per month or CLV, I used GREATEST(..., 1) to enforce a minimum of 1 month. This preserved data integrity without skewing the output.

#### Querying large SQL files locally:
The original .sql file provided for database setup was over 70MB and exceeded phpMyAdmin’s default upload limits. I adjusted the upload_max_filesize and post_max_size settings in php.ini, restarted Apache through XAMPP, and successfully imported the file for use in phpMyAdmin.

#### Interpreting ambiguous business logic in CLV calculation:
In Q4, the phrase “profit per transaction is 0.1% of the transaction value” required careful interpretation. I calculated profit dynamically using 0.1% of each user's actual inflow value. This produced a realistic customer lifetime value.


## Summary

Each solution:

- Handles nulls, edge cases, and schema-specific conditions  
- Aligns with business logic and real-world expectations  
- Returns accurate, readable, and fully explained output  
- Uses clean SQL design, with formatting and comments  

All queries were tested on phpMyAdmin using the `adashi_assessment` database.
