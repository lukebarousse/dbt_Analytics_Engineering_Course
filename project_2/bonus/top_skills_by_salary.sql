-- BONUS 2026-08-19 (Luke's famous-five split): Q4 lives in the supporter tier.
-- Q1+Q3 are core analyses (3.71), Q5 is the capstone mart, Q2+Q4 are here.
-- original marts.yml block preserved at the bottom of this file.

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

{#- preserved marts.yml block (restore alongside the model):
  - name: top_skills_by_salary
    description: >
      Q4 — average annualized salary per skill; the USD rule is inherited
      from the intermediate layer, never restated here.
    columns:
      - name: skill_id
        description: One row per skill observed on salaried fct jobs.
        data_tests:
          - not_null
          - unique
-#}
