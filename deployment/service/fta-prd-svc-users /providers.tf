
terraform {
  backend "gcs" {
    bucket = "fta-mstr-gcs-tfstate"
    prefix = "fta/service/deployment/fta-prd-svc-users"
  }
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# Configure the Google Cloud provider for Terraform
provider "google" {
  project = "${var.unit}-platform"
  region  = var.region
}

# Configure the Google Cloud provider for Terraform
provider "google-beta" {
  project = "${var.unit}-platform"
  region  = var.region
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

# create helm provider
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}