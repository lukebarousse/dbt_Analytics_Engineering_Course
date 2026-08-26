# DEMOTED TO SUPPORTER BONUS (Luke, 2026-08-26)

MetricFlow / the semantic layer left the core course: emerging surface,
dbt Cloud-gated APIs, weak on-camera payoff vs its freight. Named in one
capstone beat; taught here instead.

Contents: the three semantic models (2 metrics), time_spine (MetricFlow's
required calendar), and its properties yml. All gate-verified on Databricks
Free Edition (mf query works, 2026-08-12).

To resurrect in a project:
1. `uv add 'dbt-metricflow[databricks]'`
2. semantic yml files -> models/semantic_models/, time_spine -> models/utilities/
3. dbt_project.yml: `utilities: {+materialized: table, +schema: marts}`
4. bridge_job_skills needs `search_date` carried from fct again (the
   job_skills semantic model's agg_time_dimension)
5. `dbt build` then `mf query --metrics total_job_postings`
