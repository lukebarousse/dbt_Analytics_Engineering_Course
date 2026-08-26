WITH job_postings AS (
    SELECT * FROM {{ ref('fct_job_postings') }}
)

SELECT
    company_name,
    COUNT(*) AS total_job_postings,
    -- conditional aggregation, not a WHERE: filtering the query would drop
    -- salary-less postings from total_job_postings. only like units average —
    -- USD yearly — the rest stay out rather than guessed
    AVG(CASE
        WHEN salary_currency = 'USD' AND salary_period = 'year'
        THEN salary_avg
    END) AS avg_salary_year
FROM job_postings
-- company_name is the natural key; a null row would break the one-row-per-company grain
WHERE company_name IS NOT NULL
GROUP BY company_name
