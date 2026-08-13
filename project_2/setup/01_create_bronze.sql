-- ============================================================================
-- BRONZE SETUP — run ONCE in the Databricks SQL editor (the EL step; 3.12)
-- Prereq: upload data/raw/*.parquet into the volume via
--   Catalog → workspace → bronze → raw → Upload to this volume
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS workspace.bronze;
CREATE VOLUME IF NOT EXISTS workspace.bronze.raw;

-- after uploading the files:
CREATE OR REPLACE TABLE workspace.bronze.raw_job_postings AS
SELECT * FROM read_files('/Volumes/workspace/bronze/raw/raw_job_postings_*.parquet', format => 'parquet');

CREATE OR REPLACE TABLE workspace.bronze.raw_job_skills AS
SELECT * FROM read_files('/Volumes/workspace/bronze/raw/raw_job_skills.parquet', format => 'parquet');

-- sanity: 843,097 and 3,304,574 rows respectively
SELECT 'raw_job_postings' AS t, COUNT(*) AS rows FROM workspace.bronze.raw_job_postings
UNION ALL
SELECT 'raw_job_skills', COUNT(*) FROM workspace.bronze.raw_job_skills;
