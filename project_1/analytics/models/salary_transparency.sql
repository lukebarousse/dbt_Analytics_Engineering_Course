-- can we even answer the salary questions? (the Advanced teaser)
SELECT
    ROUND(100.0 * COUNT(job_salary) / COUNT(*), 1) AS pct_with_salary,
    COUNT(*) AS total_postings
FROM {{ ref('job_postings') }}
