with job_skills as (
    select * from {{ ref('stg_job_skills') }}
),

job_postings as (
    select * from {{ ref('fct_job_postings') }}
)

-- inner join scopes pairs to jobs that made fct; fct is one row per job,
-- so the (job_id, skill_id) grain survives the join
select
    job_id,
    skill_id,
    skill_keyword,
    -- carried from fct: the metrics layer needs an agg time dimension on the bridge
    job_postings.search_date
from job_skills
inner join job_postings using (job_id)
