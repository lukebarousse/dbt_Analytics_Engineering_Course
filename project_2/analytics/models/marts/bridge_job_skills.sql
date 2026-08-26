WITH job_skills AS (
    SELECT * FROM {{ ref('stg_job_skills') }}
),

job_postings AS (
    SELECT * FROM {{ ref('fct_job_postings') }}
)

-- inner join scopes pairs to jobs that made fct. on today's data it drops
-- zero rows — it's here so integrity holds by construction, not by luck,
-- when the data changes
SELECT
    job_id,
    skill_id,
    skill_keyword
FROM job_skills
INNER JOIN job_postings USING (job_id)
