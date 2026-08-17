-- grain: one row per (job_id, skill_id) pair; raw arrives already distinct.
-- the deliberately boring one: some staging models just rename, order, and trim,
-- and that is the discipline working.

with source as (

    select *
    from {{ source('jobs', 'raw_job_skills') }}

),

renamed as (

    select
        job_id,
        skill_id,
        trim(skill_keyword) as skill_keyword  -- same cleanup shape as company_name in stg_job_postings

    from source

)

select * from renamed
