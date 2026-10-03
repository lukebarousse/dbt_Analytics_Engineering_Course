# snippets/

Files the videos hand out so you paste instead of type. Each file is frozen
at the lesson that uses it, so it can sit behind the finished `analytics/`
on purpose: later lessons add tests and features on camera.

| Lesson | Short link | What you get |
| --- | --- | --- |
| 3.03 Properties YAML | `lukeb.co/dbt-staging-yml` | `staging.yml`: both staging models, every column described, no tests yet |
| 3.06 Macros Pt.2 | `lukeb.co/dbt-salary` | the four salary columns to paste into `stg_job_postings.sql` |
| 3.07 The Star Schema | `lukeb.co/dbt-int` · `dbt-fct` · `dbt-dim-company` · `dbt-dim-skill` · `dbt-bridge` | the five star models |
| 3.07 The Star Schema | `lukeb.co/dbt-int-yml` · `dbt-marts` | `intermediate.yml` and `marts.yml`, before the 3.09 tests |
| 3.07 Seeds | `lukeb.co/skill-categories` | the `skill_categories.csv` seed |

How to use a link:

```bash
curl -sL lukeb.co/dbt-salary                                  # print it, then paste
curl -sL lukeb.co/dbt-staging-yml -o models/staging/staging.yml   # save it as a file
```

Files not listed here (`dbt-int`, `dbt-dim-*`, `dbt-bridge`, `skill-categories`)
point straight at `analytics/`, because nothing changes them after the lesson.
