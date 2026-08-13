-- no posting in this data legitimately pays seven figures a year, in any currency.
-- anything the parser lands above 1,000,000 is scraper garbage, and the garbage is real:
-- Fraser Health's senior Data Engineer posting hit the scrape at CA$1.06M–1.22M on
-- 2025-09-01, then got corrected to CA$104K–145K ten days later. the 3.81 snapshot
-- catches the correction; this test catches the garbage.
-- checks parsed min/max, not salary_year_avg: the USD rule nulls out foreign-currency
-- rows, and the hero garbage is CA$. points at int, not fct: fct keeps only the latest
-- scrape (the corrected row), so only scrape grain still shows the bad one.
-- warn, not error: the rows are documented data reality, not a broken pipeline.

{{ config(severity = 'warn') }}

select
    job_id,
    company_name,
    job_title,
    salary_min,
    salary_max,
    salary_period,
    salary_currency,
    searched_at
from {{ ref('int_job_postings_enriched') }}
where salary_period = 'year'
  and coalesce(salary_max, salary_min) > 1000000
