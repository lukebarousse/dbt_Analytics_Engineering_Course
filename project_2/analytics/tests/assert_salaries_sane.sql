-- a sanity bound: no posting legitimately pays seven figures a year. across ALL
-- currencies it fires 7,232 times, and most of those flags are the test's own
-- assumption being wrong: ₹, ZAR, PKR and friends legitimately pay seven figures
-- (₹ alone is 4,248 of them). fix the assumption, not the data: pinned to USD the
-- red drops to 27 rows, every one a range that ends in "1M" (a typed ceiling, not
-- a salary). one of them, Kobie Marketing's Decision Sciences Analyst, reads
-- 800K–1M for a single scrape inside a five-scrape 90K–125K life: the employer
-- corrected it within days, and only scrape grain still shows the bad one. the
-- 3.11.1 snapshot turns that into history; reading this red in two layers is the
-- 3.10.2 lesson. points at staging, not fct: fct keeps only the latest scrape.
-- warn, not error: documented data reality, not a broken pipeline.

{{ config(severity = 'warn') }}

SELECT
    job_id,
    company_name,
    job_title,
    salary_min,
    salary_max,
    salary_period,
    salary_currency,
    searched_at
FROM {{ ref('stg_job_postings') }}
WHERE salary_period = 'year'
  AND salary_currency = 'USD'
  AND COALESCE(salary_max, salary_min) >= 1000000
