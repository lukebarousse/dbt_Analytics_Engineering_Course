{{ config(materialized='view') }}

-- Q1: the 100 best-paying postings with a usable annual salary

with job_postings as (
    select * from {{ ref('fct_job_postings') }}
)

select
    job_id,
    job_title,
    company_name,
    job_location,
    search_term,
    posted_date,
    salary_year_avg,
    has_health_insurance,
    has_dental_insurance,
    has_paid_time_off,
    has_no_degree_mentioned
from job_postings
where salary_year_avg is not null
order by salary_year_avg desc
limit 100
