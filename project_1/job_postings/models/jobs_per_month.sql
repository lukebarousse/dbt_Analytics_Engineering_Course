
-- monthly posting counts by role
SELECT
    DATE_TRUNC('month', search_date) AS month,
    search_term AS role,
    COUNT(*) AS postings
FROM {{ ref('job_postings') }}
GROUP BY ALL
ORDER BY month, role