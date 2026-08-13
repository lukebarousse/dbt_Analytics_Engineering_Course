{% snapshot job_postings_snapshot %}

{{
    config(
        schema='silver',
        unique_key='job_id',
        strategy='check',
        check_cols=[
            'job_title',
            'company_name',
            'job_location',
            'job_schedule_type',
            'job_work_from_home',
            'salary_min',
            'salary_max',
            'salary_period',
            'salary_currency',
            'has_health_insurance',
            'has_dental_insurance',
            'has_paid_time_off',
            'has_no_degree_mentioned'
        ],
        updated_at='searched_at'
    )
}}

-- SCD2 history of each posting's own fields (2,756 jobs change salary text across scrapes).
-- check_cols is posting content only: scrape-derived columns (searched_at, posted_at, search_*)
-- shift on every re-scrape and would version every row. updated_at makes dbt_valid_from/to
-- carry data time, not run time, so the as_of replays below write honest history.
--
-- time machine (data is fully loaded, so we replay time):
--   dbt snapshot --vars '{as_of: <early>}' -> <mid> -> no var = today.
-- in production this var doesn't exist; every nightly run IS a new as_of.

select * from {{ ref('stg_job_postings') }}
-- explicit cast: run_started_at renders with a +00:00 offset
where searched_at <= cast('{{ var("as_of", run_started_at) }}' as timestamp)
-- 3.73's dedupe pattern, new job: pick the current row as of the cutoff.
-- job_title tiebreaker: one job_id carries two rows with identical searched_at
qualify row_number() over (
    partition by job_id
    order by searched_at desc, job_title
) = 1

{% endsnapshot %}
