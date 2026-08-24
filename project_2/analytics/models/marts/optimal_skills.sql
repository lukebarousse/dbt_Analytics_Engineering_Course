{{ config(materialized='view') }}

-- Q5: high demand AND high salary; the demand floor keeps
-- one-posting salary outliers out of the ranking.
-- the capstone mart — self-contained on the star (fct ⋈ bridge ⋈ dim_skill):
-- demand counts ALL jobs, the salary average only the salaried ones (avg()
-- skips nulls itself). Q1/Q3 live in analyses/, Q2/Q4 in the supporter bonus.

WITH bridge AS (
    SELECT * FROM {{ ref('job_skills_bridge') }}
),

job_postings AS (
    -- the comparable-pay rule, stated once for this file: USD yearly only.
    -- derived here (not a WHERE) so the demand denominator still counts every job
    SELECT
        job_id,
        CASE
            WHEN salary_currency = 'USD' AND salary_period = 'year'
            THEN salary_avg
        END AS salary_year_usd
    FROM {{ ref('fct_job_postings') }}
),

skills AS (
    SELECT * FROM {{ ref('dim_skill') }}
)

SELECT
    skills.skill_id,
    skills.display_name,
    skills.category,
    COUNT(DISTINCT bridge.job_id) AS demand_count,
    ROUND(COUNT(DISTINCT bridge.job_id) / (SELECT COUNT(*) FROM job_postings), 4) AS demand_pct,
    ROUND(AVG(job_postings.salary_year_usd), 0) AS avg_salary_year
FROM bridge
INNER JOIN job_postings USING (job_id)
INNER JOIN skills USING (skill_id)
GROUP BY skills.skill_id, skills.display_name, skills.category
HAVING COUNT(DISTINCT bridge.job_id) >= 100
   AND AVG(job_postings.salary_year_usd) IS NOT NULL
ORDER BY avg_salary_year DESC, demand_count DESC
