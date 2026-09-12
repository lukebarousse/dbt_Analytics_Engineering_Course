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
