variable "project" {
  type    = string
  default = "insat-devops-project"
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
