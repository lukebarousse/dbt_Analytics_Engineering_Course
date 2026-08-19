{#- the student-written 3.62 macro: the filter chain from the 3.61 loop, named.
    core call site: staging's has_* flags (jobs_pivot, its former second
    caller, demoted to bonus/ 2026-08-19). -#}
{% macro slugify(text) -%}
{{ text | lower | replace(' ', '_') }}
{%- endmacro %}
