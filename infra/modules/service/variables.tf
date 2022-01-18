variable "ecs_task_execution_role_arn" {
  type = string
}
variable "ecs_task_role_arn" {
  type = string
}
variable "name" {
  type = string
}
variable "environment" {
  type    = string
  default = "dev"
}
variable "container_image" {
  type = string
}
variable "port" {
  type = number
}
variable "namespace_id" {
  type = string
}
variable "cluster_id" {
  type = string
}
variable "subnets" {
  type = list(string)
}
variable "public_ip" {
  type    = bool
  default = true
}
variable "vpc_id" {
  type = string
}
