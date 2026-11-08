module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.12.0"

  identifier = "registry-rds-mysql"

  engine         = "mysql"
  instance_class = "db.t3.micro"

  allocated_storage = 20

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = "3306"

  create_db_subnet_group = true

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false
}