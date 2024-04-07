

variable "project" {
  description = "Project"
  default     = "decapstone-419603"
}

variable "region" {
  description = "Region"
  #Update the below to your desired region
  default     = "us-west4-b"
}

variable "location" {
  description = "Project Location"
  #Update the below to your desired location
  default     = "US"
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  #Update the below to a unique bucket name
  default     = "fanng_stock_datalake"
}

variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  #Update the below to what you want your dataset to be called
  default     = "fanng_stock_dataset"
}