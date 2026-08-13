-- one_big_query.sql
--
-- the question: which skills do Data Engineer postings ask for most,
-- and how many of those postings even bother to post a salary?
--
-- written at 3.11 the way you'd hack it out in a SQL editor: one giant query,
-- nested subqueries, everything hardcoded. it produced the course's first real
-- answer at 3.12, and every sin in it is load-bearing for a later lesson:
--   * catalog paths hardcoded 3 times (the 3.41 refactor swaps in source())
--   * the same WHERE clause copy-pasted into two branches
--   * 'Data Engineer' as a magic string, twice
--   * COUNT(*) at scrape grain, so re-scraped postings count again every time
--     (3.73 puts a number on exactly how wrong that is)
--
-- DEMOTED to analyses/legacy at 3.51: dbt still compiles it, it never ships as
-- a table again. this is the "before" photo of the refactor. do not clean it up.

SELECT
    skill_counts.skill_keyword,
    skill_counts.mention_count,
    totals.total_postings,
    totals.postings_with_salary,
    ROUND(100.0 * totals.postings_with_salary / totals.total_postings, 1) AS pct_with_salary
FROM
    (
        -- branch 1: skill mentions across Data Engineer postings
        SELECT
            skills.skill_keyword,
            COUNT(*) AS mention_count
        FROM
            (
                SELECT
                    job_id,
                    job_title,
                    -- company_name,
                    -- job_location,
                    -- job_via,
                    -- job_schedule_type,
                    search_term,
                    search_date,
                    error
                FROM workspace.bronze.raw_job_postings
                WHERE error = false AND search_term = 'Data Engineer'
            ) AS postings
        INNER JOIN
            (
                SELECT
                    job_id,
                    skill_id,
                    skill_keyword
                FROM workspace.bronze.raw_job_skills
            ) AS skills
            ON postings.job_id = skills.job_id
        GROUP BY
            skills.skill_keyword
    ) AS skill_counts
CROSS JOIN
    (
        -- branch 2: the transparency check. how many postings even show a salary?
        -- yes, this repeats the exact filter from branch 1. copy-paste was faster.
        SELECT
            COUNT(*) AS total_postings,
            COUNT(CASE WHEN job_salary IS NOT NULL THEN 1 END) AS postings_with_salary
            -- TODO: salary is text soup ('120K–160K a year', 'PKR 62,733.60 a month'),
            -- parsing it into actual numbers is a later problem
        FROM
            (
                SELECT
                    job_id,
                    job_title,
                    job_salary,
                    search_term,
                    search_date,
                    error
                FROM workspace.bronze.raw_job_postings
                WHERE error = false AND search_term = 'Data Engineer'
            ) AS de_postings
    ) AS totals
ORDER BY
    skill_counts.mention_count DESC
