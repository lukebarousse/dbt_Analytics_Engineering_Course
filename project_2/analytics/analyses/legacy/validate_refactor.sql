-- written at 3.51 to prove the 3.41 carve changed nothing: same rows, same total
-- mentions, before and after the refactor. compiled with
-- `dbt compile --select validate_refactor`, pasted into the Databricks SQL editor,
-- both sides matched. point-in-time QA: nobody reruns this after 3.73, where the
-- fct dedupe legitimately moves the numbers (that's the dedupe working, not the
-- refactor breaking).
--
-- 2026-08 (the 3.51 demotion): one_big_query.sql left models/, so ref() can't see
-- it anymore, and dbt parses every ref in analyses. the old side now points at the
-- leftover relation dbt built back in 3.21 and never dropped. a hardcoded reference
-- for the hardcoded-era query; this file is a record of the refactor, not part of
-- the pipeline.
-- 4.31: validated the 3.41 carve; superseded by the capstone generalization.

select
    'old' as pipeline,
    count(*) as row_count,
    sum(mention_count) as total_mentions
from dev.default.one_big_query

union all

select
    'new' as pipeline,
    count(*) as row_count,
    sum(mention_count) as total_mentions
from {{ ref('in_demand_skills') }}
