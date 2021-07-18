output "nodes" {
  value = module.k3s-cluster.instance[*].public_dns
}

output "loadbalancer" {
  value = module.loadbalancer.lb_endpoint
}

output "kubeconfig" {
  value = data.local_file.kubeconfig
}
