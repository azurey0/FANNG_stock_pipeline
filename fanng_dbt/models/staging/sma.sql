{{ config(
    materialized='incremental',
    alias='sma',
    partition_by={
        'field': 'processed_at',
        'data_type': 'timestamp',
        'granularity': 'day'
    },
    incremental_strategy='insert_overwrite',
    full_refresh = false
) }}

WITH base AS (
    SELECT
        date,
        company,
        close,
    FROM {{ ref('base_metrics')}}
)
SELECT
    CURRENT_TIMESTAMP() as processed_at,
    date,
    company,
    AVG(close) OVER (PARTITION BY company ORDER BY UNIX_DATE(date) RANGE BETWEEN 6 PRECEDING AND CURRENT ROW) AS sma7,
    AVG(close) OVER (PARTITION BY company ORDER BY UNIX_DATE(date) RANGE BETWEEN 20 PRECEDING AND CURRENT ROW) AS sma20,
    AVG(close) OVER (PARTITION BY company ORDER BY UNIX_DATE(date) RANGE BETWEEN 50 PRECEDING AND CURRENT ROW) AS sma50,
    AVG(close) OVER (PARTITION BY company ORDER BY UNIX_DATE(date) RANGE BETWEEN 100 PRECEDING AND CURRENT ROW) AS sma100,
    AVG(close) OVER (PARTITION BY company ORDER BY UNIX_DATE(date) RANGE BETWEEN 200 PRECEDING AND CURRENT ROW) AS sma200
FROM base


-- Specify how dbt decides what data to insert on each run
{% if is_incremental() %}
  -- this filter will only be applied on incremental runs
  WHERE date > (SELECT MAX(date) FROM {{ this }})
{% endif %}