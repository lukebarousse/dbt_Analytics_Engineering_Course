-- which postings changed their salary between scrapes? the 3.91 payoff, kept as a
-- rerunnable QA artifact. needs `dbt snapshot` run at least twice (two as_of points)
-- before any job has a second version to compare.
-- hero rows: Fraser Health's senior Data Engineer, CA$1.06M–1.22M on 2025-09-01,
-- corrected to CA$104K–145K on 2025-09-11 — the same rows assert_salaries_sane flags.

with versions as (

    select * from {{ ref('job_postings_snapshot') }}

),

with_previous as (

    select
        job_id,
        job_title,
        company_name,
        salary_min,
        salary_max,
        salary_currency,
        dbt_valid_from,
        lag(dbt_valid_from) over (partition by job_id order by dbt_valid_from) as prev_valid_from,
        lag(salary_min) over (partition by job_id order by dbt_valid_from) as prev_salary_min,
        lag(salary_max) over (partition by job_id order by dbt_valid_from) as prev_salary_max
    from versions

)

select
    job_id,
    job_title,
    company_name,
    prev_salary_min,
    prev_salary_max,
    salary_min,
    salary_max,
    salary_currency,
    dbt_valid_from as changed_at
from with_previous
where prev_valid_from is not null  -- only rows that have an earlier version to differ from
  and (
    salary_min is distinct from prev_salary_min
    or salary_max is distinct from prev_salary_max
  )
order by abs(coalesce(salary_max, 0) - coalesce(prev_salary_max, 0)) desc
