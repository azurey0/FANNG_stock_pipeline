{{ config(
    materialized='incremental',
    alias='base_metrics',
    partition_by={
        'field': 'processed_at',
        'data_type': 'timestamp',
        'granularity': 'day'
    },
    incremental_strategy='insert_overwrite',
    full_refresh = false
) }}

SELECT
    CURRENT_TIMESTAMP() as processed_at,  -- This generates the ingestion timestamp
    DATE(parse_date('%Y-%m-%d', Date)) as date,
    SAFE_CAST(Open as NUMERIC) as open,
    SAFE_CAST(High as NUMERIC) as high,
    SAFE_CAST(Low as NUMERIC) as low,
    SAFE_CAST(Close as NUMERIC) as close,
    SAFE_CAST(Volume as NUMERIC) as volume,
    Company as company
FROM
    {{ source('fanng_stock', 'raw') }}

-- Specify how dbt decides what data to insert on each run
{% if is_incremental() %}
  -- this filter will only be applied on incremental runs
  WHERE date_column > (SELECT MAX(date_column) FROM {{ this }})
{% endif %}