-- biggest salary swings per posting (optional second payoff for 3.10.3).
-- no LAG needed: a job's versions are just rows, so MIN/MAX across them IS the
-- swing. USD only — mixed currencies (COP, KRW, INR) swamp the board otherwise.
-- live receipt: the top is a TYPO board (a PMO Analyst going 60K → 1,000,000) —
-- which is the point: snapshots catch postings mid-edit; this is QA as analysis.

SELECT
    job_title,
    company_name,
    MIN(salary_max) AS lowest_posted,
    MAX(salary_max) AS highest_posted,
    MAX(salary_max) - MIN(salary_max) AS salary_swing
FROM {{ ref('job_postings_snapshot') }}
WHERE salary_currency = 'USD'
GROUP BY job_id, job_title, company_name  -- per-job grain; title + company for display
ORDER BY salary_swing DESC
LIMIT 10
