{#- the flagship 3.43 macro: written twice verbatim at 3.41 (min, then max),
    extracted once here. expects the raw job_salary column in scope.
    handles: en-dash ranges ('100K–186K a year'), single values (both bounds),
    K/M suffixes, thousands commas + decimals, currency prefixes (ignored here;
    salary_currency owns them). serverless runs ansi mode, so every cast is a
    try_cast: unprofiled shapes degrade to null, never error. -#}
{% macro parse_salary(part) -%}
    {%- if part == 'min' -%}
        {%- set segment = "split(job_salary, '–')[0]" -%}
    {%- else -%}
        {%- set segment = "element_at(split(job_salary, '–'), -1)" -%}
    {%- endif -%}
    TRY_CAST(REPLACE(REGEXP_EXTRACT({{ segment }}, '([0-9][0-9,.]*)', 1), ',', '') AS DECIMAL(15, 2))
        * CASE UPPER(REGEXP_EXTRACT({{ segment }}, '[0-9][0-9,.]*([KkMm])', 1))
            WHEN 'K' THEN 1000
            WHEN 'M' THEN 1000000
            ELSE 1
          END
{%- endmacro %}
