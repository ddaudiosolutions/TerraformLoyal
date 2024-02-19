terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

#data source para obtener la region
data "aws_region" "current" {}

#data source para id de la cuenta de AWS
data "aws_caller_identity" "current" {}


#data source para obtener el ID de la VPC por defecto
data "aws_vpc" "vpc_default" {
  default = true
}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.access_secret
}

data "aws_subnet" "az_a" {
  vpc_id            = data.aws_vpc.vpc_default.id
  availability_zone = "us-east-1a"
}

data "aws_subnet" "az_b" {
  vpc_id            = data.aws_vpc.vpc_default.id
  availability_zone = "us-east-1b"
}

resource "aws_security_group" "grupo_seguridad_publica" {
  name        = "${var.name}-publica-sg"
  description = "Grupo de seguridad para instancias publicas"
  vpc_id      = data.aws_vpc.vpc_default.id
  ingress {
    cidr_blocks = ["206.204.157.44/32"] #mi ip publica
    description = "Acceso al puerto 22 desde ip"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acceso al puerto 80 desde el exterior"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acceso al puerto 443 desde el exterior"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acceso internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
  tags = local.common_tags

}

#define un grupo de seguridad privada
resource "aws_security_group" "grupo_seguridad_privada" {
  name        = "${var.name}-privada-sg"
  description = "Grupo de seguridad para instancias privadas"
  vpc_id      = data.aws_vpc.vpc_default.id
  ingress {
    security_groups = [aws_security_group.grupo_seguridad_publica.id]
    description     = "Acceso base de datos mysql"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
  }
  ingress {
    security_groups = [aws_security_group.grupo_seguridad_publica.id]
    description     = "Acceso ssh privada"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acceso internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
  tags = local.common_tags

}

resource "aws_db_instance" "mi_base_de_datos" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t2.micro"
  identifier             = "${var.name}-db"
  username               = "admin"
  password               = "123"
  parameter_group_name   = "default.mysql8.0"
  publicly_accessible    = true
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.mi_grupo_seguridad.id]
  tags                   = local.common_tags

}
