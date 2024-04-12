{{ config(
    materialized='incremental',
    alias='rsi',
    partition_by={
        'field': 'processed_at',
        'data_type': 'timestamp',
        'granularity': 'day'
    },
    incremental_strategy='insert_overwrite',
    full_refresh = false
) }}


WITH PriceChanges AS (
    SELECT 
        date,
        company,
        close,
        LAG(close, 1) OVER (PARTITION BY company ORDER BY UNIX_DATE(date)) as previous_close,
        close - LAG(close, 1) OVER (PARTITION BY company ORDER BY UNIX_DATE(date)) as change
    FROM {{ ref('base_metrics')}}
),
GainsAndLosses AS (
    SELECT
        date,
        company,
        GREATEST(change, 0) as gain,
        -LEAST(change, 0) as loss
    FROM PriceChanges
),
Averages AS (
    SELECT
        date,
        company,
        AVG(gain) OVER (PARTITION BY company ORDER BY UNIX_DATE(date) ROWS BETWEEN 13 PRECEDING AND CURRENT ROW) as avg_gain,
        AVG(loss) OVER (PARTITION BY company ORDER BY UNIX_DATE(date) ROWS BETWEEN 13 PRECEDING AND CURRENT ROW) as avg_loss
    FROM GainsAndLosses
)
SELECT
    CURRENT_TIMESTAMP() as processed_at,
    date,
    company,
    100 - (100 / (1 + avg_gain / NULLIF(avg_loss, 0))) as RSI
FROM Averages

-- Specify how dbt decides what data to insert on each run
{% if is_incremental() %}
  -- this filter will only be applied on incremental runs
  WHERE date > (SELECT MAX(date) FROM {{ this }})
{% endif %}