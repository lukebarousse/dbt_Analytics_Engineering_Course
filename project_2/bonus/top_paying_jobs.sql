-- BONUS 2026-08-26 (Luke's split, v2): Q1 lives in the supporter tier.
-- Q3+Q4 are the core analyses (3.08.1), Q5 is the capstone mart, Q2 is here too.
-- born a core analysis; body unchanged — runs as an analysis or installs as a model.

WITH job_postings AS (
    SELECT * FROM {{ ref('fct_job_postings') }}
)

SELECT
    job_id,
    job_title,
    company_name,
    job_location,
    search_term,
    search_date,
    salary_avg,
    has_health_insurance,
    has_dental_insurance,
    has_paid_time_off,
    has_no_degree_mentioned
FROM job_postings
-- only like units rank: USD yearly. the unit columns make the filter explicit
-- instead of hiding it inside a precomputed column
WHERE salary_currency = 'USD'
  AND salary_period = 'year'
  AND salary_avg IS NOT NULL
ORDER BY salary_avg DESC
LIMIT 100
