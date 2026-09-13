# snippets/

Paste-ready code for the video. Each file is a fragment students drop into a
file they are already editing, printed straight to their terminal:

```bash
curl -sL <link>
```

## The contract: these files are FROZEN

Every snippet is frozen at the state of the lesson that hands it out, which
means it is **deliberately behind** `analytics/`. The 3.06 salary columns, for
example, carry the parse written out twice, because the macro that removes the
duplication is the next thing the lesson teaches.

**Do not "fix" a snippet to match the current models.** Syncing them forward
would hand students code from a lesson they have not reached yet, which is the
exact problem this folder exists to solve.

If a snippet's underlying logic genuinely changes, update the snippet to the
new version *of that lesson's state*, and re-verify it against the models the
same way it was verified when it was written.

## What belongs here

The rule is **paste the SQL, type the dbt.** A snippet carries the long,
mechanical SQL that teaches nothing about dbt. Anything that demonstrates a dbt
feature stays a live edit on camera, so students always type the part the
course is actually about.

| File | Lesson | Verified |
| --- | --- | --- |
| `3.06_salary_columns.sql` | 3.06 Macros Pt.2 | Matches the shipped `parse_salary()` output on all 685,695 rows (0 mismatches across min, max, period, currency) |
| `3.07/fct_job_postings.sql` | 3.07 Fact Table | Compiles with 0 QUALIFY / is_incremental / ROW_NUMBER (the four features 3.09 and 3.11 add later) |
| `3.07/marts.yml` | 3.07 Fact / Dimensions / Bridge | Parses; 4 models, 18/3/5/3 columns, every description preserved; diff vs live is exactly 5 `data_tests:` removals |

## Frozen here, or live from `analytics/`?

A snippet only exists when a LATER lesson modifies the file. Otherwise the
lesson points `curl` straight at the live model, which never drifts from the
answer key and costs nothing to maintain.

3.07 hands students six files. Verified file by file:

| Short link | File | Source |
| --- | --- | --- |
| `lukeb.co/dbt-int` | `int_skill_observations.sql` | live |
| `lukeb.co/dbt-fct` | `fct_job_postings.sql` | **frozen** (3.09 adds QUALIFY, 3.11 adds incremental) |
| `lukeb.co/dbt-dim-company` | `dim_company.sql` | live |
| `lukeb.co/dbt-dim-skill` | `dim_skill.sql` | live |
| `lukeb.co/dbt-bridge` | `bridge_job_skills.sql` | live |
| `lukeb.co/dbt-int-yml` | `intermediate.yml` | **frozen** (3.09 adds `data_tests` on skill_id) |
| `lukeb.co/dbt-marts` | `marts.yml` | **frozen** (3.09 adds 5 `data_tests:` blocks) |

`marts.yml` is downloaded ONCE, whole, at the Fact Table topic. It documents
all four marts, so until the dimensions and bridge are built dbt prints
`Did not find matching node for patch with name ...` for each one. That is a
warning, not an error, and the lesson calls it out. An earlier design split
this file into three append-able fragments; it was dropped as too fragile
(the `>>` seam silently welded lines when a fragment lost its trailing blank
line). Do not reintroduce it.

⚠️ Before adding a live link, grep the file for later-lesson features. The
SQL check is `qualify|is_incremental|row_number|unique_key`; for a `.yml` it
is `data_tests`, which that SQL pattern does not catch.
