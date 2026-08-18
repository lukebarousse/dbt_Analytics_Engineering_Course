-- the jinja-loop walkthrough artifact: you write the loop, dbt writes the sql.
-- read the expansion at target/compiled/analytics/models/intermediate/jobs_pivot.sql.
-- slugify names the columns, same macro the staging flags use (call site #2).
-- deliberately time-free (role columns over all history): slicing by month would
-- count a re-scraped job once per month and reopen the dedupe question fct settles.

{% set roles = ['Data Analyst', 'Data Engineer', 'Data Scientist'] %}

select
    {%- for role in roles %}
    count(distinct case when search_term = '{{ role }}' then job_id end)
        as {{ slugify(role) }}_postings
        {%- if not loop.last %},{% endif %}
    {%- endfor %}
from {{ ref('int_job_postings_enriched') }}
