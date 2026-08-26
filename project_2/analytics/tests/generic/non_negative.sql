{#- a custom GENERIC test: a macro-style block that returns FAILING rows.
    saved in tests/generic/, called from any properties yml like the
    built-ins. OPTIONAL on camera; deep patterns in supporter (B.2). -#}
{% test non_negative(model, column_name) %}

SELECT *
FROM {{ model }}
WHERE {{ column_name }} < 0

{% endtest %}
