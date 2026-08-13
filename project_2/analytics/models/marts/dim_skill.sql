with skill_categories as (
    select * from {{ ref('skill_categories') }}
),

job_skills as (
    select * from {{ ref('stg_job_skills') }}
),

observations as (
    select
        skill_id,
        count(distinct job_id) as postings_with_skill
    from job_skills
    group by skill_id
)

-- every observed skill_id sits inside the 1,422-row seed, so the seed is the spine
select
    skill_id,
    display_name,
    category,
    subcategory,
    coalesce(postings_with_skill, 0) as postings_with_skill
from skill_categories
left join observations using (skill_id)
