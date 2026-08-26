{{ config(materialized='view') }}

-- Q5: high demand AND high salary; the demand floor keeps
-- one-posting salary outliers out of the ranking.
-- the capstone mart — self-contained on the star (fct ⋈ bridge ⋈ dim_skill):
-- demand counts ALL jobs, the salary average only the salaried ones (avg()
-- skips nulls itself). Q3/Q4 live in analyses/, Q1/Q2 in the supporter bonus.

WITH bridge AS (
    SELECT * FROM {{ ref('bridge_job_skills') }}
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
    skills.display_name,
    skills.category,
    COUNT(DISTINCT bridge.job_id) AS demand_count,
    ROUND(demand_count / (SELECT COUNT(DISTINCT job_id) FROM job_postings) * 100, 1) AS demand_pct,
    ROUND(AVG(job_postings.salary_year_usd), 0) AS avg_salary_year
FROM bridge
INNER JOIN job_postings USING (job_id)
INNER JOIN skills USING (skill_id)
GROUP BY skills.display_name, skills.category
HAVING COUNT(DISTINCT bridge.job_id) >= 100
   AND AVG(job_postings.salary_year_usd) IS NOT NULL
ORDER BY avg_salary_year DESC, demand_count DESC
