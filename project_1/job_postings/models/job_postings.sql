{{ config(materialized="view") }}

-- all job postings, minus scraper error rows (data quality done properly in Advanced)
SELECT *
    -- job_id,
    -- job_title,
    -- company_name,
    -- job_location,
    -- job_via,
    -- job_schedule_type,
    -- job_work_from_home,
    -- search_date,
    -- search_term
FROM {{ source('raw', 'job_postings') }} -- read_parquet('../data/raw/raw_job_postings_*.parquet')
WHERE error IS NULL