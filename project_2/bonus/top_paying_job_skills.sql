-- BONUS 2026-08-19 (Luke's famous-five split): Q2 lives in the supporter tier.
-- Q1+Q3 are core analyses (3.71), Q5 is the capstone mart, Q2+Q4 are here.
-- ⚠️ resurrection note: ref('top_paying_jobs') now points at an ANALYSIS —
-- to run this, inline Q1 as a CTE (or restore it as a model first).
-- original marts.yml block preserved at the bottom of this file.

{{ config(materialized='view') }}

-- Q2: which skills the top payers ask for — a mart built on a mart

WITH top_jobs AS (
    SELECT * FROM {{ ref('top_paying_jobs') }}
),

bridge AS (
    SELECT * FROM {{ ref('job_skills_bridge') }}
),

skills AS (
    SELECT * FROM {{ ref('dim_skill') }}
)

SELECT
    skills.skill_id,
    skills.display_name,
    skills.category,
    COUNT(*) AS top_job_mentions
FROM top_jobs
INNER JOIN bridge USING (job_id)
INNER JOIN skills USING (skill_id)
GROUP BY skills.skill_id, skills.display_name, skills.category
ORDER BY top_job_mentions DESC

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
