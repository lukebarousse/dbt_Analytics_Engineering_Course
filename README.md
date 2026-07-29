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
| [0. Setup and orientation](0_Setup_Orientation/) | What analytics engineering is; project setup with dbt Core + DuckDB |
| [1. Models and dependencies](1_Models_Dependencies/) | Models, `ref`, the DAG, materializations |
| [2. Structuring a project](2_Structuring_Project/) | Layering: staging, intermediate, marts (and how it maps to medallion) |
| [3. Trust: sources and tests](3_Sources_Tests/) | Declaring sources, freshness, data tests |
| [4. Incremental processing](4_Incremental_Processing/) | Processing only new data |
| [5. Documentation and lineage](5_Documentation_Lineage/) | Self-documenting pipelines, the lineage graph |
| [6. Shipping to production](6_Shipping_Production/) | dev vs prod, `dbt build`, deploying to BigQuery, capstone |

## Setup

Requires [uv](https://docs.astral.sh/uv/) (Part 1 of the bootcamp covers it). Then:

```bash
git clone https://github.com/lukebarousse/dbt_Analytics_Engineering_Course.git
cd dbt_Analytics_Engineering_Course
uv sync                                      # installs dbt (DuckDB + BigQuery adapters)
uv run job_postings/scripts/download_data.py    # downloads the course dataset (~85MB)
cd job_postings
uv run dbt debug                             # verify everything works
```

## The dataset

A year of real job postings (Data Engineer, Data Analyst, Data Scientist roles) collected by my [datanerd.tech](https://datanerd.tech) pipeline, July 2025 - June 2026. Raw and intentionally messy: duplicate scrapes, error rows, salary as text, dates like "10 hours ago", JSON columns. Cleaning it is the course.

Files ship as monthly parquet in the [dataset release](https://github.com/lukebarousse/dbt_Analytics_Engineering_Course/releases/tag/dataset-v1); the download script above fetches them for you.
