terraform {
  required_version = ">= 1.5.0"
}

resource "terraform_data" "student" {
  count = 3

  input = "Student-${count.index}"
}

resource "terraform_data" "person" {
  count = length(var.names)

  input = var.names[count.index]
}
