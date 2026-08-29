-- BACKFILL: a year of nightly `dbt snapshot` runs, compressed into one query.
-- Rebuilds dev.snapshots.job_postings_snapshot at DAILY grain from staging's
-- full scrape log, then `dbt snapshot` takes over as if it had run all along.
-- Paste into the Databricks SQL editor and run once.
-- (How it works, line by line = the advanced-snapshots supporter deep-dive.)

CREATE OR REPLACE TABLE dev.snapshots.job_postings_snapshot AS
WITH deduped AS (
    -- one row per job per scrape day (mirrors the snapshot input's pick)
    SELECT *
    FROM dev.staging.stg_job_postings
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY job_id, search_date
        ORDER BY searched_at DESC
    ) = 1
),

sigged AS (
    -- one fingerprint per row over the 13 watched columns
    SELECT *,
        MD5(CONCAT_WS('||',
            COALESCE(job_title, '~'), COALESCE(company_name, '~'),
            COALESCE(job_location, '~'), COALESCE(job_schedule_type, '~'),
            COALESCE(CAST(job_work_from_home AS STRING), '~'),
            COALESCE(CAST(salary_min AS STRING), '~'),
            COALESCE(CAST(salary_max AS STRING), '~'),
            COALESCE(salary_period, '~'), COALESCE(salary_currency, '~'),
            COALESCE(CAST(has_health_insurance AS STRING), '~'),
            COALESCE(CAST(has_dental_insurance AS STRING), '~'),
            COALESCE(CAST(has_paid_time_off AS STRING), '~'),
            COALESCE(CAST(has_no_degree_mentioned AS STRING), '~')
        )) AS _sig
    FROM deduped
),

versions AS (
    -- keep a row only when the fingerprint differs from the previous scrape
    SELECT *
    FROM (
        SELECT *,
            LAG(_sig) OVER (PARTITION BY job_id ORDER BY searched_at) AS _prev_sig
        FROM sigged
    )
    WHERE _prev_sig IS NULL OR _sig != _prev_sig
)

SELECT
    * EXCEPT (_sig, _prev_sig),
    MD5(CONCAT(job_id, '|', CAST(searched_at AS STRING))) AS dbt_scd_id,
    searched_at AS dbt_updated_at,
    searched_at AS dbt_valid_from,
    LEAD(searched_at) OVER (PARTITION BY job_id ORDER BY searched_at) AS dbt_valid_to
FROM versions
