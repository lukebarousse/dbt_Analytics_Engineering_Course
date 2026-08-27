-- snapshot INPUT, not served: picks each job's current row as of the
-- time-machine cutoff. ephemeral — inlined into the snapshot's SQL, never
-- lands in the warehouse (1.07.4's materialization, finally load-bearing).
{{ config(materialized='ephemeral') }}

SELECT *
FROM {{ ref('stg_job_postings') }}
-- explicit cast: run_started_at renders with a +00:00 offset
WHERE searched_at <= CAST('{{ var("as_of", run_started_at) }}' AS TIMESTAMP)
-- 3.09.4's dedupe pattern, new job: pick the current row as of the cutoff.
-- job_title tiebreaker: one job_id carries two rows with identical searched_at
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY job_id
    ORDER BY searched_at DESC, job_title
) = 1
