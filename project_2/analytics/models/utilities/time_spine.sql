-- required by MetricFlow (the metrics layer joins against this calendar)
SELECT explode(sequence(DATE'2025-07-01', DATE'2026-06-30', INTERVAL 1 DAY)) AS date_day
