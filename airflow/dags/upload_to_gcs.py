from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.utils.dates import days_ago
from airflow.models.param import Param
from datetime import datetime
import os
import logging
import glob
from google.cloud import storage

# Define constants for the paths and GCS bucket
BASE_PATH = "/home/zhangr235_dev0/FANNG_stock_pipeline/raw_dataset/partitioned_"
COMPANIES = ["Amazon", "Facebook", "Apple", "Google", "Netflix"]  # Extend this list with other companies as needed
GCS_BUCKET = "fanng_stock_datalake"
GCS_UPLOAD_FOLDER = "uploaded_datasets/"

# Set up logging
logger = logging.getLogger("airflow.task")

def process_and_upload_files(company, year, **kwargs):
    # Retrieve the DAG run configuration
    dag_run_conf = kwargs.get('dag_run').conf if kwargs.get('dag_run') else {}

    # Check if a specific company is specified for this DAG run
    # And skip processing if the company doesn't match
    if 'company' in dag_run_conf and dag_run_conf['company'] != company:
        logging.info(f"Skipping {company} in {year}, not the target company for this run.")
        return
    
    try:
        # Construct the file path pattern
        file_path_pattern = f"{BASE_PATH}{company}/{company}.csv_{year}"
        
        # Find the first matching file for simplicity (adjust as needed for multiple files)
        matching_files = glob.glob(file_path_pattern)
        if not matching_files:
            logger.info(f"No files found for {company} in {year}")
            return
        
        extension = 'csv'
        os.chdir(file_path_pattern)
        file_path = glob.glob('*.{}'.format(extension))[0] #find the csv file 
        new_file_name = f"{company}_{year}.csv"
        
        # Rename the file locally (optional: move to a staging area if you don't want to rename in place)
        new_file_path = os.path.join(os.path.dirname(file_path), new_file_name)
        os.rename(file_path, new_file_path)
        logger.info(f"File renamed to {new_file_name}")
        
        # Upload the file to GCS
        client = storage.Client()
        bucket = client.bucket(GCS_BUCKET)
        blob = bucket.blob(f"{GCS_UPLOAD_FOLDER}{new_file_name}")
        blob.upload_from_filename(new_file_path)
        
        logger.info(f"Uploaded {new_file_name} to {GCS_BUCKET}/{GCS_UPLOAD_FOLDER}")
    except Exception as e:
        logger.error(f"Error processing {company} in {year}: {str(e)}", exc_info=True)

with DAG(
    'fanng_stock_pipeline',
    default_args={
        'owner': 'airflow',
    },
    description='DAG for processing and uploading FANNG stock data',
    schedule_interval=None,
    start_date=days_ago(1),
    catchup=False,
    tags=['FANNG', 'stock_data'],
) as dag:
    
    # Dynamically create tasks for each company and year
    for company in COMPANIES:
        for year in range(1980, 2023):  # Adjust the range as necessary
            PythonOperator(
                task_id=f"process_and_upload_{company}_{year}",
                python_callable=process_and_upload_files,
                op_kwargs={'company': company, 'year': str(year)},
                provide_context=True,  # Ensure **kwargs is passed to the callable
            )
