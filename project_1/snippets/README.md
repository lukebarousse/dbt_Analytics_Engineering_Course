# snippets/

Files the videos hand out so you paste instead of type. Each file is frozen
at the lesson that uses it, so it can sit behind the finished `analytics/`
on purpose: later lessons add tests and models on camera.

| Lesson | Short link | What you get |
| --- | --- | --- |
| 1.05 Properties | `lukeb.co/dbt-schema` | `schema.yml` for the three models, before `persist_docs` and tests |
| 1.06 Multiple ref() | `lukeb.co/dbt-summary` | `monthly_summary.sql` (points at the live model) |
| 1.06 Multiple ref() | `lukeb.co/dbt-summary-yml` | the `monthly_summary` entry to append to `schema.yml` |

How to use a link:

```bash
curl -sL lukeb.co/dbt-schema                                   # print it, then paste
curl -sL lukeb.co/dbt-summary -o models/monthly_summary.sql     # save it as a file
curl -sL lukeb.co/dbt-summary-yml >> models/schema.yml          # append it to a file
```
