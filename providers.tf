provider "helm" {
  kubernetes {
    config_paths = flatten(fileset(path.module, "./files/k3s-node-*.yaml"))
    insecure     = true
  }
}
