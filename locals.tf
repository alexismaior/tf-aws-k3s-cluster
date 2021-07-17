locals {
  charts = {
    ingress-nginx-controller = {
      repo      = "https://charts.bitnami.com/bitnami"
      chart     = "nginx-ingress-controller"
      namespace = "kube-system"
      values = {
        kind = {
          name  = "kind"
          value = "DaemonSet"
        }
        daemonset = {
          name  = "daemonset.useHostPort"
          value = "true"
        }
        servicetype = {
          name  = "service.type"
          value = "ClusterIP"
        }
      }
    }
    grafana = {
      repo      = "https://grafana.github.io/helm-charts"
      chart     = "grafana"
      namespace = "default"
      values = {
        ingress = {
          name  = "ingress.enabled"
          value = "true"
        }
        hosts = {
          name  = "ingress.hosts[0]"
          value = "${module.loadbalancer.lb_endpoint}"
        }
      }
    }
  }
}
