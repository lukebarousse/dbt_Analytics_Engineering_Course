{#- dbt's default glues the profile schema onto declared layer names
    (staging becomes default_staging — on screen from 3.33 until this fix
    lands at 3.43). this override says: use MY names exactly.
    environments are separated by CATALOG (dev/prod in the profile);
    raw keeps its own shared catalog. -#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
