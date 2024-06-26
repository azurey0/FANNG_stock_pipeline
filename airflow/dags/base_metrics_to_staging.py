from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.utils.dates import days_ago

with DAG('base_metrics_to_staging',
         start_date=days_ago(1),
         tags=['FANNG', 'stock_data'],
         schedule_interval='@daily'
) as dag:

    dbt_run = BashOperator(
        task_id='dbt_run_base_metrics',
        bash_command='source /home/zhangr235_dev0/dbt-env/bin/activate && ' \
              'cd /home/zhangr235_dev0/FANNG_stock_pipeline/fanng_dbt && '\
             'dbt run --select staging.base_metrics --target dev'

    )
