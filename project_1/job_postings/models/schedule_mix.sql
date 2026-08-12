-- full-time vs everything else?
SELECT
    COALESCE(job_schedule_type, 'Not specified') AS schedule,
    COUNT(*) AS postings
FROM {{ ref('job_postings') }}
GROUP BY schedule
ORDER BY postings DESC
