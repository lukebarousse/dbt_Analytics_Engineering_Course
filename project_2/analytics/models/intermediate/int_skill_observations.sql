-- staging cleans, intermediate thinks, marts serve. the thinking here is a
-- re-grain: 3,304,574 raw (job, skill) pairs collapse to one row per skill.
-- counts run against staging on purpose — they include pairs whose job never
-- made fct (the orphan finding), so this is "observed in the wild", not
-- "observed in the star"; dim_skill serves it with the seed's taxonomy.

WITH job_skills AS (
    SELECT * FROM {{ ref('stg_job_skills') }}
)

SELECT
    skill_id,
    COUNT(DISTINCT job_id) AS postings_with_skill
FROM job_skills
GROUP BY skill_id
