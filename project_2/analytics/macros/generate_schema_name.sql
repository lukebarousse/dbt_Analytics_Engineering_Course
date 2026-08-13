{#- only the dev target gets sandboxed (dev_silver, dev_gold); every other
    target — prod, and the name a Databricks job invents for its generated
    profile — owns the clean medallion names. bronze is OUTSIDE dbt
    (raw landing, shared by all targets). -#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    {%- elif target.name == 'dev' -%}
        dev_{{ custom_schema_name | trim }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
