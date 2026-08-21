{#- the student-written 3.43 macro: the filter chain from the 3.42 loop, named.
    call sites: the sandbox that tested it (analyses/jinja_practice) and
    staging's has_* flags — macros are project-wide (bonus jobs_pivot is a
    third caller for supporters). -#}
{% macro slugify(text) -%}
{{ text | lower | replace(' ', '_') }}
{%- endmacro %}
