locals {
  ingress_rules = [
    for port in var.allowed_ports : {
      from_port   = port
      to_port     = port
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    }
  ]
}

output "ingress_rules" {
  value = local.ingress_rules
}