-- BONUS 2026-08-19 (Luke's famous-five split): Q2 lives in the supporter tier.
-- Q1+Q3 are core analyses (3.71), Q5 is the capstone mart, Q2+Q4 are here.
-- ⚠️ resurrection note: ref('top_paying_jobs') now points at an ANALYSIS —
-- to run this, inline Q1 as a CTE (or restore it as a model first).
-- original marts.yml block preserved at the bottom of this file.

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

{#- preserved marts.yml block (restore alongside the model):
  - name: top_paying_job_skills
    description: Q2 — skill frequency among the top payers; a mart built on a mart.
    columns:
      - name: skill_id
        description: One row per skill observed in the top-paying set.
        data_tests:
          - not_null
          - unique
-#}
