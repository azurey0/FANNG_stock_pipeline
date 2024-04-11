from airflow import DAG
from airflow.utils.dates import days_ago
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator

GCS_BUCKET = "fanng_stock_datalake"
GCS_FILE_PATH = "uploaded_datasets/*.csv"
RAW_TABLE = "decapstone-419603.fanng_stock_dataset.raw"

default_args = {
    'owner': 'airflow',
    'start_date': days_ago(1),
}

with DAG(
    'load_multiple_csv_to_bigquery',
    default_args=default_args,
    schedule_interval='@daily',  # Adjust based on your needs
    tags=['FANNG', 'stock_data'],
) as dag:

    load_csv_to_bq = GCSToBigQueryOperator(
        task_id='load_csv_to_bq',
        bucket=GCS_BUCKET,
        source_objects=[GCS_FILE_PATH],  # Use wildcard to match all CSV files
        destination_project_dataset_table=RAW_TABLE,
        write_disposition='WRITE_TRUNCATE',  # Consider 'WRITE_APPEND' if you don't want to overwrite
        source_format='CSV',
        skip_leading_rows=1,  # Use if your CSV files have a header row
        autodetect=False,  # Enable schema auto-detection
        src_fmt_configs={"nullMarker": "null"},  # Adjust this to match how null values are represented in your CSV files
        schema_fields=[
        {'name': 'Date', 'type': 'STRING', 'mode': 'NULLABLE'},
        {'name': 'Open', 'type': 'STRING', 'mode': 'NULLABLE'},
        {'name': 'High', 'type': 'STRING', 'mode': 'NULLABLE'},
        {'name': 'Low', 'type': 'STRING', 'mode': 'NULLABLE'},
        {'name': 'Close', 'type': 'STRING', 'mode': 'NULLABLE'},
        {'name': 'AdjClose', 'type': 'STRING', 'mode': 'NULLABLE'},
        {'name': 'Volume', 'type': 'STRING', 'mode': 'NULLABLE'},
        {'name': 'Year', 'type': 'STRING', 'mode': 'NULLABLE'},
        {'name': 'Company', 'type': 'STRING', 'mode': 'NULLABLE'},  # Added based on your previous modification
        # Add additional fields as necessary
    ],
    )
