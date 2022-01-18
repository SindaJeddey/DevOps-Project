variable "project" {
  type    = string
  default = "devops"
}
variable "name" {
  type    = string
  default = "insat-devops-project"
}
variable "environment" {
  type    = string
  default = "dev"
}
variable "region" {
  type    = string
  default = "eu-west-3"
}

variable "backend_container_image" {
  type    = string
  default = "sindajeddey/backend-devops"
}
variable "prometheus_container_image" {
  type    = string
  default = "sindajeddey/prometheus"
}
variable "grafana_container_image" {
  type    = string
  default = "grafana/grafana:latest"
}
