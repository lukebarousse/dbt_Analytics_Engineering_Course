# Automated dbt Pipeline for Job Postings

[![dbt build & publish](https://github.com/lukebarousse/dbt-project1/actions/workflows/dbt_build.yml/badge.svg)](https://github.com/lukebarousse/dbt-project1/actions/workflows/dbt_build.yml)
[![dbt Docs](https://img.shields.io/badge/dbt_docs-live-blue)](https://lukebarousse.github.io/dbt_Analytics_Engineering_Course/project1/)

![dbt pipeline diagram](img/dbt_pipeline.png)

A public dbt + DuckDB pipeline over ~692k real job postings. Every push rebuilds the models, runs tests, and publishes artifacts anyone can open — no private warehouse, no credentials.

| What this demonstrates | Where to look |
| --- | --- |
| **dbt pipeline** — sources → cleaned model → insight marts | [`analytics/models/`](analytics/models/) |
| **Hosted dbt docs** — lineage, descriptions, column tests | [Live docs site](https://lukebarousse.github.io/dbt_Analytics_Engineering_Course/project1/) |
| **Public CI** — build + test + publish on every push | [Actions workflow](https://github.com/lukebarousse/dbt-project1/actions/workflows/dbt_build.yml) |

---

## What's in here

The project takes ~692k raw job postings through the full dbt workflow:

1. **A tested pipeline** — `source()` / `ref()`, materializations, and grain tests
2. **Published documentation** — the DAG and every column meaning, browsable without cloning
3. **CI automation** — every push rebuilds, tests, and republishes the warehouse

---

## 1. The dbt pipeline

![dbt dag diagram](img/dag_pipeline.png)

**dbt practices used**

| Practice | Implementation |
| --- | --- |
| Declared sources (no hardcoded paths in SQL) | [`sources.yml`](analytics/models/sources.yml) + `source('raw', 'job_postings')` |
| Model dependencies | `ref()` everywhere downstream; dbt resolves order and parallelism |
| Materializations | project default `table`; staging override to `view` |
| Data tests | `unique` / `not_null` on mart grains in [`schema.yml`](analytics/models/schema.yml) |
| Environments | local `dev` vs CI `prod` targets ([`ci/profiles.yml`](ci/profiles.yml)) |

`dbt build` compiles SQL, materializes models, and fails the run if any test fails — same command locally and in CI.

---

## 2. Hosted dbt docs

Docs are generated with `dbt docs generate` and published to GitHub Pages:

**→ [lukebarousse.github.io/dbt_Analytics_Engineering_Course/project1/](https://lukebarousse.github.io/dbt_Analytics_Engineering_Course/project1/)**

The site shows:

- The full **lineage graph** (sources → models → marts)
- **Model and column descriptions** from the YAML
- Which columns carry **tests**

---

## 3. CI: build, test, publish

Workflow: [`.github/workflows/dbt_build.yml`](.github/workflows/dbt_build.yml)

| Trigger | What happens |
| --- | --- |
| Push to `main` | Full rebuild |
| Weekly (Monday) | Scheduled rebuild — pipeline stays fresh |
| Manual (`workflow_dispatch`) | Run button in the Actions UI |

On each run, Actions:

1. Installs deps with `uv`
2. Downloads raw parquet
3. Runs `dbt build --target prod`
4. Publishes `prod.duckdb` as a GitHub Release asset

The badge at the top of this README links to the latest runs.

### Query the published warehouse

No clone required. From a local DuckDB session:

```sql
ATTACH 'https://github.com/lukebarousse/dbt_Analytics_Engineering_Course/releases/download/warehouse/prod.duckdb'
  AS jobs (READ_ONLY);

SELECT * FROM jobs.main.top_companies;
SELECT * FROM jobs.main.monthly_summary;
```

---

## Headline findings (from the marts)

- Meta leads employer volume by a wide margin among active posters
- Remote remains a small share of data-role postings in this sample
- Salary is sparse and often free-text when present — documented as-is rather than patched

(Open the marts or the [docs site](https://lukebarousse.github.io/dbt_Analytics_Engineering_Course/project1/) for the exact numbers after the latest CI build.)

---

## Run it yourself

```bash
uv sync
uv run python scripts/download_data.py
cd analytics && uv run dbt build
```

Optional docs locally:

```bash
uv run dbt docs generate
uv run dbt docs serve
```

---

## Project layout

```text
.
├── .github/workflows/dbt_build.yml   # public CI: build, test, publish
├── ci/profiles.yml                   # prod DuckDB target for Actions
├── data/                             # raw + warehouses (gitignored; CI regenerates)
├── docs/                             # dbt docs site (GitHub Pages)
├── analytics/
│   ├── dbt_project.yml
│   └── models/                       # sources, staging, marts, schema.yml
└── scripts/download_data.py          # fetch raw parquet before build
```
