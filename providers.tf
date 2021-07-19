provider "helm" {
  kubernetes {
    config_path = "./kubeconfig"
    insecure     = true
  }
}
