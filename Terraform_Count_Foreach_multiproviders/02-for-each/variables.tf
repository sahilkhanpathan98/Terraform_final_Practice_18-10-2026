variable "environments" {
  description = "Set of environment names"
  type        = set(string)
  default     = ["dev", "test", "prod"]
}

variable "instance_types" {
  description = "Map of environment names to example instance types"
  type        = map(string)
  default = {
    dev  = "t3.micro"
    prod = "t3.small"
  }
}
