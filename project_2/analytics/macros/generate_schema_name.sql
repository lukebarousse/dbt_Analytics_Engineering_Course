{#- dbt's default glues the profile schema onto declared layer names
    (staging becomes default_staging — on screen from 3.33 until this fix
    lands at 3.44). this is dbt's own macro with ONE edit: the else-branch
    drops the glue — use MY names exactly. the name matters: override the
    entry-point generate_schema_name (the docs template); a default__-named
    copy can answer dbt show probes yet be skipped by a real build.
    environments are separated by CATALOG (dev/prod in the profile); raw
    keeps its own shared catalog. -#}
{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}

        {{ default_schema }}

    {%- else -%}

        {{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}
