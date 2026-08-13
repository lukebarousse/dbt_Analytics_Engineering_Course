-- where do postings live?
-- cleanup: some rows arrive as "via LinkedIn" (a scraper-incident artifact)
SELECT
    REGEXP_REPLACE(job_via, '^via ', '') AS platform,
    COUNT(*) AS postings
FROM {{ ref('job_postings') }}
GROUP BY platform
ORDER BY postings DESC
LIMIT 10
