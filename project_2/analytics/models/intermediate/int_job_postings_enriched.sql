-- staging cleans, intermediate thinks, marts serve. grain unchanged from staging:
-- one row per posting per scrape day (fct_job_postings owns the dedupe to one per job).
-- the demo marts ref this model on purpose: scrape grain plus count(distinct job_id)
-- keeps their numbers stable no matter what gold does.

WITH job_postings AS (
    SELECT * FROM {{ ref('stg_job_postings') }}
)

SELECT
    *,

    -- the usd annualization rule, stated once for the whole project; downstream
    -- models filter salary_year_avg is not null instead of restating it.
    -- null currency = assumed usd. yearly = average of the parsed range (single
    -- values land as their own range upstream). hourly = average x 2080.
    -- month/day/week periods and explicit currencies stay null: documented, not guessed
    CASE
        WHEN salary_currency IS NOT NULL THEN NULL
        WHEN salary_period = 'year' THEN (salary_min + salary_max) / 2
        WHEN salary_period = 'hour' THEN (salary_min + salary_max) / 2 * 2080
    END AS salary_year_avg

FROM job_postings
