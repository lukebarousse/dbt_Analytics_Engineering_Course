-- Q3: skill demand across the whole star (fct ⋈ bridge ⋈ dim_skill).
-- a QUESTION, not a model — it lives in analyses/ (3.71). all roles by default;
-- pick yours with:
--   dbt compile --select in_demand_skills --vars 'job_title: Data Analyst'

WITH job_postings AS (

    SELECT job_id
    FROM {{ ref('fct_job_postings') }}
    {% if var('job_title', none) %}
    WHERE search_term = '{{ var("job_title") }}'
    {% endif %}

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
    COUNT(DISTINCT bridge.job_id) AS demand_count,
    ROUND(COUNT(DISTINCT bridge.job_id) / (SELECT COUNT(*) FROM job_postings), 4) AS demand_pct
FROM bridge
INNER JOIN job_postings USING (job_id)
INNER JOIN skills USING (skill_id)
GROUP BY skills.skill_id, skills.display_name, skills.category
ORDER BY demand_count DESC
