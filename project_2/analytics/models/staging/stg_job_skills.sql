-- grain: one row per (job_id, skill_id) pair; raw arrives already distinct.
-- the deliberately boring one: some staging models just rename, order, and trim,
-- and that is the discipline working.

WITH source AS (

    SELECT *
    FROM {{ source('jobs', 'raw_job_skills') }}

),

renamed AS (

    SELECT
        job_id,
        skill_id,
        TRIM(skill_keyword) AS skill_keyword  -- same cleanup shape as company_name in stg_job_postings

    FROM source

)

SELECT * FROM renamed
