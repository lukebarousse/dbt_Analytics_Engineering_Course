{#- the student-written 3.62 macro: the filter chain from the 3.61 loop, named.
    two call sites earn it: staging's has_* flags and jobs_pivot's columns. -#}
{% macro slugify(text) -%}
{{ text | lower | replace(' ', '_') }}
{%- endmacro %}
