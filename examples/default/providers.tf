terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.42.0"
    }
  }
}

provider "google" {
  # Configuration options
  project = "1234567890"
  region  = "us-central1"
}

