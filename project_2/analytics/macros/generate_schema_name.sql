{#- dbt's default glues the profile schema onto layer names (dev_silver
    becomes default_silver etc). this override says: use MY names exactly.
    environments are separated by CATALOG (dev/prod in the profile), the
    Databricks-recommended pattern — bronze stays in workspace, shared. -#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
