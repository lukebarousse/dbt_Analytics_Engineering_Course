-- which postings changed their salary between scrapes? BONUS deep-dive — the filmed
-- 3.10.3 payoff went simpler (analyses/top_posting_editors.sql + salary_swings.sql);
-- this is the LAG-over-versions version. needs `dbt snapshot` run at least twice
-- (two as_of points) before any job has a second version to compare.
-- hero rows: Fraser Health's senior Data Engineer, CA$1.06M–1.22M on 2025-09-01,
-- corrected to CA$104K–145K on 2025-09-11 — the same rows assert_salaries_sane flags.
-- caveat: on the full-year table the ORDER BY is dominated by foreign-currency rows
-- (₩85M, COP 77M…) — add e.g. `AND salary_currency = 'CAD'` to put Fraser on top.

WITH versions AS (

    SELECT * FROM {{ ref('job_postings_snapshot') }}

),

with_previous AS (

    SELECT
        job_id,
        job_title,
        company_name,
        salary_min,
        salary_max,
        salary_currency,
        dbt_valid_from,
        LAG(dbt_valid_from) OVER (PARTITION BY job_id ORDER BY dbt_valid_from) AS prev_valid_from,
        LAG(salary_min) OVER (PARTITION BY job_id ORDER BY dbt_valid_from) AS prev_salary_min,
        LAG(salary_max) OVER (PARTITION BY job_id ORDER BY dbt_valid_from) AS prev_salary_max
    FROM versions

)

SELECT
    job_id,
    job_title,
    company_name,
    prev_salary_min,
    prev_salary_max,
    salary_min,
    salary_max,
    salary_currency,
    dbt_valid_from AS changed_at
FROM with_previous
WHERE prev_valid_from IS NOT NULL  -- only rows that have an earlier version to differ from
  AND (
    salary_min IS DISTINCT FROM prev_salary_min
    OR salary_max IS DISTINCT FROM prev_salary_max
  )
ORDER BY ABS(COALESCE(salary_max, 0) - COALESCE(prev_salary_max, 0)) DESC
