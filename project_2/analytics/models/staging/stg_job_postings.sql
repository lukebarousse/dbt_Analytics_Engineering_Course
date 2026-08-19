-- grain: one row per posting per SCRAPE DAY, not per job. re-scrapes stay in;
-- the snapshot replays them, and fct_job_postings owns the dedupe to one row per job.

{% set extension_keywords = ['Health insurance', 'Dental insurance', 'Paid time off', 'No degree mentioned'] %}

with source as (

    select *
    from {{ source('jobs', 'raw_job_postings') }}
    -- staging's door (3.34): the scraper flags its own failures — error is TRUE
    -- on the 151,147 failure rows and NULL otherwise, so IS NOT TRUE keeps the
    -- good rows (= false would null-compare them all away). raw keeps the record.
    where error is not true
    -- the earned cut (3.83): 6,255 id-less incident-window postings — real rows,
    -- dropped with eyes open; an id-less row can't be deduped or joined
      and job_id is not null

),

-- pull 'n units ago' apart once. serverless runs ansi mode, and regexp_extract
-- returns '' (not null) on no match, so every cast is guarded: unprofiled shapes
-- degrade to null instead of killing the model
parsed as (

    select
        *,
        cast(search_time as timestamp) as searched_at,
        try_cast(nullif(regexp_extract(job_posted_at, '^([0-9]+)', 1), '') as int) as posted_qty,
        regexp_extract(job_posted_at, '(minute|hour|day|month)', 1) as posted_unit

    from source

),

renamed as (

    select
        -- ids + scrape metadata
        job_id,
        search_term,
        search_date,
        searched_at,
        search_location,

        -- posting attributes
        job_title,
        trim(company_name) as company_name,
        job_location,
        regexp_replace(job_via, '^via ', '') as source_platform,  -- 'via LinkedIn' scraper artifact, ~6.3k rows
        job_schedule_type,
        job_work_from_home,

        -- relative posted time resolved against the scrape time
        job_posted_at,
        case posted_unit
            when 'minute' then timestampadd(minute, -posted_qty, searched_at)
            when 'hour' then timestampadd(hour, -posted_qty, searched_at)
            when 'day' then timestampadd(day, -posted_qty, searched_at)
            when 'month' then timestampadd(month, -posted_qty, searched_at)
        end as posted_at,
        cast(posted_at as date) as posted_date,  -- lateral alias: reuses posted_at from the line above

        -- salary text to numbers; raw text kept, the snapshot lesson diffs it across scrapes
        job_salary,
        {{ parse_salary('min') }} as salary_min,
        {{ parse_salary('max') }} as salary_max,
        nullif(regexp_extract(job_salary, 'an? (year|hour|month|day|week)$', 1), '') as salary_period,
        nullif(trim(regexp_extract(job_salary, '^([^0-9]+)', 1)), '') as salary_currency,  -- 'PKR', 'CA$', '₱', ...; null = usd

        -- one boolean per extension keyword: the loop writes the sql, slugify names the columns
        {% for keyword in extension_keywords %}
        array_contains(from_json(job_extensions_raw, 'array<string>'), '{{ keyword }}') as has_{{ slugify(keyword) }}{{ "," if not loop.last }}
        {% endfor %}

    from parsed

)

select * from renamed
