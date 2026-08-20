-- a naive sanity bound: flag any parsed yearly salary above 1,000,000. it fires
-- ~6.9k times, and MOST flags are the test's own assumption being wrong — ₹, ZAR,
-- PKR and friends legitimately pay seven figures a year (₹ alone is 4,165 of them).
-- buried inside is the real garbage: Fraser Health's senior Data Engineer posting
-- hit the scrape at CA$1.06M–1.22M on 2025-09-01, then got corrected to CA$104K–145K
-- ten days later. the 3.81 snapshot catches the correction; interrogating this
-- test's red — your assumption vs real garbage — is the 3.72 lesson.
-- checks parsed min/max, not salary_year_avg: the USD rule nulls out foreign-currency
-- rows, and the hero garbage is CA$. points at int, not fct: fct keeps only the latest
-- scrape (the corrected row), so only scrape grain still shows the bad one.
-- warn, not error: the rows are documented data reality, not a broken pipeline.

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
FROM {{ ref('int_job_postings_enriched') }}
WHERE salary_period = 'year'
  AND COALESCE(salary_max, salary_min) > 1000000
