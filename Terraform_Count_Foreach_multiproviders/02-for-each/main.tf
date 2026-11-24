terraform {
  required_version = ">= 1.5.0"
}

resource "terraform_data" "environment" {
  for_each = var.environments

  input = each.key
}

resource "terraform_data" "server_type" {
  for_each = var.instance_types

  input = "${each.key} - ${each.value}"
}
