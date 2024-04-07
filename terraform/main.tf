terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.6.0"
    }
  }
}

provider "google" {
  #credentials = file(var.credentials) No need if configured using gcloud auth activate-service-account
  project     = var.project
  region      = var.region
}

// GCS Bucket for Data Lake
resource "google_storage_bucket" "data_lake" {
  name          = var.gcs_bucket_name
  location      = var.location
  force_destroy = true


  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

// BigQuery Dataset(Data Warehouse)
resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = var.bq_dataset_name
  location                    = var.location
  delete_contents_on_destroy  = false
}