locals {
  common_tags = {
    Environment = "Dev"
    Project     = "Applicacion"
    Terraform   = "true"
  }
}

variable "access_key" {
  type    = string
  default = "AKIATIU7QUNFKU6JALWA"
}

variable "access_secret" {
  type    = string
  default = "H8jpPQ7JZSWj2T5yFvJnXMB7ehbdNa+AIU2PKo2b"
}

variable "name" {
  type    = string
  default = "server"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "region" {
  type    = string
  default = "us-east-1"

}

variable "imagen" {
  type    = string
  default = "ami-0cf10cdf9fcd62d37"
}

variable "tipo_instancia" {
  type    = string
  default = "t2.micro"
}

variable "key_name" {
  type    = string
  default = "servidor-ppk"
}
