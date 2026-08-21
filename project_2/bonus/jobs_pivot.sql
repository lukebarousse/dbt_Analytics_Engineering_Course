-- DEMOTED TO BONUS 2026-08-19 (Luke): not needed by the final model; candidate
-- for the supporter "advanced macros/jinja" tier. Lives outside analytics/ so
-- dbt never parses it. To resurrect: drop into models/marts/ and restore the
-- yml block preserved at the bottom of this file. 3.04.2's core loop example is
-- now staging's has_* flags.
--
-- the jinja-loop walkthrough artifact: you write the loop, dbt writes the sql.
-- read the expansion at target/compiled/analytics/models/intermediate/jobs_pivot.sql.
-- slugify names the columns, same macro the staging flags use (call site #2).
-- deliberately time-free (role columns over all history): slicing by month would
-- count a re-scraped job once per month and reopen the dedupe question fct settles.

{% set roles = ['Data Analyst', 'Data Engineer', 'Data Scientist'] %}

SELECT
    {%- for role in roles %}
    COUNT(DISTINCT CASE WHEN search_term = '{{ role }}' THEN job_id END)
        AS {{ slugify(role) }}_postings
        {%- if not loop.last %},{% endif %}
    {%- endfor %}
FROM {{ ref('int_job_postings_enriched') }}

{#- preserved marts.yml block (was the last entry; restore alongside the model):
  - name: jobs_pivot
    description: >
      One-row pivot of distinct jobs per search role, written by a Jinja loop; read
      the compiled file for the SQL dbt wrote. Time-free by design: role columns
      over all history, because a month axis would count re-scraped jobs once per
      month.
    columns:
      - name: data_analyst_postings
        description: Distinct jobs found by the 'Data Analyst' search.
      - name: data_engineer_postings
        description: Distinct jobs found by the 'Data Engineer' search.
      - name: data_scientist_postings
        description: Distinct jobs found by the 'Data Scientist' search.
-#}
