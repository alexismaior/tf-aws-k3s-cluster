#-- Common variables --
variable "aws_region" {}

#-- Networking variables --
variable "access_ip" {}
variable "vpc_cidr" {}
variable "public_cidrs" {}
variable "private_cidrs" {}
variable "public_sn_count" {}
variable "private_sn_count" {}
variable "db_subnet_group" {}

#-- Load Balancer variables --
variable "target_port" {}
variable "target_protocol" {}
variable "lb_healty_threshold" {}
variable "lb_unhealty_threshold" {}
variable "lb_timeout" {}
variable "lb_interval" {}
variable "listener_port" {}
variable "listener_protocol" {}

#-- Database variables --
variable "db_storage" {}
variable "db_engine_version" {}
variable "db_instance_class" {}
variable "dbname" {}
variable "dbuser" {}
variable "dbpassword" {}
variable "db_identifier" {}
variable "skip_final_snapshot" {}

#-- k3s cluster variables --
variable "instance_count" {}
variable "instance_type" {}
variable "vol_size" {}
variable "key_name" {}
variable "public_key" {}
variable "private_key" {}
variable "user_data_path" {}
variable "enable_lb_tg_group_attachment" {}
variable "tg_port" {}
