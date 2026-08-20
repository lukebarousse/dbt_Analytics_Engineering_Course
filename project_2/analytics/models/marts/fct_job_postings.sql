{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='job_id'
    )
}}

WITH job_postings AS (
    SELECT * FROM {{ ref('int_job_postings_enriched') }}
)

SELECT
    job_id,
    job_title,
    search_term,
    company_name,
    job_location,
    source_platform,
    job_schedule_type,
    job_work_from_home,
    posted_date,
    posted_at,
    search_date,
    salary_min,
    salary_max,
    salary_period,
    salary_currency,
    salary_year_avg,
    has_health_insurance,
    has_dental_insurance,
    has_paid_time_off,
    has_no_degree_mentioned
FROM job_postings

{% if is_incremental() %}
-- strict > is fine for this dataset; with late same-day arrivals,
-- merge idempotency makes >= the safer production choice
WHERE search_date > (SELECT MAX(search_date) FROM {{ this }})
{% endif %}

-- one row per job: latest scrape wins; job_title breaks the single real
-- identical-searched_at tie in the data
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY job_id
    ORDER BY searched_at DESC, job_title
) = 1
