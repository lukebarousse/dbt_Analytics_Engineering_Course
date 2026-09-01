<!-- NUMBERING NOTE (2026-08-13): this contract was designed against the PRE-restructure
chapter-3 numbering. Translation to current course numbering:
  contract 3.11 kickoff        -> now 3.11 Kickoff + 3.2x Local Setup (scaffold/connect split out)
  contract 3.12 cloud load     -> now 3.14 Ingest Data (LOAD MECHANICS OVERRIDDEN: the locked
                                  ingestion path is the load_bronze NOTEBOOK downloading from the
                                  GitHub release in-platform -- NO Catalog Explorer upload, no local
                                  files. The notebook params idea (month_cutoff / append_month) IS
                                  adopted for the 4.1x simulation.)
  contract 3.13 BQ portability -> LESSON REMOVED in restructure; dialect-break/portability beats
                                  need a new home (reconciliation item, see chat digest)
  contract 3.21->3.31 3.22->3.32 3.31->3.41 3.32->3.42 3.33->3.43 3.41->3.51 3.42->3.52
  contract 3.51->3.61 3.52->3.62 3.61->3.71 3.62->3.72 3.63->3.73 3.71->3.81 ; 4.x unchanged.
-->

<!-- AMENDMENTS (2026-08-13 — Luke's flag decisions + the BigQuery purge):
INVESTIGATION (flag 6): NOTHING in P2 was built on BigQuery. All BQ references in this
contract trace to TWO stale Notion rows (the old "3.12 BigQuery setup & load" and
"3.13 Warehouse portability & the swap") that the extraction phase read mid-restructure.
The build is Databricks-only: bronze is live on the course workspace, every verification
ran on Databricks, the repo's only adapter is dbt-databricks.
PURGED from this contract: the BQ side-load beat (3.12 row), the entire portability-swap
lesson (3.13 row — already deleted in the ch3 restructure), "green in both warehouses"
framing, and `bq mk`. The dbt.date_trunc dialect-break beat is RETIRED from core with the
portability lesson (adapter portability stays a 3.22 mention; cross-warehouse = bonus-tier
candidate). The monolith's table-not-found-on-BQ beat dies with it; its hardcoding sins
are still taught by the refactor itself.
FLAG DECISIONS (Luke): 1 KEEP dim_company (paste-not-type; first cut if capstone runs
long) · 2 orphan tests AS CONTRACTED · 3 fct dedupe lands at the 157k lesson's CLOSE ·
4 MOOT (BQ purged; 'bronze' naming already implemented) · 5 keep 'Data Engineer'
hardcoded in v1 BUT the capstone generalization must give students a pick-your-role
mechanism (var('job_title') or role-parameterized mart — decide at build; ties to P1's
personalization) · 6 ACCEPT — reworded "green in dev, prod, and on a schedule" ·
7 verify-then-script (MetricFlow demo shape locked by verification item (i)).

AMENDMENT (2026-08-17 — Luke's catalog-per-environment redesign, VERIFIED live):
Environments moved from schema prefixes to CATALOGS. dev/prod catalogs created on
Free Edition (CREATE CATALOG works); profile targets differ by ONE line (catalog:
dev vs prod; schema: default on both — nothing lands there, every model declares
its layer). generate_schema_name shrank to the 5-line no-env-logic docs version.
Layer schemas CLEAN in both envs (dev.silver/dev.gold, prod.silver/prod.gold);
bronze stays workspace.bronze (shared, notebook-owned, sources.yml unchanged).
Full DAG re-verified green into the dev catalog (PASS=46 WARN=2, 2026-08-17);
prod target connection verified. SUPERSEDES: the contract §0 dev_-prefix pin, the
4.21 bare-schema reveal, the 4.23 generated-profile prefix concern (moot — the
job's catalog dropdown now simply selects prod). Lesson 3.2 also restructured
same day: 3.21 env · 3.22 profile (+ CREATE CATALOG dev) · 3.23 connect via
dbt init --profile databricks · 3.24 local test (dbt show round trip); CLI topic
deleted. dbt init taught with --profile flag (collision beat retired).

AMENDMENT (2026-08-17, later — Luke: ONE NAMING LANGUAGE, dbt conventions win):
Warehouse schemas now MIRROR the repo folders — dev/prod catalogs contain
staging, intermediate, marts (+utilities→marts), seeds, snapshots. Medallion
(bronze/silver/gold) is DEMOTED to vocabulary, taught once at 3.31 as the
Databricks dialect for the same layers — objects never use it. Landing zone:
raw.jobs (schema named for the SOURCE SYSTEM per dbt convention; source name
'jobs'; volume /Volumes/raw/jobs/files; tables keep scraper names). Verified
live: notebook end-to-end as job (counts exact), dev catalog reset + full
rebuild green (PASS=46 WARN=2), dev schemas = staging/intermediate/marts/
seeds/snapshots. SUPERSEDES all silver/gold schema references in this file.
-->

# P2 Build Contract — SILVER + GOLD Layers (REVISED)
**dbt reference pipeline for the dbt Analytics Engineering course (Project #2, Databricks Free Edition)**

Prime directive honored throughout: every transformation below exists because a mapped course concept needs it, and every Advanced-era concept row has a concrete home. Where "cleaner" and "teaches better" conflicted, teaching won. Numbers cited are the live-verified counts and must not drift. All previously-verified timings (debug ~15s, build 22–27s, job 1m57s) came from the 9-model gate project — a **re-timing pass on the final ~20-node DAG is queued** and no latency number may be scripted until it clears.

---

## 0. System overview

```
bronze (OUTSIDE dbt: UC volume upload → ingestion notebook CTAS; dbt sources, source name 'bronze')
  raw_job_postings (843,097 scrape-grain rows)      raw_job_skills (3,304,574 pairs)
        │                                                  │
SILVER (schema: silver · prod / dev_silver · dev) ─────────┼──────────────
  stg_job_postings (view, SCRAPE GRAIN, 685,695 post-3.63) stg_job_skills (view, keeps orphans)
        │                                                  │
  int_job_postings_enriched (view, scrape grain)     [seed] skill_categories (1,422 rows)
        │                                                  │
  snapshots/job_postings_snapshot (SCD2, var('as_of'))     │
        │                                                  │
GOLD (schema: gold · prod / dev_gold · dev) ───────────────┼──────────────
  fct_job_postings (incremental+merge, ONE ROW PER JOB) ── job_skills_bridge (table, carries search_date)
        │                                                  │        │
  dim_company · time_spine                            dim_skill (seed + observed)
        │                                                  │
  Famous Five marts: top_paying_jobs · top_paying_job_skills · in_demand_skills
                     · top_skills_by_salary · optimal_skills
  Demo marts (point at INT, never fct — dedupe-stable by construction):
                     jobs_per_month (dbt.date_trunc home) · jobs_pivot (Jinja loop home)
  Semantic layer: 3 semantic models (job_postings, job_skills, dim_skill) + 2 metrics
                     (total_job_postings, skill_demand_pct)

LEGACY (after 3.41): analyses/legacy/one_big_query.sql + analyses/legacy/validate_refactor.sql
  (validate_refactor is EDITED at the demotion beat — no ref('one_big_query') survives in any
   compilable path; see §2.4. dbt parses refs in analyses, so a dangling ref would kill every command.)
ANALYSES: (optional) analyses/salary_changers.sql
TESTS: staging YAML (accepted_values, not_null, relationships[warn]) · tests/assert_no_orphan_skills.sql · gold strict tests
```

**Folder tree (3.21 artifact, must match on-screen):** `models/staging/`, `models/intermediate/`, `models/marts/`, plus `seeds/`, `snapshots/`, `analyses/`, `tests/`, `macros/`. Empty folders carry a `.gitkeep` so the on-screen tree survives git until populated. Schema config: staging + intermediate → `+schema: silver`; marts → `+schema: gold`; seeds → `+schema: silver`; snapshots → silver. `persist_docs: {relation: true, columns: true}` set project-wide (column persistence on VIEWS is adapter-version-dependent — verification item (j); if views don't persist column comments on the pinned version, scope `columns: true` to tables and script it that way).

**`generate_schema_name` (provided as boilerplate at 3.21, explained at 4.21, reveal ammo in 3.52) — exact logic pinned, because the scheduled job depends on it:**

```sql
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%} {{ target.schema }}
    {%- elif target.name == 'dev' -%} dev_{{ custom_schema_name | trim }}
    {%- else -%} {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
```

Only a target literally named `dev` gets the prefix. The local dev target IS named `dev` (from 3.11 on), so **students see `dev_silver` / `dev_gold` from 3.21 until 4.21** — all screenshots and verified counts between those lessons use the `dev_`-prefixed schemas, and 3.21's script carries the planted line: "ignore that `dev_` prefix for now — it's a mystery we solve in 4.2." The 4.23 Databricks job runs plain `dbt build` under a GENERATED profile whose target is named `databricks_cluster` — not `dev` — so it resolves to bare `silver`/`gold` with zero flags. That is the scripted 4.23 beat (job log target name → Catalog Explorer bare schemas), and it retires 4.22's stale "`build --target prod` = the command a scheduler runs" line (edits sweep).

**Materialization inventory (4.23 requires all four to survive):** views (stg, int, demo marts), tables (dims, bridge, five marts), incremental (fct_job_postings), snapshot (job_postings_snapshot). Plus seed. `dbt build` covers seed + run + test + snapshot with zero packages, so the Databricks job command list stays `dbt debug` → `dbt build` (no `dbt deps` — Resolution 3).

**Diagram obligations (contracted):** the 3.21 Layers diagram must be drawn to feed the 0.32 end-state diagram directly (same boxes, more detail); the 0.3 star diagram must agree with the FINAL mart set — fct_job_postings, dim_skill, dim_company (per Flag 1), job_skills_bridge, AND time_spine — not a simplified subset.

---

## 1. SILVER SPEC

### 1.1 `stg_job_postings` — view, silver
**Grain: one row per posting per scrape day (LOCKED — snapshots need re-scrape rows).** 843,097 rows at v1; 685,695 after the 3.63 filter. Source: `source('bronze', 'raw_job_postings')`, 1:1 with the source (3.22 discipline: rename, cast, clean — no joins, no business logic).

**Databricks dialect mandate (applies to transformations 5 and 6):** serverless SQL warehouses run ANSI mode by default, and `regexp_extract` returns **empty string, not NULL, on no-match** — so a bare `CAST('' AS DOUBLE)` is a runtime error that kills the whole model. Every regex-to-number cast MUST use the defensive pattern **`try_cast(nullif(regexp_extract(...), '') as <type>)`**. This is itself a scripted teach at 3.32 ("guard every cast — one unprofiled string kills the model"), and it is guaranteed exposure at 4.1x where the final-month append feeds unprofiled data into an on-camera incremental run.

Transformations, numbered, in the order they enter the course:

1. **Import/select block from `source('bronze','raw_job_postings')`** — [source() second rep → 3.12 declaration, 3.31 application; staging 1:1 rule → 3.22]
2. **`CAST(search_time AS TIMESTAMP) AS searched_at`** — [rename+cast staging pattern, exact promised SQL → 3.22]
3. **`TRIM(company_name) AS company_name`** — [light cleaning, exact promised SQL → 3.22; the same expression shape recurs in stg_job_skills — the honest "across staging models" repetition 3.52 cites]
4. **`job_via` platform cleanup: strip the `'via '` prefix (6.3k rows, Dec 2025–Apr 2026 incident) → `source_platform`** — [text-consistency fix → 3.32; same incident window as the 6,255 null IDs — narrative echo for 3.63]. NOTE: this is a text-consistency fix, not an encoding fix. Whether a genuine mojibake/encoding case exists is verification item (g); if none exists, the 3.32 row's "encodings fixed" phrasing gets edited in the sweep — the 'via' strip does not get mislabeled to cover it.
5. **Relative posted-time → `posted_at` (timestamp) and `posted_date` (date), resolved against `searched_at`** — plain SQL `CASE` + `REGEXP_EXTRACT` with the mandatory `try_cast(nullif(...))` guard on the extracted number (see Resolution 4). Pattern classes it MUST handle (live profile): `'N hours ago'` (658,432), `'N days ago'` (14,915), NULL (14,878 → posted_date NULL, pass through), singular forms `'N day ago'`/`'N hour ago'`/`'N minute ago'` (strip trailing `s`, don't enumerate), `'N minutes ago'`, `'N month ago'`; **any unmatched future class degrades to NULL via the guard instead of erroring**. — [relative dates resolved against scrape time, literal `'10 hours ago'` demo → 3.32; feeds snapshot `updated_at` chain → 3.71]
6. **Salary text → numbers: `salary_min`, `salary_max`, `salary_period`, `salary_currency`** via guarded `REGEXP_EXTRACT` — written INLINE at 3.32 with the min and max expressions **deliberately duplicated verbatim** (the planted pain 3.52 extracts into the flagship `parse_salary(part)` macro). Pattern classes it MUST handle (live profile): EN-DASH `–` ranges (not hyphen — `'90K–140K a year'`, 111,512 + 21,897 rows); single values (`'180K a year'`, 4,347 + 2,957); `K` suffix → ×1,000; thousands commas + decimals (`'62,733.60'`); currency prefixes → `salary_currency` (`'PKR'`, `'CLP'`, …; NULL when absent = assumed USD); periods `a year / an hour / a month / a day / a week` → `salary_period`; ~79% NULL passthrough; **unprofiled shapes (e.g. `'Up to 120K a year'`) degrade to NULL via try_cast, never error**. NO annualization and NO USD filtering here — that is business logic and lives in int (Resolution 5). — [regex salary parsing → 3.32; duplication → 3.52; famous-five prerequisite → 4.31]
7. **Extension flags from `job_extensions_raw` — keyword list and column names PINNED so v1/v2/v3 are byte-identical for fct:** canonical keyword list `['Health insurance', 'Dental insurance', 'Paid time off', 'No degree mentioned']`; canonical column names = `has_` + slug: `has_health_insurance`, `has_dental_insurance`, `has_paid_time_off`, `has_no_degree_mentioned`. **v1 (3.32)** = 3 hand-written flags (health, PTO, no-degree) under exactly those final names; at least one uses a real JSON function — `array_contains(from_json(job_extensions_raw, 'array<string>'), 'Health insurance')` — the rest use `LIKE`, and the scripted contrast ("proper JSON vs pragmatic LIKE") is the beat; the same expression shape is repeated verbatim (loop bait). **v2 (3.51)** = `{% set extension_keywords = [...] %}` for-loop emitting `has_{{ keyword | lower | replace(' ', '_') }}` — the template's `has_` prefix guarantees the loop reproduces v1's names exactly (and adds `has_dental_insurance`). **v3 (3.52)** = filter chain replaced by `has_{{ slugify(keyword) }}`. fct selects these four names from 3.32 on, and nothing ever renames them. — [JSON→flag demo → 3.32; loop-generates-columns demo → 3.51; slugify call site #1 → 3.52]
8. **Pass-throughs with casts only: `job_id`, `job_title`, `job_location`, `job_schedule_type` (12,252 NULLs stay NULL — documented, not fixed), `job_work_from_home`, `search_term`, `search_date`, `search_location`, `error` (v1 only)** — [staging keeps raw truth; `search_term` untouched so accepted_values is teachable → 3.61]
9. **(3.63 Act 1, NOT before) `WHERE job_id IS NOT NULL`** — drops exactly 157,402 rows = 151,147 error rows (all error rows have NULL job_id, so one filter kills both) + 6,255 real ID-less postings from the incident window (66/2,191/955/2,938/105 by month), with eyes open. `error` column dropped from the select at the same moment (always false post-filter). **stg is UNFILTERED until 3.63** so `not_null` fails with the verified 157,402 on camera. — [test-driven cleaning, incident-vs-design verdict → 3.63]

**Tests (staging YAML, in arrival order):** `accepted_values: search_term ['Data Engineer','Data Analyst','Data Scientist']` (3.61 — runs against the UNFILTERED 843,097-row stg, error rows included; that it passes there is verification item (e), BLOCKING); `not_null: job_id` (3.63 — fails 157,402, then passes); `unique: job_id` (3.63 — fails 63,207, then **removed with a comment**: grain is one-row-per-job-per-scrape-day by design; uniqueness is promised — and tested — at fct). Column descriptions in YAML (persist_docs pushes them to Catalog Explorer).

### 1.2 `stg_job_skills` — view, silver
**Grain: one row per (job_id, skill_id) pair** (raw is already distinct pairs). Source: `source('bronze','raw_job_skills')`, 1:1.

1. **Import/select from source; casts and column ordering (`job_id`, `skill_id`, `skill_keyword`)** — [the deliberately boring staging model: "some staging models just rename and cast — that's the discipline working" → 3.22]
2. **`TRIM(skill_keyword) AS skill_keyword`** — the same cleaning expression shape as stg_job_postings' company_name — [makes 3.52's "repeated across staging models" line literally true without making the model less boring]
3. **NO orphan filtering, ever** — the ~13% of pairs whose job_id has no surviving parent MUST remain — [relationships finding → 3.61; singular test → 3.62; architectural resolution is job_skills_bridge, not deletion → 3.63/gold]

**Tests:** `not_null: job_id, skill_id`; `relationships: job_id → ref('stg_job_postings') job_id` — **fails with the real orphan gap on camera at 3.61 — against PRE-filter staging** (the filter arrives 3.63), so the on-camera failure count is the PRE-filter number — verification items (c)/(n): pin the pre-filter count/%, and confirm the orphan set is identical pre- and post-filter (it should be: only NULL-job_id parents are dropped, and NULL parents never satisfy a relationships match anyway). Then configured `severity: warn` (teaches severity config; keeps the finding visible without blocking builds). `tests/assert_no_orphan_skills.sql` (3.62) targets this same pair with the exact promised SQL — also against pre-filter staging, while orphans visibly exist. **3.62's scripted closer acknowledges the reversal on purpose:** "yes — one lesson after we set this to warn, I broke the build on purpose. Next lesson we decide what this data actually deserves."

### 1.3 Seed: `seeds/skill_categories.csv` — silver
1,422 rows: `skill_id, display_name, category, subcategory`. Enters at 3.42 exactly when `dim_skill` needs it, never before (nothing upstream may depend on it). Ref'd like a model: `{{ ref('skill_categories') }}`. — [seeds as version-controlled reference data, input-type-not-layer framing → 3.42]

### 1.4 `int_job_postings_enriched` — view, silver
**Grain: one row per posting per scrape day (unchanged — silver keeps scrape grain).** Born during the 3.31 carve as the "do the thinking once" layer — **v1 (3.31) is a thin passthrough** (import CTE on stg, select-star-plus-nothing, its job explained: "staging cleans, intermediate thinks, marts serve — the thinking arrives next lesson"). Written flat at 3.31; import-CTE header retrofitted on camera at 3.33 (a deliberate mini-refactor rep).

1. **(added at 3.32's close) `salary_year_avg`: computed ONCE, USD-only** — `salary_currency IS NULL AND salary_period = 'year'` → `(salary_min + salary_max)/2` (or the single value); `... = 'hour'` → avg × 2080; month/day/week and any non-null currency → NULL, documented in YAML. The datanerd production rule, encoded once, cited on camera. It CANNOT exist at 3.31 — salary_min/max are born at 3.32 — which is why int v1 is a passthrough. — [business logic belongs in int, not staging → 3.21/3.22 contrast; currency decision → Resolution 5; famous-five fuel → 4.31]
2. **`salary_is_parsed` / convenience flags as needed by marts** — kept minimal.
3. **Pass everything else through** — int is thin by design. **int is also the permanent home of both demo marts' upstream ref** (jobs_per_month, jobs_pivot) — scrape grain + `COUNT(DISTINCT job_id)` makes their numbers immune to BOTH of 3.63's Acts (COUNT(DISTINCT) ignores NULL job_ids, and int never dedupes), so nothing shown on camera at 3.12/3.13/3.51 shifts later.

### 1.5 Snapshot: `snapshots/job_postings_snapshot.sql` — SCD2, silver
Promised shape kept: `{% snapshot %}` with `unique_key='job_id'`, `strategy='timestamp'`, `updated_at='searched_at'`, selecting from `ref('stg_job_postings')` — **plus the as_of time-machine** (Resolution 1):

```sql
select * from {{ ref('stg_job_postings') }}
where searched_at <= cast('{{ var("as_of", run_started_at) }}' as timestamp)
qualify row_number() over (
    partition by job_id
    order by searched_at desc, job_title
) = 1
```

The explicit `CAST(... AS TIMESTAMP)` guards against `run_started_at`'s `+00:00` offset rendering; the `job_title` tiebreaker makes the "current" row deterministic if any job carries two rows with identical `searched_at` (verification item (h) checks whether such pairs exist). Run three times advancing `--vars '{as_of: ...}'` (early month → mid-window → no var = today). Each run presents exactly one current row per job_id, dbt maintains `dbt_valid_from/valid_to`, and the payoff query answers "which postings changed their salary between scrapes?" using LAG over versions. **The QUALIFY here is scripted as a CALLBACK to 3.63's dedupe — "same pattern, new job: instead of picking the latest row ever, pick the current row as of a point in time"** (3.63 lands the pattern first; 3.71 reuses it — never the reverse). — [SCD2, dbt snapshot, Jinja vars → 3.71; verified: snapshot builds true SCD history on Databricks]

---

## 2. GOLD SPEC

### 2.1 Star schema

**`fct_job_postings` — incremental (merge), gold. Grain: ONE ROW PER JOB (job_id), latest scrape wins.**

| Column group | Source | Notes |
|---|---|---|
| `job_id` (PK) | stg passthrough | tested `not_null` + `unique` from 3.63 on ("test the grain where you promise it") |
| Posting attributes: `job_title`, `search_term`, `company_name`, `job_location`, `source_platform`, `job_schedule_type`, `job_work_from_home` | latest scrape row via int ← stg | `company_name` is the natural FK to dim_company; `search_term` kept under its honest name |
| Dates: `posted_date`, `posted_at`, `search_date` (latest scrape) | int ← stg parse (3.32) | `search_date` doubles as the incremental high-water mark (4.12 promised filter) |
| Salary: `salary_min`, `salary_max`, `salary_period`, `salary_currency`, `salary_year_avg` | stg parse + int annualization | USD rule already encoded upstream; marts just filter `salary_year_avg IS NOT NULL` |
| Extension flags: `has_health_insurance`, `has_dental_insurance`, `has_paid_time_off`, `has_no_degree_mentioned` | stg (pinned names, §1.1.7) | byte-identical across the v1→v2→v3 flag evolution |
| YAML: `meta: {owner: luke, tier: gold}` + full column descriptions | — | meta PATTERN is taught at 3.21 on jobs_per_month's YAML (fct doesn't exist yet); fct inherits it at 3.31 — coverage row + edits sweep updated |

**Dedupe placement (LOCKED, with timeline):** `QUALIFY ROW_NUMBER() OVER (PARTITION BY job_id ORDER BY searched_at DESC) = 1` lives in **fct_job_postings**, added on camera at the **close of 3.63** as Act 2's verdict ("the design you MODEL, not delete"): stg keeps the scrape grain for the snapshot; gold serves one row per job. Count: 685,695 → **491,140**. Side effect scripted for awareness (verification item (l) quantifies it): latest-scrape-wins can flip a job's `search_term` if it was re-scraped under a different search — the drift count is script-quotable ammo for "dedupe is a design decision, not a formality."

**Evolution timeline (build-order contract):**
- **v1 (3.31 carve):** table; scrape grain; `WHERE NOT error` carved from the monolith (parked here deliberately — "this filter wants to live upstream; a test will send it there"); 691,950 rows. Written flat; import-CTE header retrofitted at 3.33.
- **v2 (3.63):** error filter removed (subsumed by stg's `job_id IS NOT NULL`); QUALIFY dedupe added; `not_null`+`unique` tests land here; 491,140 rows.
- **v3 (4.1x):** `{{ config(materialized='incremental', incremental_strategy='merge', unique_key='job_id') }}` — **merge strategy pinned explicitly** (self-documenting, immune to adapter default drift) — + the canonical filter `{% if is_incremental() %} WHERE search_date > (SELECT MAX(search_date) FROM {{ this }}) {% endif %}`. Merge on `unique_key` keeps the one-row-per-job promise under incremental: re-scrapes UPDATE, new jobs INSERT, in-batch dupes resolved by the QUALIFY. Compiled SQL read both ways in target/compiled; the conversion run itself is the explicit `--full-refresh` (converting an existing table makes `is_incremental()` true immediately — the full-refresh IS the "first run, no WHERE" path on camera, no surprise). One scripted sentence on `>` vs `>=`: merge idempotency makes `>=` the safer production pattern for late-arriving same-day rows; strict `>` is fine for this demo but don't copy it blind.

**`dim_company` — table, gold (4.31).** Grain: one company (natural key `company_name`). Columns: `company_name`, `total_job_postings`, `first_posted_date`, `last_posted_date`, `avg_salary_year` (USD-parsed only). Built from fct. Completes the 0.3 star diagram. **Kept per Flag 1 — but pasted-not-typed, and the designated FIRST CUT if 4.31 runs long.**

**`dim_skill` — table, gold (3.42).** Grain: one skill_id. `skill_categories` seed (display_name, category, subcategory) LEFT JOIN aggregated observations from `stg_job_skills` (`postings_with_skill`). Construction genuinely requires the seed — the categories exist nowhere else — which is 3.42's entire placement justification. `postings_with_skill` is **YAML-documented as "observed in raw pairs — includes orphans"** (it aggregates stg, so it runs ~13% hot vs anything bridge-based; the doc line doubles as a 3.6 foreshadow). Tests: `unique`+`not_null: skill_id` — arriving before the 3.6 testing arc is fine because P1 established generic tests as routine (the P1 reference repo shipped 12 green tests; scripted one-line callback). **Contracted Plan B** if verification item (b) finds observed skill_ids outside the seed: construction flips to seed FULL OUTER JOIN observed with `COALESCE(category, 'Uncategorized')` — the bridge→dim_skill relationships test stays green either way.

**`job_skills_bridge` — table, gold (born at 3.63's close, alongside the fct dedupe).** Grain: one row per (job_id, skill_id) **for jobs that exist in fct** — `stg_job_skills` INNER JOIN `fct_job_postings` USING (job_id). Columns: `job_id`, `skill_id`, `skill_keyword`, **plus `search_date` carried from fct** (one extra column, no narrative cost — it is the bridge semantic model's required `agg_time_dimension` at 4.31; grain unchanged since fct is one row per job). This is the architectural resolution of the orphan finding: orphans stay upstream (visible, warn-tested), the bridge guarantees referential integrity downstream. Import-CTE header with two refs. Tests: `relationships → fct_job_postings.job_id` and `→ dim_skill.skill_id`, **error severity, passing** — the redemption arc of 3.6, and the model 3.62's singular test is re-pointed at for its permanent green home (Flag 2; 3.62's "exact promised SQL" row claim gets updated at the re-point — edits sweep).

**`time_spine` — table, gold (4.31).** `explode(sequence(DATE'2024-01-01', DATE'2027-12-31', interval 1 day)) AS date_day` + time_spine YAML — **start extended to 2024-01-01** because "N months ago" postings resolved against early scrape dates can push posted_date into 2024 (verification item (m) confirms MIN(posted_date) ≥ spine start; spine-joined queries drop out-of-range dates silently). MetricFlow-required (verified); doubles as the date dim in the star.

### 2.2 Famous Five marts (gold; views over the star; final form at 4.31)

1. **`top_paying_jobs`** — fct WHERE `salary_year_avg IS NOT NULL`, ranked desc, top 100. (Q1) **Typed on camera.**
2. **`top_paying_job_skills`** — `ref('top_paying_jobs')` ⋈ bridge ⋈ dim_skill; skill frequency among top payers. Marts stacking on marts = the DRY/lineage payoff. (Q2) **Typed on camera** (the mart-on-mart beat is the lesson).
3. **`in_demand_skills`** — bridge ⋈ dim_skill; `demand_count = COUNT(DISTINCT job_id)`, `demand_pct = demand_count / total fct jobs`. **Born at 3.33** (not 3.31 — see the 3.3 build-order note below) as the refactored twin of the monolith: v1 = `ref('stg_job_postings') ⋈ ref('stg_job_skills') USING (job_id)` — the exact two-ref join 3.33 promised, faithful to the monolith's raw⋈raw join — with the monolith's `WHERE error = false AND search_term = 'Data Engineer'` and its `COUNT(*)` mention_count preserved verbatim so 3.41 validation matches by construction. Re-pointed to bridge ⋈ fct (and to COUNT(DISTINCT job_id)) at 3.63; capstone upgrade generalizes to all roles. (Q3) **Upgrade pasted at 4.31** (students know this query from the SQL course).
4. **`top_skills_by_salary`** — bridge ⋈ fct, avg `salary_year_avg` per skill. (Q4) **Pasted.**
5. **`optimal_skills`** — `ref('in_demand_skills')` ⋈ `ref('top_skills_by_salary')`, minimum demand threshold, ordered by salary. (Q5) **Pasted.**

**3.3-group internal build order (pinned):** 3.31 carves stg ×2 + int v1 + fct v1, all written FLAT (plain refs, no CTE headers). 3.33 teaches import CTEs by (a) retrofitting headers onto int and fct — a mini-refactor rep — and (b) **birthing in_demand_skills, whose two-stg-ref `USING (job_id)` header IS the teaching moment.** The 3.31 carve-list row and 3.33 row are both in the edits sweep.

**Demo marts — permanently pointed at `int_job_postings_enriched`, NEVER at fct (grain-change immunity by construction):**
- **`jobs_per_month`** — born 3.12 as the load-validation query off `source()`; `COUNT(DISTINCT job_id)` grouped by `DATE_TRUNC('month', search_date)`; carries the course's ONE dialect break at 3.13 and its permanent fix `{{ dbt.date_trunc('month', 'search_date') }}`; re-pointed to **int** at 3.31. COUNT(DISTINCT job_id) ignores NULL ids (so the 3.63 filter changes nothing) and int never dedupes (so 3.63 Act 2 changes nothing): every monthly number shown at 3.12/3.13 stays true forever. It is NOT deduped-per-job monthly counts, and never claims to be — fct owns that grain.
- **`jobs_pivot`** — 3.51 walkthrough artifact off **int**: `{% set roles = [...] %}` CASE-WHEN pivot, `COUNT(DISTINCT CASE WHEN search_term = '{{ role }}' THEN job_id END)`; compiled expansion read at `target/compiled/analytics/models/marts/jobs_pivot.sql`. **Stays time-free** (role columns over all history) — adding a month axis would reintroduce dedupe instability; contracted against.
- 3.51 row's ref edit goes to `int_job_postings_enriched` (NOT fct) — edits sweep.

### 2.3 Metrics YAML plan (4.31 — a taste, 2 metrics + 3 semantic models, locked scope)

- **`semantic_models/job_postings.yml`** on `fct_job_postings`: primary entity `job` (job_id); dimensions `search_term`, `company_name`; time dimensions `search_date` (**agg_time_dimension — never NULL**) and `posted_date` (secondary; ~14,878 NULLs YAML-documented — NULL agg-time rows silently drop from time-grouped queries, which is why search_date gets the default); measure `job_count`.
- **`semantic_models/job_skills.yml`** on `job_skills_bridge`: foreign entities `job`, `skill`; **`agg_time_dimension: search_date`** (the column carried into the bridge for exactly this — MetricFlow rejects any semantic model with measures and no agg time); measure `skill_mentions`.
- **`semantic_models/dim_skill.yml`** on `dim_skill`: primary entity `skill`; dimensions `category`, `subcategory`, `display_name`; no measures. **Required** — without it, no query can group by `skill__category`. Metric count stays 2; semantic-model count is 3.
- **Metrics:** `total_job_postings` (simple, over job_count) and `skill_demand_pct` (ratio: skill_mentions / total_job_postings).
- **Demo query — verify-then-script (verification item (i), BLOCKING for the 4.31 script):** MetricFlow applies group-bys to BOTH ratio inputs, and the denominator lives on fct where `job` is primary — reaching `skill__category` from the denominator may be disallowed (fan-out), and any bridge-side denominator silently changes semantics to "jobs within that category." Therefore: (1) run the exact grouped query `mf query --metrics skill_demand_pct --group-by skill__category` on the final project; (2) if it runs, reconcile its value against in_demand_skills for the same category before scripting the "metric inherits governed definitions" line; (3) **contracted fallback demo** if it errors or doesn't reconcile: `mf query --metrics total_job_postings --group-by job__search_term` (simple metric, own-entity dimension — guaranteed) plus ungrouped `mf query --metrics skill_demand_pct`, reconciled on camera against in_demand_skills' total. The prior "~1.4s verified" proves the toolchain runs, not that the grouped ratio computes mentions/ALL-jobs — no on-camera claim gets scripted past what (i) proves.
- The governed-definitions point survives either demo shape: dedupe and USD/ID filters are encoded once upstream and the metric inherits them instead of restating WHERE clauses.
- `time_spine` YAML as verified. Install: `uv add "dbt-metricflow[databricks]"`.

### 2.4 Analyses & legacy — the demotion beat, fully mechanized

**Critical constraint honored:** analyses are parsed by dbt, and a `ref()` to a non-node is a fatal parse error on EVERY subsequent command. So no file may carry `ref('one_big_query')` at any moment after the monolith leaves `models/`. The 3.41 demotion is therefore a TWO-file move, scripted as one beat:

- **`analyses/validate_refactor.sql`** (3.41): `SELECT 'old', COUNT(*), SUM(mention_count) FROM {{ ref('one_big_query') }} UNION ALL SELECT 'new', ... FROM {{ ref('in_demand_skills') }}` — two-column validation (rows AND total mentions). Compiled via `dbt compile --select validate_refactor`, pasted into the **Databricks SQL editor**. **Passes at 3.41 by construction**: v1 in_demand_skills is a verbatim carve (same joins via stg refs, same `WHERE error = false AND search_term = 'Data Engineer'`, same `COUNT(*)` mention_count). **The green guarantee is scoped to 3.41 ONLY** — it is point-in-time QA for the carve, and nobody reruns it after 3.63 (where the dedupe would legitimately diverge SUM(mention_count); that divergence is the dedupe working, not the refactor breaking — one scripted sentence says so).
- **The demotion (same 3.41 beat, on camera):** `one_big_query.sql` moves `models/` → `analyses/legacy/` ("compiles, never ships as a table again"), AND `validate_refactor.sql` is edited and moved to `analyses/legacy/` alongside it: the old-side `{{ ref('one_big_query') }}` is replaced with the hardcoded FQN of the still-materialized leftover relation (dbt never drops removed models) plus a dated comment — scripted line: "a hardcoded reference for the hardcoded-era query — this file is a record of the refactor, not part of the pipeline." Result: zero dangling refs, every later dbt command parses clean, and the repo keeps both artifacts for portfolio storytelling. At 4.31, one comment line is appended: "validated the 3.41 carve; superseded by the capstone generalization."
- **(Optional) `analyses/salary_changers.sql`** (3.71): the LAG-over-snapshot-versions query preserved as a rerunnable QA artifact.

---

## 3. COVERAGE MATRIX

Every extracted topic → its build artifact(s) → the promised beats this design fulfills. **Topics with no home: NONE. Artifacts teaching nothing: NONE** (dim_company is the only marginal one — kept per Flag 1, with a job and a cut rule).

| Topic | Build artifact(s) | Beats fulfilled / design notes |
|---|---|---|
| 3.11 Kickoff | Repo `dbt_project_2`, project `analytics`, `profile: 'databricks'` (single target, named `dev`), `models/one_big_query.sql` WRITTEN | **Sequencing pinned (was contradictory):** 3.11 = scaffold + `dbt debug` green + the scrappy monolith written and RUN ONCE → table-not-found → honest cliffhanger: "dbt transforms data that's already there — and we haven't loaded any. EL first." The real-answer payoff moves to 3.12's close. Profile-collision beat, latency folklore-bust, "profile names the CONNECTION" line all setup-side, intact. Row edit in sweep. |
| 3.12 Cloud load | **Load mechanics pinned:** UC Volume `/Volumes/workspace/bronze/raw_files/` → student uploads the 1.24 monthly parquet from local `data/raw` via Catalog Explorer's Upload-to-Volume UI (no re-download, no CLI on camera; CLI path documented for the supporter job appendix) → ingestion notebook (params: `month_cutoff` for the 4.1x sim, `append_month` for the append path) CTAS → `bronze.raw_job_postings`/`raw_job_skills`; `sources.yml` (name `bronze`); `jobs_per_month.sql` as load-validation query; **monolith runs → the real answer (top DE skills + transparency %, the P1 21.3% callback) closes the lesson** | The student-performed EL step = upload + run notebook, on camera. **BQ side-load (`bq mk bronze` + `bq load`) compressed to a "run this doc off-camera before next lesson" beat** (3.13 prep only). Dataset named `bronze` on both warehouses so ONE portable sources.yml serves both. 4.1x and the supporter multi-task job reuse this exact notebook + volume path. |
| 3.13 Portability swap | BigQuery target in profiles.yml; `dbt run` on BQ; fix in `jobs_per_month`; **green mechanism: `dbt run --select jobs_per_month`** | Exactly ONE dialect break: `DATE_TRUNC('month', search_date)` → `{{ dbt.date_trunc('month','search_date') }}`. **TWO models fail on the first BQ run, different classes, both featured:** jobs_per_month (dialect — fixable now, with a macro) and the monolith (table-not-found — its FQN is welded to the Databricks catalog; NOT fixable until 3.3, and that's the scripted point: "hardcoding doesn't just offend style, it breaks portability"). The lesson ends green via `--select jobs_per_month`; the row's "exactly ONE model fails" line is stale — edits sweep. Scripted as "a second CONNECTION under the same profile" (cashing 3.11's plant), so 4.21's dev/prod reveal keeps its job — 4.21 opens with the callback "you've already run two targets; now targets get a job." Sandbox-safe: only views exist at 3.13. |
| 3.21 Layers | `models/staging|intermediate|marts` tree (+`.gitkeep` in empty scaffold folders); `+schema: silver/gold`; `generate_schema_name` boilerplate (§0 logic, pinned); `meta: {owner: luke, tier: gold}` taught on **jobs_per_month's YAML** (fct doesn't exist yet) | **Medallion mapping: the on-screen line is EDITED to the P2 concrete truth — raw = bronze, staging + intermediate = silver, marts = gold (datanerd's own mapping)** — because that is what the student's Catalog Explorer will literally show; the old "bronze = staging" line contradicts the schemas the project builds (edits sweep, 3.21). Students see `dev_silver`/`dev_gold` (target name `dev`) — scripted: "ignore the prefix, mystery for 4.2." Layers diagram drawn to feed 0.32 (contracted obligation). 21%→95% stat and "same cake, different frosting" untouched. |
| 3.22 Staging discipline | `stg_job_postings` v1, `stg_job_skills` | Exact promised SQL (searched_at cast, TRIM) present verbatim; stg_job_skills is the deliberately boring one (plus its TRIM echo for 3.52); every 3.32 cleanup qualifies as rename/cast/clean. |
| 3.31 The refactor | Carve: monolith → stg ×2 → int v1 (thin passthrough) → fct v1 — **all written flat; in_demand_skills is NOT born here** (3.33's job) | ~80-line before-query designed (Resolution 2, aggregates pinned); hardcoded refs → `source()`/`ref()` (second-rep application; declaration happened 3.12 — row edit noted); shape-diagram filename aligned to `one_big_query.sql` (was `one_giant_query` — sweep); fct meta block inherited from 3.21's jobs_per_month pattern; QA deferred to 3.41 and guaranteed to pass. |
| 3.32 Staging cleanups | stg_job_postings transformations 4–7; int gains `salary_year_avg` at the close | **Pacing locked: type the FIRST salary expression and the FIRST flag; paste the rest — "the pattern is the lesson, the enumeration is the repo."** posted_at shown compact (Resolution 4). Salary regex (en-dash class covers the scripted `'100K–186K a year'`); `'10 hours ago'` vs searched_at; JSON flags (one real JSON function — `array_contains(from_json(...))` — kept so the promised code shape appears verbatim); 'via '-prefix text fix (labeled honestly per verification item (g)); **`try_cast(nullif(...))` guard taught as the Databricks-ANSI beat**; min/max duplication deliberately left in for 3.52. |
| 3.33 Import CTEs | Headers retrofitted onto int + fct (mini-refactor rep); **in_demand_skills v1 born here — its `ref('stg_job_postings') ⋈ ref('stg_job_skills') USING (job_id)` header IS the promised two-ref join, on a real model** | The committed 3.33 join shape now has a literal home (the prior design never joined those two models anywhere). job_id confirmed as the shared key. Bridge repeats the pattern at 3.63. |
| 3.41 Analyses | `analyses/validate_refactor.sql` (green at 3.41, scope pinned); **two-file demotion beat** (monolith → `analyses/legacy/`; validate_refactor edited — old-side ref → leftover-relation FQN + dated comment — and moved alongside) | **No dangling `ref('one_big_query')` ever exists → every subsequent dbt command parses clean** (analyses are parsed; this was the project-killing bug). "Stays green after 3.63" claim DELETED — validation is point-in-time QA, retired at the demotion; post-3.63 divergence acknowledged in one scripted sentence as the dedupe working. Console beat re-homed to Databricks SQL editor. Advanced-arc framing (3.4→3.5→3.6→3.7) preserved. |
| 3.42 Seeds | `seeds/skill_categories.csv` → `dim_skill` | dim_skill genuinely requires the seed; nothing depends on the seed before 3.42; seed lands in silver per locked decision; generic tests on dim_skill ride P1's established precedent (one-line callback); Plan B construction contracted (§2.1). |
| 3.51 Jinja loops | `jobs_pivot.sql` (off **int**) + stg extension-flags loop upgrade (pinned names, §1.1.7) | Locked walkthrough kept (roles pivot, compiled-file wow, "you wrote the loop, dbt wrote the SQL"); the boolean-per-keyword loop ships with byte-identical column names (the `has_` prefix in the template guarantees it — fct never breaks); refs updated `job_postings`→`int_job_postings_enriched` (sweep — NOT fct); compiled path `target/compiled/analytics/...`. |
| 3.52 Macros | `macros/slugify.sql` (student-written), `macros/parse_salary.sql` (Luke-led flagship), reveal | Reveal ammo: ref/source as macros PLUS "your project has shipped a custom macro since 3.2" (generate_schema_name). Earned pain: duplicated min/max salary regex (3.32) + duplicated filter chains in stg flags loop and jobs_pivot = slugify's two call sites; the TRIM echo across stg models keeps the "repeated across staging models" line literally true (no row edit needed). is_incremental() hedged in script. Packages stay bonus. |
| 3.61 accepted_values & relationships | stg YAML tests — **both run against PRE-filter staging (843,097 rows incl. 151,147 error rows)** | accepted_values passes on ALL raw rows (verification item (e), BLOCKING — error rows' search_term values included); relationships surfaces the REAL orphan gap with the PRE-filter failure count (item (c)/(n) makes it script-quotable); orphans preserved by contract; warn-severity resolution framed as "keep the finding visible WITHOUT blocking builds." |
| 3.62 Singular tests | `tests/assert_no_orphan_skills.sql` | Exact promised SQL, exact model names, against pre-filter staging while orphans visibly exist; build deliberately RED for a full lesson — **scripted closer owns the reversal on purpose** (§1.2); datanerd production-parity claim checked against Flag 2 before scripting. Row's "exact SQL" claim updated when the test re-points to the bridge at 3.63 (sweep). |
| 3.63 Test-driven cleaning | stg filter (Act 1), fct QUALIFY + bridge (with search_date) + test migration (Act 2); in_demand_skills re-pointed | All verified numbers preserved (157,402 / 151,147+6,255 / incident histogram / 63,207 / 491,140 / 365-day scrape); stg unfiltered until this lesson; Act 2 verdict: model it — stg keeps grain, fct dedupes, bridge guarantees integrity, unique test moves to where the grain is promised; search_term drift quantified (item (l)); demo marts untouched by construction (they ride int). Month-histogram SQL re-verify on Databricks queued (d). |
| 3.71 Snapshots | `snapshots/job_postings_snapshot.sql` + as_of runs + salary-changers query | Promised config shape kept (timestamp/searched_at/job_id); CAST guard + deterministic tiebreaker (§1.5); stg NOT deduped upstream (locked); **QUALIFY scripted as CALLBACK to 3.63, never foreshadow**; salary-changer existence is verification item (a), BLOCKING — with a contracted fallback (if salary changers are scarce, the payoff query broadens to any-field-changed with salary preferred; if zero field changes exist at all, 3.71 and 1.23's tease get redesigned BEFORE scripting). Closes the folder-by-folder tour. |
| 4.11–4.14 Incremental — **CONSOLIDATED into ONE ~8-min lesson** (budget-locked) | fct v3 (§2.1) | **Pre-staged off-camera:** notebook run with `month_cutoff` = final-month-minus-one; fct built. **On camera:** (1) bytes-scanned pain via query history (wall-clock pain is mild — honesty kept); (2) config: incremental + merge (pinned) + unique_key; (3) canonical `WHERE search_date > (SELECT MAX(search_date) FROM {{ this }})` — with the `>` vs `>=` sentence; (4) conversion run = explicit `--full-refresh` (the no-WHERE compiled path, mechanism pinned); (5) notebook `append_month` cell lands the FINAL month; (6) incremental run — rows affected = one month; compiled SQL read both ways; (7) 60-second when-to-go-incremental verdict as the outro (datanerd "partitioned full rebuild" phrasing verbatim). **Dataset extent pinned:** the appended month IS the dataset's final month, so post-sim bronze is byte-identical to the full load — no restore step, no drift; verification item (f) confirms post-sim counts = 843,097 / 3,304,574 and all downstream verified numbers hold. Full bronze-rebuild mechanics demoted to the supporter appendix (pairs with the monthly job). |
| 4.21 dev vs prod | profiles.yml outputs dev/prod + generate_schema_name payoff (§0 macro logic) | dev target (name `dev`) → `dev_silver`/`dev_gold`; prod → bare `silver`/`gold`; **any non-`dev` target name resolves bare — which is exactly why 4.23's generated-profile job works with zero flags** (the plant for 4.23's payoff). Opens with the 3.13 callback ("you've already run two targets — now targets get a job"). Consistent with 1.22's "prod is inert" plant. |
| 4.22 dbt build halting | Severity flip mechanic | Induce: stg relationships test `warn`→`error` (one YAML line, real data condition) → bridge and everything downstream SKIP → revert → full green. Reversible on camera. **Stale line edited (sweep):** "`build --target prod` = the command a scheduler runs" is false on Databricks Jobs (the job never passes --target); replacement hand-off line: "in 4.23 you'll see a scheduler run this exact build — under a target it names itself." |
| 4.23 Databricks Jobs | Scheduled job: `dbt debug` + `dbt build`, no deps | Generated profile, target name `databricks_cluster` → generate_schema_name resolves bare `silver`/`gold` (§0 — scripted beat: job log target name → Catalog Explorer bare schemas; cashes 4.21). All four materializations preserved; zero-secrets, public repo, warehouse-dropdown gotcha honored; cron daily for core; supporter monthly (5th) multi-task job (Task 1 = the 3.12 ingestion notebook via CLI-uploaded parquet → Task 2 dbt build) documented as the appendix, alongside the full-rebuild mechanics demoted from 4.1x. Job timing number re-earned per verification item (k) before scripting. |
| 4.31 Capstone — **compression pinned** | Five marts, dim_company, time_spine, 3 semantic models + 2 metrics, persist_docs, end-to-end build | **Typed on camera: Q1 + Q2 only** (the mart-on-mart beat). **Pasted/montaged: Q3 generalization, Q4, Q5** (students know these queries from the SQL course), **dim_company** (first cut if minutes run out — Flag 1), **time_spine**. **Semantic YAML shown pre-written and read through**, demo query per §2.3's verify-then-script rule (item (i)). persist_docs = Catalog Explorer flyover, re-verified on the final warehouse/adapter (item (j)). All Famous Five answerable (salary parsed 3.32, skills via bridge); P1-answered-none framing holds; full lineage payoff; "both warehouses" line retired per Flag 6; 0.3 star diagram agreement (incl. time_spine + bridge) is a contracted obligation. |
| 4.32 Portfolio push | Final push + README per 2.21 pattern | Update-push (repo created 3.11, public since 4.23); `git remote add origin` snippet belongs to 3.11's kickoff script. |

---

## 4. RESOLUTIONS — the five open problems

**1. Snapshot demo on frozen data → the `as_of` time machine.**
The snapshot block filters its source by `searched_at <= CAST(var('as_of', run_started_at) AS TIMESTAMP)` and QUALIFYs to the latest row per job_id at that cutoff (deterministic tiebreaker included — §1.5). Luke runs `dbt snapshot` three times, advancing `as_of` between runs; dbt walks the timestamp strategy through genuinely different states built from REAL re-scrape rows, so the captured salary changes are real, not synthesized. Honest framing on camera: "the data is fully loaded, so we'll replay time — in production this var doesn't exist and every nightly run IS a new as_of." Bonus coverage: Jinja `var()` with a default gets its teaching rep here, and **the QUALIFY is a scripted CALLBACK to 3.63's dedupe** ("same pattern, new job: pick the current row as of a point in time") — 3.63 owns the first sighting. Rationale over alternatives: a single-run snapshot shows nothing; mutating bronze between runs would corrupt the verified 3.63 numbers. The timestamp strategy will also version unchanged re-scrapes (searched_at always advances) — scripted as the check-strategy tease for bonus B.1. The payoff's existence rests on verification item (a) with its contracted fallback.

**2. The tangled monolith: `one_big_query.sql` (~80 lines) — aggregates PINNED (they are load-bearing for 3.41).**
Question: "which skills do Data Engineer postings ask for most — and how many even post a salary?" Real answer at 3.12's close (per the pinned 3.11/3.12 sequencing), a crude preview of Famous Five Q3 that the capstone answers properly (bookend). Contents: nested subqueries (no CTEs); hardcoded `workspace.bronze.raw_job_postings` and `raw_job_skills` FQNs (3×); `WHERE error = false AND search_term = 'Data Engineer'` repeated verbatim in two branches; magic string `'Data Engineer'` twice; **`mention_count = COUNT(*)` over the postings⋈skills join (scrape grain, no dedupe)** — and in_demand_skills v1 preserves exactly this COUNT(*), so validate_refactor's row-count AND SUM(mention_count) columns match at 3.41 by construction; **the scrape-grain inflation ("Act 2 ammo") lives in the transparency-% / total-postings branch** — `COUNT(*)` postings and `job_salary IS NOT NULL` share the inflated denominator (with the `-- TODO: salary is text soup` comment setting up 3.32), and THAT is the number 3.63's dedupe corrects on camera. No TRIM, no via-fix. Deliberately absent: DATE_TRUNC and regex (preserves 3.13's exactly-one-dialect-break; the monolith's BQ failure is table-not-found — featured, not hidden). Afterlife: the two-file demotion beat (§2.4) — no dangling refs, ever.

**3. dbt packages: OUT of core.**
Two locked pins already decide this (3.13: dispatch fix must use built-in `dbt.date_trunc`; 3.52: "packages stay bonus tier"). The contract uses natural keys (no `generate_surrogate_key`), plain `unique` tests, and built-in dispatch macros; the Databricks job needs no `dbt deps`. dbt_utils gets a bonus-tier lesson (B.x): `packages.yml` + `dbt deps` + `unique_combination_of_columns(job_id, search_date)` on stg — which retroactively gives the stg grain a proper test ("remember the unique test we removed? here's the package that tests the grain we actually have").

**4. posted_date parsing: plain SQL in staging — with mandatory cast guards.**
One call site = macro not earned; keeping it plain PRESERVES the contrast that makes 3.52 land ("parse_salary got a macro because we wrote it twice; posted_at stayed SQL because we wrote it once — macros are earned by repetition, not by cleverness"). Implementation is compact: extract the number (**`try_cast(nullif(regexp_extract(...), '') as int)` — non-negotiable on ANSI-mode Databricks**, §1.1), extract the unit, strip trailing `s`, one CASE over four units, NULL passthrough for both genuine NULLs and unprofiled shapes. Flagship macro remains `parse_salary`; `slugify` remains the student-written artifact with two genuine call sites. Optional homework: macro-ize posted_at parsing — explicitly not core.

**5. Currency: parse in staging, decide in intermediate, filter never repeated.**
Staging extracts `salary_currency` (leading currency code, NULL = assumed USD) — cleaning, staging-legal. `int_job_postings_enriched` encodes the datanerd production rule ONCE (at 3.32's close, when the inputs exist): `salary_year_avg` computed only for USD year/hour rows (hourly × 2080), NULL otherwise, YAML-documented. Marts and metrics only ever filter `salary_year_avg IS NOT NULL` — no mart restates currency logic, which is itself the governed-definitions teach ("the USD decision lives in one file; five marts and a metric inherit it"). On-camera moment in 3.32 when `'PKR 62,733.60–PKR 308,888.34 a month'` appears in the real profile.

---

## 5. OPEN FLAGS FOR LUKE (genuine judgment calls only)

1. **dim_company: keep or cut.** Endorsed as contracted: **keep** — it completes the star for the lineage payoff and costs ~15 lines — but it is paste-not-type, and it is the **designated first cut** if 4.31 runs long (the 0.3 star diagram must match whichever way this lands).
2. **Orphan tests' final resting state.** Contract: stg relationships stays `severity: warn`; singular test re-pointed to bridge↔fct at 3.63 (strict, passing). Check this matches how the datanerd nightly assertion actually runs before scripting the production-parity line. **Recommendation: as contracted** — warn-on-stg also hands 4.22 its halting mechanic for free.
3. **Where the fct QUALIFY lands on camera: end of 3.63 vs opening of 3.71.** Contract says 3.63 close (the two-verdicts closer needs its resolution; 3.71 then opens with "gold keeps only the latest — the history is GONE from gold; here's the tool that keeps it," and its QUALIFY is the callback). **Recommendation: 3.63 close.**
4. **`bq mk bronze` rename** (was `raw`) so one sources.yml is portable across both warehouses with zero Jinja. **Recommendation: yes.**
5. **in_demand_skills v1 keeps the monolith's hardcoded `'Data Engineer'` and COUNT(*)** until 3.63/4.31 evolve it (faithful-carve guarantee for 3.41). **Recommendation: keep, and call it out as intentional.**
6. **4.31 "green in both warehouses" line retires** → "green in dev, prod, and on a schedule." The BQ sandbox can't run MERGE/snapshot. **Recommendation: accept; the portability proof already happened in 3.13.**
7. **MetricFlow demo shape** (new): if verification item (i) shows the grouped ratio errors or doesn't reconcile with in_demand_skills, the demo becomes the contracted fallback pair (§2.3) and the script's framing shifts from "grouped ratio" to "governed totals + ungrouped ratio." **Recommendation: pre-commit to whichever (i) proves — do not script ahead of it.**

### Verification queue (run BEFORE scripting; items marked BLOCKING gate contract acceptance for their lessons)

| # | Item | Status |
|---|---|---|
| (a) | Count of job_ids with real salary-text changes across re-scrapes — 3.71's payoff and 1.23's tease depend on it. Fallback contracted (§3, 3.71 row): scarce → any-field-changed payoff; zero → redesign 3.71/1.23 jointly before scripting. | **BLOCKING (3.71)** |
| (b) | All observed skill_ids ⊆ the 1,422-row seed. Plan B contracted either way (dim_skill FULL OUTER + 'Uncategorized'), so the bridge→dim_skill test ends green regardless. | verify |
| (c) | **PRE-filter** orphan count/% on stg_job_skills→stg_job_postings (the number Luke quotes at 3.61) AND confirmation the orphan set is identical pre- and post-filter; post-filter ~13% claim re-checked. | **BLOCKING (3.61)** |
| (d) | 3.63 month-histogram SQL on Databricks (66/2,191/955/2,938/105). | verify |
| (e) | accepted_values on search_term against **ALL 843,097 unfiltered rows including the 151,147 error rows** — the test runs at 3.61, pre-filter; error rows' search_term values must be within the three, or 3.61's "pin it" beat needs a redesign. | **BLOCKING (3.61)** |
| (f) | Dataset month extent: confirm the 4.1x sim's appended month is the FINAL month of the dataset, and post-sim bronze counts = 843,097 / 3,304,574 exactly (no restore step exists or is needed). Month-13 file row count for the on-camera rows-affected line. | **BLOCKING (4.1x)** |
| (g) | Whether a genuine mojibake/encoding case exists. If yes → it becomes a hard 3.32 requirement; if no → 3.32 row's "encodings" phrasing edited in the sweep (the 'via' strip is text-consistency, not encoding). | verify → sweep |
| (h) | Snapshot table size after three as_of runs; existence of same-job identical-searched_at row pairs (justifies/exercises the tiebreaker). | verify |
| (i) | MetricFlow grouped-ratio query on the FINAL project: does `mf query --metrics skill_demand_pct --group-by skill__category` run, and does its value reconcile with in_demand_skills for the same category? Locks demo shape per §2.3/Flag 7. | **BLOCKING (4.31 script)** |
| (j) | persist_docs column comments on VIEWS in Catalog Explorer on the pinned dbt-databricks version (4.31's explicit re-verify-on-final-warehouse constraint). If views don't persist, scope `columns: true` to tables and script accordingly. | **BLOCKING (4.31 claim)** |
| (k) | Re-time `dbt debug` / `dbt build` / the scheduled job on the FINAL model set (~2× the gate project) — no latency-map or run-anatomy number is scripted from the 9-model timings. | **BLOCKING (any timing line)** |
| (l) | search_term drift at 3.63: how many jobs change role membership under latest-scrape-wins (perturbs in_demand_skills and Famous Five counts; script-quotable). | verify |
| (m) | MIN(posted_date) ≥ 2024-01-01 (extended spine start); extend further if not. | verify |
| (n) | Script-quotable failure numbers: PRE-filter relationships failure count (3.61) and the duplicate profile behind 63,207 (3.63). | verify |

### Stale row-text edits this contract implies (sweep the inventory)

- **3.11** — "produces a real answer" beat moves to 3.12's close; 3.11 ends on the table-not-found cliffhanger ("EL first").
- **3.12** — BQ→Databricks-first restructure; dataset `bronze`; UC-volume upload + notebook params; BQ side-load demoted to off-camera doc.
- **3.13** — "exactly ONE model fails" → "exactly one DIALECT break; the monolith also fails — table-not-found, hardcoding's other bill"; lesson ends green via `dbt run --select jobs_per_month`.
- **3.21** — medallion line edited to the built truth: raw = bronze, staging + intermediate = silver, marts = gold; `meta:` demo re-homed to jobs_per_month's YAML; dev_-prefix "mystery" line added.
- **3.31** — "sources re-declared here" → "sources applied here; declared in 3.12"; shape-diagram filename `one_giant_query.sql` → `one_big_query.sql`; carve list drops in_demand_skills (born 3.33); models written flat (headers arrive 3.33).
- **3.33** — in_demand_skills born here; its stg⋈stg USING(job_id) header is the teaching artifact.
- **3.41** — placeholder refs → `one_big_query` / `in_demand_skills`; console beat → Databricks SQL editor; "stays green after 3.63" claim removed (green scoped to 3.41); demotion is a two-file beat (validate_refactor edited + moved).
- **3.51** — ref → `int_job_postings_enriched` (NOT fct); compiled path → `analytics`.
- **3.62** — "exact promised SQL" claim updated when the singular test re-points at the bridge at 3.63; red-on-purpose closer added.
- **4.12** — code block's source ref → the fct ref chain (or source name `bronze`); `>` vs `>=` sentence added; consolidated-lesson framing (4.11–4.14 = one ~8-min lesson).
- **4.22** — "`build --target prod` = the command a scheduler runs every day" → "a scheduler runs this exact build under a target it names itself — see 4.23."
- **3.32** — conditional on (g): "encodings fixed" phrasing → "text-consistency fixed" if no genuine encoding case exists.
- ~~3.52 "across staging models"~~ — **no longer needs an edit**: the TRIM echo in stg_job_skills makes the line true as written.
---

## APPENDIX — VERIFICATION QUEUE RESULTS (run live on workspace bronze, 2026-08-13)

| Item | Result | Status |
|---|---|---|
| (a) salary changers | **2,756 jobs** change salary TEXT across scrapes (6,421 incl. null↔value; 7,484 any-field). HERO: Fraser Health Senior DE `1318ef9f0edbfd2dda647fcff660e013` posted **CA$1.06M–1.22M** on 2025-09-01, corrected to **CA$104K–145K** on 2025-09-11. Runner-up: Ace1Media intern CA$16K–17.6K → CA$104K–130.9K. | ✅ snapshot payoff SOLID |
| (b) skill_ids ⊆ seed | observed 960, seed 1,422, **0 outside seed** — Plan B (FULL OUTER JOIN) not needed | ✅ |
| (c) orphans | **ZERO orphan skill-pairs, pre- AND post-filter.** The ~13% claim was datanerd-production lore; the course export's JOIN guaranteed integrity. **CONTRACT PREMISE FALSE** — see redesign note below | ❌ REDESIGN |
| (d) incident histogram | Databricks reproduces exactly: 66 / 2,191 / 955 / 2,938 / 105 (2025-12→2026-04) | ✅ |
| (e) accepted_values search_term | ALL 843,097 rows = exactly Data Engineer 460,643 · Data Analyst 226,791 · Data Scientist 155,663; zero NULL/other even in error rows | ✅ passes green as contracted |
| (f) sim month extent | 2025-07-01 → 2026-06-30; final month 2026-06 = **58,933 rows** (the append-month rows-affected number) | ✅ |
| (g) mojibake | **113 real rows** with `â€"`-class double-encoding (e.g. "DATA ANALYST â€“ ERP & REPORTING") — genuine 3.42 cleanup material, small enough to be safe | ✅ |
| (h) identical-timestamp dupes | exactly **1 job_id** with two identical search_time rows — deterministic tiebreaker still required, barely | ✅ |
| (i) MetricFlow grouped ratio | deferred to built DAG (by definition) | ⏳ build |
| (j) persist_docs on views | **VIEW column comments DO persist** to information_schema.columns (dbt-databricks 1.10.9, verified live) | ✅ |
| (k) full-DAG re-timing | deferred to build completion (by definition) | ⏳ build |
| (l) search_term drift | **11,923 jobs** scraped under >1 search_term — latest-scrape-wins consequence is real and quotable | ✅ |
| (m) posted_date floor | max "N months ago" = 1; min search_date 2025-07-01 → min posted_date ≈ 2025-06. No deep-past parsing risk | ✅ |
| (n) quotables | dup profile behind 63,207: 2×=38,778 jobs · 3×=10,099 · 4–10×=10,961 · 11–50×=3,016 · **51+×=353** (max 365). Pre-filter relationships failure count = 0 (dead, see (c)) | ✅ |

### REDESIGN NOTE — the orphan arc (DECIDED: Plan A, PROVISIONAL — Luke, 2026-08-13: "go with A but I really won't know until I start testing and building this out" — revisit at lesson walkthrough)
Item (c) kills the contracted red-test arc (3.71 relationships red → 3.72 assert_no_orphan_skills red
→ bridge redemption → 4.22 warn→error halting). Verified replacement candidates, both REAL:
- **accepted_values on job_schedule_type**: 17 distinct values incl. combos — the "obvious" 4-value
  list fails on ~28.8k rows ('Full-time and Part-time' 25,242 … plus 'Part-time and Full-time' 7 —
  same meaning, different order). Natural 3.71 red.
- **assert_salaries_sane singular test**: red on real garbage (Fraser Health CA$1.06M–1.22M),
  and the SAME rows are the snapshot lesson's hero (corrected 10 days later). Natural 3.72 red,
  double-duty with 3.81.
Relationships still taught at 3.71 — passing green, with production-parity narration. Bridge keeps
its structural role (fct grain + search_date for MetricFlow); "redemption arc" framing retires.
dim_skill's "runs ~13% hot" doc line retires. 4.22 halting mechanic flips whichever red test lands.
