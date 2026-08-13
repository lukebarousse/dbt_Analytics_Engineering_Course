-- staging cleans, intermediate thinks, marts serve. grain unchanged from staging:
-- one row per posting per scrape day (fct_job_postings owns the dedupe to one per job).
-- the demo marts ref this model on purpose: scrape grain plus count(distinct job_id)
-- keeps their numbers stable no matter what gold does.

with job_postings as (
    select * from {{ ref('stg_job_postings') }}
)

select
    *,

    -- the usd annualization rule, stated once for the whole project; downstream
    -- models filter salary_year_avg is not null instead of restating it.
    -- null currency = assumed usd. yearly = average of the parsed range (single
    -- values land as their own range upstream). hourly = average x 2080.
    -- month/day/week periods and explicit currencies stay null: documented, not guessed
    case
        when salary_currency is not null then null
        when salary_period = 'year' then (salary_min + salary_max) / 2
        when salary_period = 'hour' then (salary_min + salary_max) / 2 * 2080
    end as salary_year_avg

from job_postings
