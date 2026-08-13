{{ config(materialized='view') }}

-- Q2: which skills the top payers ask for — a mart built on a mart

with top_jobs as (
    select * from {{ ref('top_paying_jobs') }}
),

bridge as (
    select * from {{ ref('job_skills_bridge') }}
),

skills as (
    select * from {{ ref('dim_skill') }}
)

select
    skills.skill_id,
    skills.display_name,
    skills.category,
    count(*) as top_job_mentions
from top_jobs
inner join bridge using (job_id)
inner join skills using (skill_id)
group by skills.skill_id, skills.display_name, skills.category
order by top_job_mentions desc
