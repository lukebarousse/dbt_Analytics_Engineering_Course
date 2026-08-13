-- where the jobs are
SELECT
    job_location,
    COUNT(*) AS postings
FROM {{ ref('job_postings') }}
GROUP BY job_location
ORDER BY postings DESC
LIMIT 10