# snippets/

Paste-ready files for the video, same contract as `project_2/snippets/`:
every file here is **frozen** at the state of the lesson that hands it out,
so it is deliberately behind `analytics/`. Do not sync a snippet forward to
match the current models; that hands students code from a lesson they have
not reached yet.

A snippet only exists when a LATER lesson modifies the file. Otherwise the
lesson points `curl` straight at the live `analytics/` file.

| Short link | File | Lesson | Why frozen | Verified |
| --- | --- | --- | --- | --- |
| `lukeb.co/dbt-schema` | `1.05/schema.yml` | 1.05 Properties | 1.06 adds `monthly_summary`, 1.08 adds `data_tests` | Diff vs live is exactly the `monthly_summary` entry, the four `data_tests` blocks and 1.08's null-count note on `job_location`; `dbt build` at the 1.05 state (no `monthly_summary.sql`) = 3 models, 0 tests, every description persisted as a column comment |

Student commands:

```bash
# print it to paste into models/properties.yml (the Describe the Models step)
curl -sL lukeb.co/dbt-schema

# or, at the end-of-lesson split, download it whole
curl -sL lukeb.co/dbt-schema -o models/schema.yml
```
