{{ config(materialized='view') }}

-- Q5: high demand AND high salary; the demand floor keeps
-- one-posting salary outliers out of the ranking.
-- the capstone mart — self-contained on the star (fct ⋈ bridge ⋈ dim_skill):
-- demand counts ALL jobs, the salary average only the salaried ones (avg()
-- skips nulls itself). Q1/Q3 live in analyses/, Q2/Q4 in the supporter bonus.

with bridge as (
    select * from {{ ref('job_skills_bridge') }}
),

job_postings as (
    select job_id, salary_year_avg
    from {{ ref('fct_job_postings') }}
),

skills as (
    select * from {{ ref('dim_skill') }}
)

select
    skills.skill_id,
    skills.display_name,
    skills.category,
    count(distinct bridge.job_id) as demand_count,
    round(count(distinct bridge.job_id) / (select count(*) from job_postings), 4) as demand_pct,
    round(avg(job_postings.salary_year_avg), 0) as avg_salary_year
from bridge
inner join job_postings using (job_id)
inner join skills using (skill_id)
group by skills.skill_id, skills.display_name, skills.category
having count(distinct bridge.job_id) >= 100
   and avg(job_postings.salary_year_avg) is not null
order by avg_salary_year desc, demand_count desc
