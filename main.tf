module "networking" {
  source           = "app.terraform.io/alexismaior/networking/aws"
  version          = "1.0.3"
  vpc_cidr         = var.vpc_cidr
  public_cidrs     = var.public_cidrs
  private_cidrs    = var.private_cidrs
  public_sn_count  = var.public_sn_count
  private_sn_count = var.private_sn_count
  access_ip        = var.access_ip
  aws_region       = var.aws_region
  db_subnet_group  = var.db_subnet_group

}

module "loadbalancer" {
  source                = "app.terraform.io/alexismaior/loadbalancer/aws"
  version               = "1.0.0"
  aws_region            = var.aws_region
  public_sg             = [module.networking.public_sg]
  public_subnets        = module.networking.public_subnets
  target_port           = var.target_port
  target_protocol       = var.target_protocol
  vpc_id                = module.networking.vpc_id
  lb_healty_threshold   = var.lb_healty_threshold
  lb_unhealty_threshold = var.lb_unhealty_threshold
  lb_timeout            = var.lb_timeout
  lb_interval           = var.lb_interval
  listener_port         = var.listener_port
  listener_protocol     = var.listener_protocol
}

module "database" {
  source                 = "app.terraform.io/alexismaior/rds-mysql/aws"
  version                = "1.0.0"
  aws_region             = var.aws_region
  db_storage             = var.db_storage
  db_engine_version      = var.db_engine_version
  db_instance_class      = var.db_instance_class
  dbname                 = var.dbname
  dbuser                 = var.dbuser
  dbpassword             = var.dbpassword
  db_subnet_group_name   = module.networking.db_subnet_group_name[0]
  vpc_security_group_ids = [module.networking.db_security_group]
  db_identifier          = var.db_identifier
  skip_final_snapshot    = var.skip_final_snapshot
}

module "k3s-cluster" {
  source                        = "app.terraform.io/alexismaior/k3s/aws"
  version                       = "1.0.1"
  aws_region                    = var.aws_region
  instance_count                = var.instance_count
  instance_type                 = var.instance_type
  public_sg                     = [module.networking.public_sg]
  public_subnets                = module.networking.public_subnets
  vol_size                      = var.vol_size
  key_name                      = var.key_name
  public_key                    = var.public_key
  user_data_path                = var.user_data_path
  dbuser                        = var.dbuser
  dbpassword                    = var.dbpassword
  dbendpoint                    = module.database.dbendpoint
  dbname                        = var.dbname
  enable_lb_tg_group_attachment = var.enable_lb_tg_group_attachment
  lb_target_group_arn           = module.loadbalancer.lb_target_group_arn
  tg_port                       = var.tg_port
}

resource "local_file" "deploy_ssh_key" {
  filename = "/tmp/id_rsa"
  content  = var.private_key
  file_permission = 600
}

resource "null_resource" "kubeconfig" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = module.k3s-cluster.instance[0].public_ip
      private_key = var.private_key
    }
    inline = ["echo 'hello'"]
  }
  provisioner "local-exec" {
    command = templatefile("${path.cwd}/files/scp_script.tpl",
      {
        nodeip           = module.k3s-cluster.instance[0].public_ip
        k3s_path         = "${path.cwd}"
        nodename         = module.k3s-cluster.instance[0].tags.Name
      }
    )
  }
}

data "local_file" "kubeconfig" {
    filename = "${path.cwd}/files/k3s-${module.k3s-cluster.instance[0].tags.Name}.yaml"
}

resource "local_file" "kubeconfig" {
  filename = "./kubeconfig"
  content  = data.local_file.kubeconfig.content
}
resource "helm_release" "applications" {
  depends_on = [module.k3s-cluster, null_resource.kubeconfig]

  for_each = local.charts

  name = each.key

  repository = each.value.repo
  chart      = each.value.chart
  namespace  = each.value.namespace

  dynamic "set" {
    for_each = each.value.values
    content {
      name  = set.value.name
      value = set.value.value
    }
  }
}
