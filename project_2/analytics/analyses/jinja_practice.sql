-- jinja practice, kept as a scratchpad (3.41): compiled by dbt, never built.
-- run it with `dbt show --select jinja_practice`, or paste the compiled file
-- from target/compiled/ into any SQL surface.
-- role_slug joined at 3.43: the sandbox is where the new macro got tested
-- before it touched a real model — macros are project-wide.

{% set roles = ['data analyst', 'data engineer', 'data scientist'] %}

{% for role in roles %}
SELECT
    search_term,
    '{{ slugify(role) }}' AS role_slug,
    COUNT(*) AS postings
FROM {{ ref('stg_job_postings') }}
WHERE search_term = '{{ role | title }}'
GROUP BY search_term
{{ "UNION ALL" if not loop.last }}
{% endfor %}
