{#- the student-written 3.43 macro: the filter chain from the 3.42 loop, named.
    core call site: staging's has_* flags (jobs_pivot, its former second
    caller, lives in bonus/). -#}
{% macro slugify(text) -%}
{{ text | lower | replace(' ', '_') }}
{%- endmacro %}
