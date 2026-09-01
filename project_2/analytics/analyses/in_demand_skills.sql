-- skill demand across the whole star (fct ⋈ bridge ⋈ dim_skill).
-- a QUESTION, not a model — it lives in analyses/ (3.08.2). all roles by default;
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
    SELECT * FROM {{ ref('bridge_job_skills') }}
),

skills AS (
    SELECT * FROM {{ ref('dim_skill') }}
)

SELECT
    display_name,
    category,
    COUNT(DISTINCT job_id) AS demand_count,
    ROUND(demand_count / (SELECT COUNT(DISTINCT job_id) FROM job_postings) * 100, 1) AS demand_pct
FROM bridge
INNER JOIN skills USING (skill_id)
INNER JOIN job_postings USING (job_id)
GROUP BY skill_id, skills.display_name, skills.category
ORDER BY demand_count DESC
