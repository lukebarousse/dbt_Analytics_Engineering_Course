# bonus/

Extra SQL and YAML that the videos do not cover. dbt never reads this folder:
nothing here is needed for the project to build.

| File | What it is |
| --- | --- |
| `top_paying_jobs.sql` | Q1 of the famous five: the highest-paying postings |
| `top_paying_job_skills.sql` | Q2: the skills behind those top-paying jobs (needs Q1 next to it) |
| `jobs_pivot.sql` | A `dbt_utils` pivot, from the advanced macros material |
| `salary_changers.sql` | Postings whose salary changed between scrapes, read from the snapshot |
| `semantic_layer/` | MetricFlow semantic models and a time spine, with their own README |

To try one: copy the `.sql` file into `analytics/analyses/`, run `dbt compile`,
and paste the compiled SQL into the Databricks SQL editor.
