with job_postings as (
    select * from {{ ref('fct_job_postings') }}
)

select
    company_name,
    count(*) as total_job_postings,
    min(posted_date) as first_posted_date,
    max(posted_date) as last_posted_date,
    avg(salary_year_avg) as avg_salary_year
from job_postings
-- company_name is the natural key; a null row would break the one-row-per-company grain
where company_name is not null
group by company_name
