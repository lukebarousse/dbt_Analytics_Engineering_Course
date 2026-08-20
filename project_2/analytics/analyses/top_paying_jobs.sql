-- Q1: the 100 best-paying postings with a usable annual salary.
-- a QUESTION, not a model — it lives in analyses/ (3.71): dbt compiles it,
-- the SQL editor runs it, and it never ships as a table.

WITH job_postings AS (
    SELECT * FROM {{ ref('fct_job_postings') }}
)

SELECT
    job_id,
    job_title,
    company_name,
    job_location,
    search_term,
    posted_date,
    salary_year_avg,
    has_health_insurance,
    has_dental_insurance,
    has_paid_time_off,
    has_no_degree_mentioned
FROM job_postings
WHERE salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 100
