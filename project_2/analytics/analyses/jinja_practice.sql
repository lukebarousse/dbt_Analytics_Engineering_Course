-- jinja practice, kept as a scratchpad (3.41): compiled by dbt, never built.
-- run `dbt compile`, then read the expansion in target/compiled/.

{% set roles = ['Data Analyst', 'Data Engineer', 'Data Scientist'] %}

{% for role in roles %}
SELECT
    '{{ role }}' AS role,
    '{{ role | lower | replace(' ', '_') }}' AS slug
{{ "UNION ALL" if not loop.last }}
{% endfor %}
