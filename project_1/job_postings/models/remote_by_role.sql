-- how rare is remote, by role?
SELECT
    search_term AS role,
    ROUND(100.0 * COUNT(*) FILTER (WHERE job_work_from_home) / COUNT(*), 1) AS pct_remote
FROM {{ ref('job_postings') }}
GROUP BY search_term
ORDER BY pct_remote DESC
