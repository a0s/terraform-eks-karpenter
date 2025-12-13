variable "env" {
  type = string
}

variable "stack" {
  type = string
}

variable "random_suffix" {
  type = string
}

variable "aws_region" {
  type = string
}

terraform {
  backend "s3" {
    bucket       = "terraform-state-${var.env}-${var.random_suffix}"
    region       = var.aws_region
    key          = "${var.env}/${var.stack}/terraform.tfstate"
    use_lockfile = true
  }
}
