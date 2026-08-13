{#- the flagship 3.52 macro: written twice verbatim at 3.32 (min, then max),
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
    try_cast(replace(regexp_extract({{ segment }}, '([0-9][0-9,.]*)', 1), ',', '') as decimal(15, 2))
        * case upper(regexp_extract({{ segment }}, '[0-9][0-9,.]*([KkMm])', 1))
            when 'K' then 1000
            when 'M' then 1000000
            else 1
          end
{%- endmacro %}
