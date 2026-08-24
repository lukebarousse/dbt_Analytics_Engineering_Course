WITH skill_categories AS (
    SELECT * FROM {{ ref('skill_categories') }}
),

observations AS (
    SELECT * FROM {{ ref('int_skill_observations') }}
)

-- a pure SERVE model: intermediate did the counting, the seed brings the
-- taxonomy; every observed skill_id sits inside the 1,422-row seed, so the
-- seed is the spine
SELECT
    skill_id,
    display_name,
    category,
    subcategory,
    COALESCE(postings_with_skill, 0) AS postings_with_skill
FROM skill_categories
LEFT JOIN observations USING (skill_id)
