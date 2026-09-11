-- jinja practice, kept as a scratchpad (3.41): compiled by dbt, never built.
-- run it with `dbt show --select jinja_practice`, or paste the compiled file
-- from target/compiled/ into any SQL surface.
-- role_slug joined at 3.43: the sandbox is where the new macro got tested
-- before it touched a real model — macros are project-wide.
-- the roles list stopped being hardcoded at 3.53: dbt_utils.get_column_values
-- asks the column itself, at parse time, so the loop follows the data.

{% set roles = dbt_utils.get_column_values(ref('stg_job_postings'), 'search_term') %}

{% for role in roles %}
SELECT
    search_term,
    '{{ slugify(role) }}' AS role_slug,
    COUNT(*) AS postings
FROM {{ ref('stg_job_postings') }}
WHERE search_term = '{{ role }}'
GROUP BY search_term
{{ "UNION ALL" if not loop.last }}
{% endfor %}
