terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.72.0"
    }
  }

  backend "s3" {
    bucket = "sindajeddey"
    key    = "terraform.tfstate"
    region = "eu-west-3"
    #    profile = "sandbox"
  }
}

provider "aws" {
  region = "eu-west-3"
  #  profile = "sandbox"
}


module "vpc" {
  source                               = "terraform-aws-modules/vpc/aws"
  # The rest of arguments are omitted for brevity
  enable_nat_gateway                   = true
  single_nat_gateway                   = true
  one_nat_gateway_per_az               = false
  #  Skip creation of EIPs for the NAT Gateways
  reuse_nat_ips                        = true
  #  IPs specified here as input to the module
  external_nat_ip_ids                  = "${aws_eip.nat.*.id}"
  name                                 = var.name
  cidr                                 = "10.0.0.0/26"
  # 10.0.0.0/8 is reserved for EC2-Classic
  azs                                  = [
    "${var.region}a"
  ]
  private_subnets                      = [
    "10.0.0.0/27"
  ]
  public_subnets                       = [
    "10.0.0.32/28"
  ]
  enable_dhcp_options                  = true
  enable_dns_hostnames                 = true
  enable_dns_support                   = true
  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60
}
resource "aws_eip" "nat" {
  vpc = true
}
resource "aws_ecs_cluster" "main" {
  name = "${var.name}-cluster-${var.environment}"
}
module "roles" {
  source = "./modules/roles"
}
resource "aws_service_discovery_private_dns_namespace" "namespace" {
  name = var.project
  vpc  = module.vpc.vpc_id
}

module "backend_service" {
  source                      = "./modules/service"
  name                        = "backend"
  cluster_id                  = aws_ecs_cluster.main.id
  container_image             = "${var.backend_container_image}:${var.environment}"
  ecs_task_execution_role_arn = module.roles.ecs_task_execution_role
  ecs_task_role_arn           = module.roles.ecs_task_role
  namespace_id                = aws_service_discovery_private_dns_namespace.namespace.id
  port                        = 5000
  subnets                     = module.vpc.public_subnets
  vpc_id                      = module.vpc.vpc_id
}
module "grafana_service" {
  source                      = "./modules/service"
  name                        = "grafana"
  cluster_id                  = aws_ecs_cluster.main.id
  container_image             = "${var.grafana_container_image}"
  ecs_task_execution_role_arn = module.roles.ecs_task_execution_role
  ecs_task_role_arn           = module.roles.ecs_task_role
  namespace_id                = aws_service_discovery_private_dns_namespace.namespace.id
  port                        = 3000
  subnets                     = module.vpc.public_subnets
  vpc_id                      = module.vpc.vpc_id
}

module "prometheus_service" {
  source          = "./modules/service"
  name            = "prometheus"
  cluster_id      = aws_ecs_cluster.main.id
  container_image = "${var.prometheus_container_image}:${var.environment}"

  ecs_task_execution_role_arn = module.roles.ecs_task_execution_role
  ecs_task_role_arn           = module.roles.ecs_task_role
  namespace_id                = aws_service_discovery_private_dns_namespace.namespace.id
  port                        = 9090
  subnets                     = module.vpc.public_subnets
  vpc_id                      = module.vpc.vpc_id
}
