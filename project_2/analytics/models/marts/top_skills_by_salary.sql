{{ config(materialized='view') }}

-- Q4: average annual salary per skill; the USD rule is inherited from int,
-- never restated — marts only ever filter salary_year_avg is not null

with bridge as (
    select * from {{ ref('job_skills_bridge') }}
),

job_postings as (
    select job_id, salary_year_avg
    from {{ ref('fct_job_postings') }}
    where salary_year_avg is not null
),

skills as (
    select * from {{ ref('dim_skill') }}
)

select
    skills.skill_id,
    skills.display_name,
    skills.category,
    round(avg(job_postings.salary_year_avg), 0) as avg_salary_year,
    count(*) as salaried_postings
from bridge
inner join job_postings using (job_id)
inner join skills using (skill_id)
group by skills.skill_id, skills.display_name, skills.category
order by avg_salary_year desc
