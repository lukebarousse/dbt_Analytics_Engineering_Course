-- ===========================================================================
-- 3.06 - the salary columns, before the macro
--
-- Paste this INSIDE the cleaned CTE of models/staging/stg_job_postings.sql,
-- directly under the `job_salary,` line.
--
-- Yes, salary_min and salary_max are the same twelve lines twice, with one
-- thing changed. That is not a mistake, it is the whole point of the lesson.
-- ===========================================================================

        TRY_CAST(REPLACE(REGEXP_EXTRACT(SPLIT(job_salary, '–')[0], '([0-9][0-9,.]*)', 1), ',', '') AS DECIMAL(15, 2))
            * CASE UPPER(REGEXP_EXTRACT(SPLIT(job_salary, '–')[0], '[0-9][0-9,.]*([KkMm])', 1))
                WHEN 'K' THEN 1000
                WHEN 'M' THEN 1000000
                ELSE 1
              END AS salary_min,
        TRY_CAST(REPLACE(REGEXP_EXTRACT(ELEMENT_AT(SPLIT(job_salary, '–'), -1), '([0-9][0-9,.]*)', 1), ',', '') AS DECIMAL(15, 2))
            * CASE UPPER(REGEXP_EXTRACT(ELEMENT_AT(SPLIT(job_salary, '–'), -1), '[0-9][0-9,.]*([KkMm])', 1))
                WHEN 'K' THEN 1000
                WHEN 'M' THEN 1000000
                ELSE 1
              END AS salary_max,
        NULLIF(REGEXP_EXTRACT(job_salary, 'an? (year|hour|month|day|week)$', 1), '') AS salary_period,
        -- leading marker ('PKR', 'CA$', '₱', ...); a salaried row with NO marker is
        -- assumed USD — stamped explicitly so consumers write salary_currency = 'USD'
        -- instead of remembering what a null means. salary-less rows stay null
        CASE
            WHEN job_salary IS NOT NULL
            THEN COALESCE(NULLIF(TRIM(REGEXP_EXTRACT(job_salary, '^([^0-9]+)', 1)), ''), 'USD')
        END AS salary_currency,
