WITH job_postings AS (
    SELECT * FROM {{ ref('fct_job_postings') }}
)

SELECT
    company_name,
    COUNT(*) AS total_job_postings,
    MIN(posted_date) AS first_posted_date,
    MAX(posted_date) AS last_posted_date,
    AVG(salary_year_avg) AS avg_salary_year
FROM job_postings
-- company_name is the natural key; a null row would break the one-row-per-company grain
WHERE company_name IS NOT NULL
GROUP BY company_name
