# DataAnalytics-Assessment
Data Analyst Technical Assessment
# Cowrywise Data Analytics Assessment

This repository contains my solutions to the Cowrywise SQL Technical Assessment.

---

## 🧠 Q1: High-Value Customers with Multiple Products

**Approach:**  
Joined savings and investment plans by customer ID, filtered for funded plans, and grouped by customer to count product types and sum total deposits.

---

## 🔁 Q2: Transaction Frequency Analysis

**Approach:**  
Calculated total transactions per customer over time. Divided by number of months to get monthly averages, then used CASE WHEN logic to categorize frequency.

---

## 💤 Q3: Account Inactivity Alert

**Approach:**  
Identified last transaction date per account and filtered for any where the difference between current date and last transaction exceeds 365 days.

---

## 💰 Q4: Customer Lifetime Value (CLV)

**Approach:**  
Calculated tenure (in months) for each customer since signup. Used total transactions and average profit per transaction to estimate CLV per provided formula.

---

## Notes
- All transaction amounts were converted from kobo to naira.
- Foreign keys were used to link users to accounts and plans.
- Efficient filtering, aggregation, and clean formatting applied.
