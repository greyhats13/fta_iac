terraform {
  backend "gcs" {
    bucket = "fta-mstr-gcs-tfstate"
    prefix = "fta/cloud/deployment"
  }
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

# Configure the Google Cloud provider for Terraform
provider "google" {
  project = "${var.unit}-platform"
  region  = var.region
}

provider "google-beta" {
  alias   = "beta"
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

provider "kubectl" {
  config_path = "~/.kube/config"
}
