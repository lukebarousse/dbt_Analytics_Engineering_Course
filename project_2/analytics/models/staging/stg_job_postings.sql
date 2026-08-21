-- grain: one row per posting per SCRAPE DAY, not per job. re-scrapes stay in;
-- the snapshot replays them, and fct_job_postings owns the dedupe to one row per job.

{% set extension_keywords = [
    'Health insurance',
    'Dental insurance',
    'Paid time off',
    'No degree mentioned'
] %}

WITH source AS (

    SELECT *
    FROM {{ source('jobs', 'raw_job_postings') }}
    -- staging's door (3.03.3): the scraper flags its own failures — error is TRUE
    -- on the 151,147 failure rows and NULL otherwise, so IS NOT TRUE keeps the
    -- good rows (= false would null-compare them all away). raw keeps the record.
    WHERE error IS NOT TRUE
    -- the earned cut (3.09.3): 6,255 id-less incident-window postings — real rows,
    -- dropped with eyes open; an id-less row can't be deduped or joined
      AND job_id IS NOT NULL

),

-- parse the extensions JSON once; the loop below probes the parsed array
parsed AS (

    SELECT
        *,
        FROM_JSON(job_extensions_raw, 'array<string>') AS job_extensions
    FROM source

),

renamed AS (

    SELECT
        -- ids + scrape metadata
        job_id,
        search_term,
        search_date,
        CAST(search_time AS TIMESTAMP) AS searched_at,
        search_location,

        -- posting attributes
        job_title,
        TRIM(company_name) AS company_name,
        job_location,
        REGEXP_REPLACE(job_via, '^via ', '') AS source_platform,  -- 'via LinkedIn' scraper artifact, ~6.3k rows
        job_schedule_type,
        job_work_from_home,

        -- relative posted time, kept RAW: search_date carries the course's time
        -- axis (~95% of rows are scraped within a day of posting, so the two
        -- nearly agree); parsing this precisely is a supporter exercise
        job_posted_at,

        -- salary text to numbers; raw text kept, the snapshot lesson diffs it across scrapes
        job_salary,
        {{ parse_salary('min') }} AS salary_min,
        {{ parse_salary('max') }} AS salary_max,
        NULLIF(REGEXP_EXTRACT(job_salary, 'an? (year|hour|month|day|week)$', 1), '') AS salary_period,
        NULLIF(TRIM(REGEXP_EXTRACT(job_salary, '^([^0-9]+)', 1)), '') AS salary_currency,  -- 'PKR', 'CA$', '₱', ...; null = usd

        -- one boolean per extension keyword: the loop probes the parsed
        -- array, slugify names the columns
        {% for keyword in extension_keywords %}
        ARRAY_CONTAINS(
            job_extensions,
            '{{ keyword }}'
        ) AS has_{{ slugify(keyword) }}
        {{ "," if not loop.last }}
        {% endfor %}

    FROM parsed

)

SELECT * FROM renamed
