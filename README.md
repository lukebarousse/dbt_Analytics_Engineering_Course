# 🔧 dbt for Data Analysts & Engineers - Full Course

Data Nerds! This repo contains all the files needed to follow along my free course: dbt for Data Analysts & Engineers <!-- TODO: course link + thumbnail badge at launch -->

## Team Members 👥

**🙋🏼‍♂️ Course Leader:** [Luke Barousse](https://www.linkedin.com/in/luke-b)
<!-- TODO: producer / content developer / video editor at launch -->

## What this course covers

You already know SQL. This course teaches you to turn scattered SQL scripts into a tested, documented, version-controlled data pipeline with dbt. It's the **T in ELT**: data engineers extract and load the raw data (that part already happened); analytics engineers transform it inside the warehouse. That's the job this course trains.

You'll build **two portfolio projects**: a local, tested, automated job-market pipeline on DuckDB (published with GitHub Actions), then a production-grade rebuild on BigQuery — a year of real job postings (~692k rows) from raw files to a documented star schema.

## What's in this repo

Lesson notes live in the course itself — this repo holds the code:

| Folder | What it is |
| --- | --- |
| [project_1/](project_1/) | Reference implementation of Project #1 (dbt + DuckDB, the finished repo you build in the course) |
| [project_2/](project_2/) | Reference implementation of Project #2 (dbt + BigQuery) |
| [scripts/](scripts/) | `download_data.py` — fetches the course dataset |
| [img/](img/) | Diagrams & images used in the course READMEs |

Each project folder is self-contained with its own `uv` environment (Project #1 uses the DuckDB adapter, Project #2 the BigQuery adapter).

## Setup

Requires [uv](https://docs.astral.sh/uv/) (Part 1 of the bootcamp covers it). In the course you build your own repo from scratch — to run a reference project directly:

```bash
git clone https://github.com/lukebarousse/dbt_Analytics_Engineering_Course.git
cd dbt_Analytics_Engineering_Course
python scripts/download_data.py              # downloads the course dataset (~85MB)
cd project_1 && uv sync                      # per-project env: dbt + DuckDB adapter
cd job_postings && uv run dbt debug          # verify everything works
```

## The dataset

A year of real job postings (Data Engineer, Data Analyst, Data Scientist roles) collected by my [datanerd.tech](https://datanerd.tech) pipeline, July 2025 - June 2026. Raw and intentionally messy: duplicate scrapes, error rows, salary as text, dates like "10 hours ago", JSON columns. Cleaning it is the course.

Files ship as monthly parquet in the [dataset release](https://github.com/lukebarousse/dbt_Analytics_Engineering_Course/releases/tag/dataset-v1); the download script above fetches them for you.
