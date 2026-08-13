{#- dev builds land in dev_-prefixed schemas; prod owns the clean medallion names.
    bronze is OUTSIDE dbt (raw landing, shared by both targets). -#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    {%- elif target.name == 'prod' -%}
        {{ custom_schema_name | trim }}
    {%- else -%}
        dev_{{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
