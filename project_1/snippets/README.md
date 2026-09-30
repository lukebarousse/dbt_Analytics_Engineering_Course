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
| `lukeb.co/dbt-schema` | `1.05/schema.yml` | 1.05 Properties, the Describe the Models step | Handed out BEFORE `persist_docs` (students type that block next, it is the dbt part), 1.06 adds `monthly_summary`, 1.08 adds `data_tests` | Diff vs live is exactly the four `persist_docs` blocks, the `monthly_summary` entry, the four `data_tests` blocks and 1.08's null-count note on `job_location`; `dbt build` at that state (no `monthly_summary.sql`) = 3 models, 0 tests, descriptions in the manifest, no column comments yet |
| `lukeb.co/dbt-summary` | `analytics/models/monthly_summary.sql` (live, not frozen) | 1.06 Multiple ref() | Born in 1.06 and never touched again (0 hits for qualify/is_incremental/row_number/unique_key/config); points straight at the answer key | `curl -sL lukeb.co/dbt-summary -o models/monthly_summary.sql` then `dbt run --select monthly_summary` |
| `lukeb.co/dbt-summary-yml` | `1.06/monthly_summary.yml` | 1.06 Multiple ref(), the schema.yml step | 1.08 adds `data_tests` (not_null, unique on `month`) to this entry | Fragment, indented to sit under `models:`, opens with a blank line so `>>` never welds onto the previous entry; appended to the 1.05 schema.yml + `monthly_summary.sql`: `dbt build` 4/4, all four column comments persisted |

Student commands:

```bash
# 1.05: print it to paste into models/properties.yml
curl -sL lukeb.co/dbt-schema

# 1.06: append the monthly_summary entry to the split file
curl -sL lukeb.co/dbt-summary-yml >> models/schema.yml
```
