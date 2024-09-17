terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    kubectl = {
      source  = "alon-dotan-starkware/kubectl"
      version = "1.11.2"
    }
  }
}

# Configure the Google Cloud provider for Terraform
provider "google" {
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
