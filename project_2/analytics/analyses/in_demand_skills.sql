-- Q3: skill demand across the whole star (fct ⋈ bridge ⋈ dim_skill).
-- a QUESTION, not a model — it lives in analyses/ (3.71). all roles by default;
-- pick yours with:
--   dbt compile --select in_demand_skills --vars 'job_title: Data Analyst'

with job_postings as (

    select job_id
    from {{ ref('fct_job_postings') }}
    {% if var('job_title', none) %}
    where search_term = '{{ var("job_title") }}'
    {% endif %}

),

bridge as (
    select * from {{ ref('job_skills_bridge') }}
),

skills as (
    select * from {{ ref('dim_skill') }}
)

select
    skills.skill_id,
    skills.display_name,
    skills.category,
    count(distinct bridge.job_id) as demand_count,
    round(count(distinct bridge.job_id) / (select count(*) from job_postings), 4) as demand_pct
from bridge
inner join job_postings using (job_id)
inner join skills using (skill_id)
group by skills.skill_id, skills.display_name, skills.category
order by demand_count desc
