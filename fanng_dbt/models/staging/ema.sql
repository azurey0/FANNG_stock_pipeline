{{ config(
    materialized='incremental',
    alias='ema',
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
),
calculate AS (
    SELECT
        CURRENT_TIMESTAMP() as processed_at,
        date,
        company,
        (close * (2 / (7 + 1))) + (LAG(close, 1) OVER (PARTITION BY company ORDER BY date) * (1 - (2 / (7+ 1)))) AS ema7,
        (close * (2 / (20 + 1))) + (LAG(close, 1) OVER (PARTITION BY company ORDER BY date) * (1 - (2 / (20 + 1)))) AS ema20,
        (close * (2 / (50 + 1))) + (LAG(close, 1) OVER (PARTITION BY company ORDER BY date) * (1 - (2 / (50 + 1)))) AS ema50,
        (close * (2 / (100 + 1))) + (LAG(close, 1) OVER (PARTITION BY company ORDER BY date) * (1 - (2 / (100 + 1)))) AS ema100,
        (close * (2 / (200 + 1))) + (LAG(close, 1) OVER (PARTITION BY company ORDER BY date) * (1 - (2 / (200 + 1)))) AS ema200
    FROM base
)
SELECT
    CURRENT_TIMESTAMP() as processed_at,
    date,
    company,
    CAST(ema7 AS NUMERIC) ema7,
    CAST(ema20 AS NUMERIC) ema20,
    CAST(ema50 AS NUMERIC) ema50,
    CAST(ema100 AS NUMERIC) ema100,
    CAST(ema200 AS NUMERIC) ema200
FROM 
    calculate

-- Specify how dbt decides what data to insert on each run
{% if is_incremental() %}
  -- this filter will only be applied on incremental runs
  WHERE date > (SELECT MAX(date) FROM {{ this }})
{% endif %}