{{ config(materialized='view') }}

-- Q5: high demand AND high salary; the demand floor keeps
-- one-posting salary outliers out of the ranking

with demand as (
    select * from {{ ref('in_demand_skills') }}
),

salary as (
    select * from {{ ref('top_skills_by_salary') }}
)

select
    demand.skill_id,
    demand.display_name,
    demand.category,
    demand.demand_count,
    demand.demand_pct,
    salary.avg_salary_year
from demand
inner join salary using (skill_id)
where demand.demand_count >= 100
order by salary.avg_salary_year desc, demand.demand_count desc
