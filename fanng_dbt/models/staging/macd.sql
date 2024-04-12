{{ config(
    materialized='incremental',
    alias='macd',
    partition_by={
        'field': 'processed_at',
        'data_type': 'timestamp',
        'granularity': 'day'
    },
    incremental_strategy='insert_overwrite',
    full_refresh = false
) }}

WITH EMACalculations AS (
    SELECT
        date,
        company,
        close,
        AVG(close) OVER (PARTITION BY company ORDER BY UNIX_DATE(date) RANGE BETWEEN 11 PRECEDING AND CURRENT ROW) as ema12,
        AVG(close) OVER (PARTITION BY company ORDER BY UNIX_DATE(date) RANGE BETWEEN 25 PRECEDING AND CURRENT ROW) as ema26
    FROM {{ ref('base_metrics')}}
)

SELECT
    CURRENT_TIMESTAMP() as processed_at,
    date,
    company,
    ema12,
    ema26,
    ema12 - ema26 as macd,
    AVG(ema12 - ema26) OVER (PARTITION BY company ORDER BY UNIX_DATE(date) RANGE BETWEEN 8 PRECEDING AND CURRENT ROW) as signal
FROM EMACalculations


-- Specify how dbt decides what data to insert on each run
{% if is_incremental() %}
  -- this filter will only be applied on incremental runs
  WHERE date > (SELECT MAX(date) FROM {{ this }})
{% endif %}
