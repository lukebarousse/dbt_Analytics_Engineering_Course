WITH job_skills AS (
    SELECT * FROM {{ ref('stg_job_skills') }}
),

job_postings AS (
    SELECT * FROM {{ ref('fct_job_postings') }}
)

-- inner join scopes pairs to jobs that made fct; fct is one row per job,
-- so the (job_id, skill_id) grain survives the join
SELECT
    job_id,
    skill_id,
    skill_keyword,
    -- carried from fct: the metrics layer needs an agg time dimension on the bridge
    job_postings.search_date
FROM job_skills
INNER JOIN job_postings USING (job_id)
