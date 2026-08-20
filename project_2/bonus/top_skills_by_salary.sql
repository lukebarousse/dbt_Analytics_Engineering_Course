-- BONUS 2026-08-19 (Luke's famous-five split): Q4 lives in the supporter tier.
-- Q1+Q3 are core analyses (3.71), Q5 is the capstone mart, Q2+Q4 are here.
-- original marts.yml block preserved at the bottom of this file.

{{ config(materialized='view') }}

-- Q4: average annual salary per skill; the USD rule is inherited from int,
-- never restated — marts only ever filter salary_year_avg is not null

WITH bridge AS (
    SELECT * FROM {{ ref('job_skills_bridge') }}
),

job_postings AS (
    SELECT job_id, salary_year_avg
    FROM {{ ref('fct_job_postings') }}
    WHERE salary_year_avg IS NOT NULL
),

skills AS (
    SELECT * FROM {{ ref('dim_skill') }}
)

SELECT
    skills.skill_id,
    skills.display_name,
    skills.category,
    ROUND(AVG(job_postings.salary_year_avg), 0) AS avg_salary_year,
    COUNT(*) AS salaried_postings
FROM bridge
INNER JOIN job_postings USING (job_id)
INNER JOIN skills USING (skill_id)
GROUP BY skills.skill_id, skills.display_name, skills.category
ORDER BY avg_salary_year DESC

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
