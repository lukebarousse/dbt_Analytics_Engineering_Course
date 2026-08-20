WITH job_postings AS (
    SELECT * FROM {{ ref('fct_job_postings') }}
)

SELECT
    company_name,
    COUNT(*) AS total_job_postings,
    -- scrape dates, not posting dates: search_date is the course's time axis
    MIN(search_date) AS first_seen_date,
    MAX(search_date) AS last_seen_date,
    AVG(salary_year_avg) AS avg_salary_year
FROM job_postings
-- company_name is the natural key; a null row would break the one-row-per-company grain
WHERE company_name IS NOT NULL
GROUP BY company_name
