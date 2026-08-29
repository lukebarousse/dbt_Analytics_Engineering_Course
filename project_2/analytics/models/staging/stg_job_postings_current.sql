-- snapshot INPUT, not served: picks each job's current row as of the
-- time-machine cutoff. ephemeral — inlined into the snapshot's SQL, never
-- lands in the warehouse (1.07.4's materialization, finally load-bearing).
{{ config(materialized='ephemeral') }}

SELECT *
FROM {{ ref('stg_job_postings') }}
-- the cutoff is a DAY: 'world through July 1' includes all of July 1.
-- (the cast also tames run_started_at's +00:00 offset rendering)
WHERE search_date <= CAST('{{ var("as_of", run_started_at) }}' AS DATE)
-- 3.09.4's dedupe pattern, new job: pick the current row as of the cutoff.
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY job_id
    ORDER BY searched_at DESC
) = 1
