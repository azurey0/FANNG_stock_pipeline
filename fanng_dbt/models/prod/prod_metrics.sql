{{ config(
    materialized='incremental',
    schema='faang_stock_production',
    alias='prod_metrics',
    partition_by={
        'field': 'processed_at',
        'data_type': 'timestamp',
        'granularity': 'day'
    },
    incremental_strategy='insert_overwrite',
    full_refresh = false
) }}

WITH volume_data AS (
    SELECT *
    FROM {{ ref('base_metrics') }}
),
price_data AS (
    SELECT date, company, ema20, ema50, ema200
    FROM {{ ref('ema') }}
),
signal_data AS (
    SELECT date, company, macd, signal AS macd_signal
    FROM {{ ref('macd') }}
)

SELECT
    CURRENT_TIMESTAMP() as processed_at,
    v.date,
    v.company,
    v.open,
    v.high,
    v.low,
    v.close,
    v.volume,
    p.ema20,
    p.ema50,
    p.ema200,
    s.macd,
    s.macd_signal
FROM volume_data v
JOIN price_data p ON v.date = p.date AND v.company = p.company
JOIN signal_data s ON v.date = s.date AND v.company = s.company

-- Specify how dbt decides what data to insert on each run
{% if is_incremental() %}
  -- this filter will only be applied on incremental runs
  WHERE v.date > (SELECT MAX(v.date) FROM {{ this }})
{% endif %}