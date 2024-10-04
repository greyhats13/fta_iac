
terraform {
  backend "gcs" {
    bucket = "fta-mstr-gcs-tfstate"
    prefix = "fta/service/deployment/fta-dev-svc-gce"
  }
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