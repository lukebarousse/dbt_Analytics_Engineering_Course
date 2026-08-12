SELECT
    company_name,
    COUNT(*) AS postings
FROM {{ ref('job_postings') }}
GROUP BY company_name
ORDER BY postings DESC
LIMIT 50