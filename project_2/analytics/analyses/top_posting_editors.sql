-- which companies edit their postings the most? the 3.10.3 payoff — a question
-- only the snapshot can answer (staging has the scrapes, but no notion of "changed").
-- the whole query leans on one idea: dbt_valid_to IS NOT NULL = a closed version
-- exists = that job changed at some point. the snapshot idiom, inverted.
-- live receipt: Meta 415 · Capital One 387 · Hertz 228 — the SCD lesson's own
-- example company (Facebook → Meta) turns out to be the biggest serial editor.

SELECT
    company_name,
    COUNT(DISTINCT job_id) AS jobs_changed
FROM {{ ref('job_postings_snapshot') }}
WHERE dbt_valid_to IS NOT NULL
GROUP BY company_name
ORDER BY jobs_changed DESC
LIMIT 10
