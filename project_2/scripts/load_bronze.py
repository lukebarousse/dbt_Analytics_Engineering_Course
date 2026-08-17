# Databricks notebook source
# MAGIC %md
# MAGIC # Load bronze — the EL step (run once)
# MAGIC Downloads the course dataset from GitHub **directly into a Unity Catalog Volume**
# MAGIC (no local files, no drag-and-drop), then lands it as bronze tables.
# MAGIC
# MAGIC Import this notebook (Workspace → Import → URL) and **Run all**.

# COMMAND ----------

REPO = "lukebarousse/dbt_Analytics_Engineering_Course"
TAG = "dataset-v1"                       # the course dataset release (pinned)
VOLUME = "/Volumes/raw/bronze/files"

MONTHS = [
    "2025-07", "2025-08", "2025-09", "2025-10", "2025-11", "2025-12",
    "2026-01", "2026-02", "2026-03", "2026-04", "2026-05", "2026-06",
]
FILES = [f"raw_job_postings_{m}.parquet" for m in MONTHS] + ["raw_job_skills.parquet"]

# COMMAND ----------

# the landing zone: the raw catalog + a schema for bronze + a Volume for the files
# (raw has ONE owner — this notebook; dev and prod both read it)
spark.sql("CREATE CATALOG IF NOT EXISTS raw")
spark.sql("CREATE SCHEMA IF NOT EXISTS raw.bronze")
spark.sql("CREATE VOLUME IF NOT EXISTS raw.bronze.files")

# COMMAND ----------

# download from the GitHub release straight into the Volume (~85MB total)
import urllib.request, os

for name in FILES:
    dest = f"{VOLUME}/{name}"
    if os.path.exists(dest):
        print(f"  already have {name}")
        continue
    print(f"  downloading {name} ...")
    urllib.request.urlretrieve(f"https://github.com/{REPO}/releases/download/{TAG}/{name}", dest)

print("Done.")

# COMMAND ----------

# land the bronze tables — raw, untouched, exactly as the scraper delivered them
spark.sql(f"""
    CREATE OR REPLACE TABLE raw.bronze.raw_job_postings AS
    SELECT * FROM read_files('{VOLUME}/raw_job_postings_*.parquet', format => 'parquet')
""")
spark.sql(f"""
    CREATE OR REPLACE TABLE raw.bronze.raw_job_skills AS
    SELECT * FROM read_files('{VOLUME}/raw_job_skills.parquet', format => 'parquet')
""")

# COMMAND ----------

# sanity check — expect 843,097 postings and 3,304,574 skill rows
display(spark.sql("""
    SELECT 'raw_job_postings' AS table, COUNT(*) AS rows FROM raw.bronze.raw_job_postings
    UNION ALL
    SELECT 'raw_job_skills', COUNT(*) FROM raw.bronze.raw_job_skills
"""))
