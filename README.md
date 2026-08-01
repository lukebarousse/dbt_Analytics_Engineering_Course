# 🔧 dbt for Data Analysts & Engineers - Full Course

Data Nerds! This repo contains all the files needed to follow along my free course: dbt for Data Analysts & Engineers <!-- TODO: course link + thumbnail badge at launch -->

## Team Members 👥

**🙋🏼‍♂️ Course Leader:** [Luke Barousse](https://www.linkedin.com/in/luke-b)
<!-- TODO: producer / content developer / video editor at launch -->

## What this course covers

You already know SQL. This course teaches you to turn scattered SQL scripts into a tested, documented, version-controlled data pipeline with dbt. It's the **T in ELT**: data engineers extract and load the raw data (that part already happened); analytics engineers transform it inside the warehouse. That's the job this course trains.

You'll build one project the whole way through: transforming a year of real data job postings (~500k jobs) from raw files into a tested, documented star schema, first locally with DuckDB, then deployed to BigQuery in the cloud.

## Table of Contents

| Module | Concepts |
| --- | --- |
| [0. Intro](0_intro/) | What dbt is, prerequisites, the data and project overview |
| [1. Basics](1_basics/) | Setup, models, `ref`, the DAG & docs, materializations |
| [2. Advanced](2_advanced/) | Layering, refactoring, sources, tests, incremental |
| [3. Project](3_project/) | Dev vs prod, ship to BigQuery, capstone |

## Setup

Requires [uv](https://docs.astral.sh/uv/) (Part 1 of the bootcamp covers it). Then:

```bash
git clone https://github.com/lukebarousse/dbt_Analytics_Engineering_Course.git
cd dbt_Analytics_Engineering_Course
uv sync                                      # installs dbt (DuckDB + BigQuery adapters)
uv run scripts/download_data.py                 # downloads the course dataset (~85MB)
cd project_1
uv run dbt debug                             # verify everything works
```

## The dataset

A year of real job postings (Data Engineer, Data Analyst, Data Scientist roles) collected by my [datanerd.tech](https://datanerd.tech) pipeline, July 2025 - June 2026. Raw and intentionally messy: duplicate scrapes, error rows, salary as text, dates like "10 hours ago", JSON columns. Cleaning it is the course.

Files ship as monthly parquet in the [dataset release](https://github.com/lukebarousse/dbt_Analytics_Engineering_Course/releases/tag/dataset-v1); the download script above fetches them for you.
