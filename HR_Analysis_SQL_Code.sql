--Creating Database--
CREATE DATABASE HrAnalyticsDB;
GO

--Import CSV data and use database--

--Using Database
USE HrAnalyticsDB;
GO

--not having same data - updated different records to get same salary-- for rank concept
UPDATE dbo.Employees
SET SALARY=80000
WHERE EMPLOYEE_ID='32';

UPDATE dbo.Employees
SET SALARY=72000
WHERE EMPLOYEE_ID='40';

UPDATE dbo.Employees
SET SALARY=68000
WHERE EMPLOYEE_ID='24';

UPDATE dbo.Employees
SET SALARY=92000
WHERE EMPLOYEE_ID='38';

UPDATE dbo.Employees
SET SALARY=98000
WHERE EMPLOYEE_ID='2';
--Query:1 - What is the unique position of each employee within their department by salary?
SELECT EMPLOYEE_ID,DEPARTMENT,SALARY,
       ROW_NUMBER() OVER(PARTITION BY DEPARTMENT             --restart count for each department
                         ORDER BY SALARY DESC) AS row_num    --highest salary gets number 1
FROM dbo.Employees
ORDER BY DEPARTMENT,row_num;


--Query:2 - Rank employees by salary — if two people earn the same, they share a rank
SELECT EMPLOYEE_ID,DEPARTMENT,SALARY,
       RANK() OVER(PARTITION BY DEPARTMENT                  --restart count for each department
                         ORDER BY SALARY DESC) AS row_num    --highest salary gets number 1
FROM dbo.Employees
ORDER BY DEPARTMENT,row_num;

--Query:3 - Create a performance leaderboard with no gaps in ranking
SELECT EMPLOYEE_ID,DEPARTMENT,SALARY,PERFORMANCE_SCORE,
       DENSE_RANK() OVER(ORDER BY PERFORMANCE_SCORE DESC,SALARY DESC) AS performance_rank  
FROM dbo.Employees
ORDER BY performance_rank;

--Query:4 - Compare all three ranking methods side by side on IT department
SELECT EMPLOYEE_ID,DEPARTMENT,SALARY,
       ROW_NUMBER() OVER(PARTITION BY DEPARTMENT ORDER BY SALARY DESC) AS row_number,
       RANK()       OVER(PARTITION BY DEPARTMENT ORDER BY SALARY DESC) AS rank_with_gaps, 
       DENSE_RANK() OVER(PARTITION BY DEPARTMENT ORDER BY SALARY DESC) AS denserank_without_gaps  
FROM dbo.Employees
WHERE DEPARTMENT='IT';

--Query:5 - Compare each employee's salary to the previous experience-level employee in the same department
SELECT EMPLOYEE_NAME,DEPARTMENT,EXPERIENCE_YEARS,SALARY,
       LAG(SALARY) OVER(PARTITION BY DEPARTMENT ORDER BY EXPERIENCE_YEARS)  AS prev_employee_salary,
       SALARY - LAG(SALARY) OVER(PARTITION BY DEPARTMENT ORDER BY EXPERIENCE_YEARS) AS salary_difference
FROM dbo.Employees
ORDER BY DEPARTMENT,EXPERIENCE_YEARS

--Query:6 - What does the next higher-experienced person earn in the same department
SELECT EMPLOYEE_NAME,DEPARTMENT,EXPERIENCE_YEARS,SALARY,
       LEAD(SALARY) OVER(PARTITION BY DEPARTMENT ORDER BY EXPERIENCE_YEARS) AS Next_employee_salary,
       LEAD(employee_name) OVER (PARTITION BY department ORDER BY experience_years) AS Next_level_employee
FROM dbo.Employees
ORDER BY DEPARTMENT,EXPERIENCE_YEARS

--Query:7 - How has the total salary cost accumulated department-wise over time since hiring?
SELECT employee_name,department,hire_date,salary,
       SUM(salary) OVER(PARTITION BY DEPARTMENT ORDER BY HIRE_DATE) AS running_total_salary
FROM dbo.Employees
ORDER BY department, hire_date;

--Query:8 - Is each employee paid above or below their department average?
SELECT Employee_name,Department,Hire_Date,Salary,
       ROUND(AVG(salary) OVER(PARTITION BY DEPARTMENT),0) AS Dept_avg_salary,
       salary - ROUND(AVG(salary) OVER(PARTITION BY DEPARTMENT),0) AS Avg_difference,
       CASE
           WHEN salary> ROUND(AVG(salary) OVER(PARTITION BY DEPARTMENT),0) THEN 'above average' 
           ELSE 'below average'
        END AS Salary_status
FROM dbo.Employees
ORDER BY department, salary DESC;

--Query:9 - How far is each employee's salary from the highest paid person in their department?
SELECT EMPLOYEE_NAME,DEPARTMENT,JOB_TITLE,SALARY,
       FIRST_VALUE(EMPLOYEE_NAME) OVER(PARTITION BY DEPARTMENT ORDER BY SALARY DESC ) AS Highest_paid_in_dept,
       FIRST_VALUE(SALARY) OVER(PARTITION BY DEPARTMENT ORDER BY SALARY DESC) AS Highest_paid_salary_in_dept,
       FIRST_VALUE(SALARY) OVER(PARTITION BY DEPARTMENT ORDER BY SALARY DESC ) - SALARY AS Salary_gap
FROM dbo.Employees
ORDER BY DEPARTMENT,SALARY DESC;

--Query:10 - Which salary band does each employee fall into across the company?
SELECT  employee_name,department,salary,
        NTILE(4) OVER (ORDER BY salary DESC) AS salary_quartile,
        CASE NTILE(4) OVER (ORDER BY salary DESC)
           WHEN 1 THEN 'Top 25% - High Earners'
           WHEN 2 THEN 'Upper Middle 25%'
           WHEN 3 THEN 'Lower Middle 25%'
           WHEN 4 THEN 'Bottom 25% - Low Earners'
        END AS salary_band
FROM Employees
ORDER BY salary_quartile, salary DESC;

--Query:11 - What salary percentile is each employee at in the entire company?
SELECT employee_name,department,salary,
       ROUND(PERCENT_RANK() OVER (ORDER BY salary) * 100, 1) AS salary_percentile
FROM Employees
ORDER BY salary_percentile DESC;

--Query:12 -  Give a complete performance dashboard for every employee showing rank,department average comparison,quartile,gap from top,percentile
SELECT employee_name,department,job_title,salary,performance_score,
-- Rank within department by salary
    DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dept_salary_rank,
-- Compare vs department average
    ROUND(AVG(salary) OVER (PARTITION BY department), 0) AS dept_avg_salary,
 -- Above or below average
    CASE
        WHEN salary >= AVG(salary) OVER (PARTITION BY department)
        THEN 'Above Avg'
        ELSE 'Below Avg'
    END AS vs_dept_avg,
-- Company wide salary quartile
    NTILE(4) OVER (ORDER BY salary DESC) AS company_quartile,
-- Gap from highest paid in department
    FIRST_VALUE(salary) OVER (PARTITION BY department ORDER BY salary DESC) - salary AS gap_from_dept_top,
-- Salary percentile in company
    ROUND(PERCENT_RANK() OVER (ORDER BY salary) * 100, 1) AS company_percentile
FROM Employees
ORDER BY department, dept_salary_rank;
