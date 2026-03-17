#  HR Employee Performance Analysis — SQL Window Functions

> A complete SQL project analyzing HR employee data using all major Window Functions in SQL Server (SSMS)

---

## Problem Statement

HR teams need deep insights beyond simple aggregations — they need to know where each employee stands relative to their department, how salaries grow with experience, who the top performers are, and how compensation is distributed across the company. This project answers all of that using **SQL Window Functions** on real HR employee data imported from Excel.

---

## Tools Used

![SQL Server](https://img.shields.io/badge/SQL_Server-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![SSMS](https://img.shields.io/badge/SSMS-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![Excel](https://img.shields.io/badge/Microsoft_Excel-217346?style=for-the-badge&logo=microsoftexcel&logoColor=white)

---

##  Project Workflow

```
Excel File (HR_Employee_Data.xlsx)
        ↓
Save as CSV
        ↓
Import into SQL Server via SSMS Import Wizard
        ↓
Run Window Function Queries
        ↓
Export Results back to Excel
        ↓
Upload everything to GitHub
```

---

##  Dataset Overview

**Source:** HR_Employee_Data.xlsx (custom dataset)
**Records:** 50 Employees across 5 Departments

| Column | Description |
|---|---|
| employee_id | Unique employee ID |
| employee_name | Full name |
| department | IT / Finance / HR / Marketing / Operations |
| job_title | Role in the company |
| gender | M / F |
| age | Employee age |
| hire_date | Date of joining |
| salary | Annual salary |
| bonus | Annual bonus |
| performance_score | 1=Poor to 5=Excellent |
| experience_years | Total years of experience |
| city | Work location |

---

## Project Structure

```
hr-window-functions-sql/
├── README.md
├── dataset/
│   └── HR_Employee_Data.xlsx
├── sql/
│   └── HR_Window_Functions_Analysis.sql
└── visuals/
    └── (screenshots of query results)
```

---

## Window Functions Covered

### 1️⃣ ROW_NUMBER()
**Business Question:** What is the unique position of each employee within their department by salary?

- Assigns sequential unique numbers 1, 2, 3... to each row
- Restarts for each department using `PARTITION BY`
- **Key point:** Always gives unique numbers — no ties ever

---

### 2️⃣ RANK()
**Business Question:** Rank employees by salary — if two people earn the same, they share a rank

- Tied employees get the **same rank**
- Next rank **skips a number** (1, 1, 3 — not 1, 1, 2)
- Used for competition-style rankings

---

### 3️⃣ DENSE_RANK()
**Business Question:** Create a performance leaderboard with no gaps in ranking

- Tied employees get the **same rank**
- Next rank does **NOT skip** (1, 1, 2 — no gaps)
- Better for HR performance appraisals

---

### 4️⃣ RANK vs DENSE_RANK vs ROW_NUMBER
**Business Question:** Compare all three ranking methods side by side on IT department

| salary | ROW_NUMBER | RANK | DENSE_RANK |
|---|---|---|---|
| 135000 | 1 | 1 | 1 |
| 125000 | 2 | 2 | 2 |
| 108000 | 3 | 3 | 3 |
| 105000 | 4 | 4 | 4 |
| 105000 | 5 | 4 | 4 |
| 100000 | 6 | 6 | 5 |

---

### 5️⃣ LAG()
**Business Question:** Compare each employee's salary to the previous experience-level employee in the same department

- Fetches value from the **previous row**
- Used to measure salary growth with experience
- NULL for the first row (no previous row)

---

### 6️⃣ LEAD()
**Business Question:** What does the next higher-experienced person earn in the same department?

- Fetches value from the **next row**
- Used for career growth planning
- NULL for the last row (no next row)

---

### 7️⃣ SUM() OVER() — Running Total
**Business Question:** How has the total salary cost accumulated department-wise over time since hiring?

- Keeps a **cumulative running total** as rows progress
- Uses `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`
- Last row in each department = total department salary

---

### 8️⃣ AVG() OVER() — Department Average Comparison
**Business Question:** Is each employee paid above or below their department average?

- Calculates average **without collapsing rows** like GROUP BY does
- Every row keeps its own data + sees the department average
- Labels employees as `Above Average` or `Below Average`

---

### 9️⃣ FIRST_VALUE()
**Business Question:** How far is each employee's salary from the highest paid person in their department?

- Returns the **first value** in the window (highest salary after ORDER BY DESC)
- Calculates gap from top earner per department
- Helps identify salary ceiling in each department

---

### 🔟 NTILE(4) — Salary Quartiles
**Business Question:** Which salary band does each employee fall into across the company?

| Quartile | Band |
|---|---|
| 1 | Top 25% — High Earners |
| 2 | Upper Middle 25% |
| 3 | Lower Middle 25% |
| 4 | Bottom 25% — Low Earners |

---

### 1️⃣1️⃣ PERCENT_RANK()
**Business Question:** What salary percentile is each employee at in the entire company?

- Returns a value between **0 and 1** (multiplied by 100 for %)
- Score of 80 means earning more than 80% of all employees
- 0 = lowest paid, 100 = highest paid

---

###  Final Combined Dashboard Query
**Business Question:** Give a complete performance dashboard for every employee showing rank, department average comparison, quartile, gap from top, and percentile — all in one query

Uses **6 window functions together:**
- `DENSE_RANK()` — department salary rank
- `AVG() OVER()` — department average
- `CASE` — above/below average label
- `NTILE(4)` — company quartile
- `FIRST_VALUE()` — gap from department top
- `PERCENT_RANK()` — company percentile

---

##  Key Insights

-  **IT department** has the widest salary range — from ₹62,000 to ₹1,35,000
-  **Experience strongly correlates with salary** — LAG analysis shows consistent growth
-  **Top 25% earners** are mostly in senior/director level roles across all departments
-  **HR department** has the highest number of below-average salary employees
-  **Finance and Operations** show the most consistent salary progression with experience
-  **Chitra Sharma (VP Marketing)** is the highest paid at ₹1,40,000

---

##  Window Function Quick Reference

```sql
-- Syntax of every window function:
FUNCTION_NAME() OVER (
    PARTITION BY column    -- group/restart for each value
    ORDER BY column        -- defines row order within group
)

ROW_NUMBER()  → unique 1,2,3... no ties
RANK()        → ties allowed, gaps in numbers (1,1,3)
DENSE_RANK()  → ties allowed, no gaps (1,1,2)
LAG(col, n)   → value from n rows BEFORE current row
LEAD(col, n)  → value from n rows AFTER current row
SUM() OVER()  → running/cumulative total
AVG() OVER()  → average without collapsing rows
FIRST_VALUE() → first value in the window partition
LAST_VALUE()  → last value in the window partition
NTILE(n)      → divide rows into n equal buckets
PERCENT_RANK()→ relative rank as 0 to 1 percentage
```

---

##  How to Run

**Option 1 — Import from Excel:**
1. Open `HR_Employee_Data.xlsx` → Save As CSV
2. Open SSMS → Right click database → Tasks → Import Flat File
3. Select CSV → follow wizard → table created automatically
4. Run the analysis queries from `sql/` folder

**Option 2 — Direct SQL Script:**
1. Open SSMS → New Query
2. Copy and run `HR_Window_Functions_Analysis.sql`
3. It creates the database, table, inserts all 50 rows, and runs all queries

---

##  Author

**Krishna Priya M** — Data Analyst
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/krishna-priya-magapu/)
[![Gmail](https://img.shields.io/badge/Gmail-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:priya.magapu.sk@gmail.com)

---

> 💬 *"Window functions don't just aggregate data — they let every row see the bigger picture while keeping its own identity."*
