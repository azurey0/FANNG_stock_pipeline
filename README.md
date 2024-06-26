# FANNG Stock Metrics Pipeline Project

## Overview and Problem Statement

This project is dedicated to the comprehensive analysis and visualization of FANNG (Facebook, Amazon, Apple, Netflix, Google) stock data, leveraging a robust data pipeline to process extensive historical stock data sourced from [Kaggle](https://www.kaggle.com/datasets/aayushmishra1512/faang-complete-stock-data). 
The project encompasses the ingestion of third-party data, applying initial processing using Apache Spark to load data into a data lake, followed by detailed transformation and calculation steps orchestrated via Apache Airflow and dbt. These steps ensure data sanity and accuracy in metric calculations, such as MACD and EMA20. 
The ultimate goal is to provide a dynamic dashboard that presents these key financial metrics, offering actionable insights into stock performance trends and aiding in informed investment decisions.
## Technologies Used

- **Cloud**: Google Cloud Platform (GCP)
- **Data Ingestion**: Apache Spark
- **Data Lake Storage**: Google Cloud Storage (GCS)
- **Data Warehousing**: BigQuery
- **ETL/ELT Process**: dbt (data build tool)
- **Workflow Orchestration**: Apache Airflow
- **Analytics and Visualization**: Looker
- **Programming Languages**: SQL, Python
- **Version Control**: Git

## Data Pipeline Diagram

![Data Pipeline Diagram](https://github.com/azurey0/FANNG_stock_pipeline/blob/master/diagram.gif)

This diagram illustrates the flow of data from source to visualization, showcasing how each technology is utilized within the pipeline.

## Prerequisites

Before you begin setting up this project, ensure you have the following:

- A Google Cloud account with billing enabled.
- Access to Google Cloud services like BigQuery and Google Cloud Storage.
- Apache Spark and Apache Airflow installed either locally or in a cloud environment.
- Looker or another compatible visualization tool set up to connect to your BigQuery datasets.

## Project Build & Setup

Follow [Setup.md](https://github.com/azurey0/FANNG_stock_pipeline/blob/master/Setup.md) 

## Dashboard 
Here is the [link](https://lookerstudio.google.com/reporting/9ee0fe34-e134-4723-8209-45bcb436c026/page/0ojwD).
![Example view](https://github.com/azurey0/FANNG_stock_pipeline/blob/master/dashboard.png)

## Testing
Tests are added to dbt models.
To further improvements, Airflow tests should be added. Also CI/CD process should be added.
