-- the monthly volume check — a QUESTION, so it lives in analyses (compiled,
-- never materialized): how many distinct jobs did each scrape month bring in?
-- refs int, never fct, on purpose: count(distinct job_id) at scrape grain ignores
-- re-scrapes, so these numbers never moved when fct started deduping. monthly
-- deduped-per-job counts are fct_job_postings' grain to serve, not this model's claim.
-- dbt.date_trunc is the cross-warehouse spelling; on databricks it compiles to
-- plain date_trunc (read the compiled file)

select
    {{ dbt.date_trunc('month', 'search_date') }} as month,
    count(distinct job_id) as postings
from {{ ref('int_job_postings_enriched') }}
group by all
order by month
