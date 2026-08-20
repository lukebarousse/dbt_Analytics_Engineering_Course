WITH skill_categories AS (
    SELECT * FROM {{ ref('skill_categories') }}
),

job_skills AS (
    SELECT * FROM {{ ref('stg_job_skills') }}
),

observations AS (
    SELECT
        skill_id,
        COUNT(DISTINCT job_id) AS postings_with_skill
    FROM job_skills
    GROUP BY skill_id
)

-- every observed skill_id sits inside the 1,422-row seed, so the seed is the spine
SELECT
    skill_id,
    display_name,
    category,
    subcategory,
    COALESCE(postings_with_skill, 0) AS postings_with_skill
FROM skill_categories
LEFT JOIN observations USING (skill_id)
