-- grain: one row per posting per SCRAPE DAY, not per job. re-scrapes stay in;
-- the snapshot replays them, and fct_job_postings owns the dedupe to one row per job.

{% set extension_keywords = ['Health insurance', 'Dental insurance', 'Paid time off', 'No degree mentioned'] %}

WITH source AS (

    SELECT *
    FROM {{ source('jobs', 'raw_job_postings') }}
    -- staging's door (3.33): the scraper flags its own failures — error is TRUE
    -- on the 151,147 failure rows and NULL otherwise, so IS NOT TRUE keeps the
    -- good rows (= false would null-compare them all away). raw keeps the record.
    WHERE error IS NOT TRUE
    -- the earned cut (3.83): 6,255 id-less incident-window postings — real rows,
    -- dropped with eyes open; an id-less row can't be deduped or joined
      AND job_id IS NOT NULL

),

-- pull 'n units ago' apart once. serverless runs ansi mode, and regexp_extract
-- returns '' (not null) on no match, so every cast is guarded: unprofiled shapes
-- degrade to null instead of killing the model
parsed AS (

    SELECT
        *,
        CAST(search_time AS TIMESTAMP) AS searched_at,
        TRY_CAST(NULLIF(REGEXP_EXTRACT(job_posted_at, '^([0-9]+)', 1), '') AS INT) AS posted_qty,
        REGEXP_EXTRACT(job_posted_at, '(minute|hour|day|month)', 1) AS posted_unit

    FROM source

),

renamed AS (

    SELECT
        -- ids + scrape metadata
        job_id,
        search_term,
        search_date,
        searched_at,
        search_location,

        -- posting attributes
        job_title,
        TRIM(company_name) AS company_name,
        job_location,
        REGEXP_REPLACE(job_via, '^via ', '') AS source_platform,  -- 'via LinkedIn' scraper artifact, ~6.3k rows
        job_schedule_type,
        job_work_from_home,

        -- relative posted time resolved against the scrape time
        job_posted_at,
        CASE posted_unit
            WHEN 'minute' THEN TIMESTAMPADD(minute, -posted_qty, searched_at)
            WHEN 'hour' THEN TIMESTAMPADD(hour, -posted_qty, searched_at)
            WHEN 'day' THEN TIMESTAMPADD(day, -posted_qty, searched_at)
            WHEN 'month' THEN TIMESTAMPADD(month, -posted_qty, searched_at)
        END AS posted_at,
        CAST(posted_at AS DATE) AS posted_date,  -- lateral alias: reuses posted_at from the line above

        -- salary text to numbers; raw text kept, the snapshot lesson diffs it across scrapes
        job_salary,
        {{ parse_salary('min') }} AS salary_min,
        {{ parse_salary('max') }} AS salary_max,
        NULLIF(REGEXP_EXTRACT(job_salary, 'an? (year|hour|month|day|week)$', 1), '') AS salary_period,
        NULLIF(TRIM(REGEXP_EXTRACT(job_salary, '^([^0-9]+)', 1)), '') AS salary_currency,  -- 'PKR', 'CA$', '₱', ...; null = usd

        -- one boolean per extension keyword: the loop writes the sql, slugify names the columns
        {% for keyword in extension_keywords %}
        ARRAY_CONTAINS(FROM_JSON(job_extensions_raw, 'array<string>'), '{{ keyword }}') AS has_{{ slugify(keyword) }}{{ "," if not loop.last }}
        {% endfor %}

    FROM parsed

)

SELECT * FROM renamed
