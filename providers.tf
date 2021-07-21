provider "helm" {
  kubernetes {
    config_paths = flatten(fileset(path.module, "./files/k3s-*.yaml"))
    insecure     = true
  }
}
terraform {
  backend "remote" {
    organization = "alexismaior"

    workspaces {
      name = "k3s-production-us-east-1"
    }
  }
}
