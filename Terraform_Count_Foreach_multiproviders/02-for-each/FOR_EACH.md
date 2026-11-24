# Topic 2 – For_each Meta-Argument

## Simple meaning

`for_each` Set ya Map ke har element/key ke liye alag resource instance banata hai.

## A. Set example

```hcl
variable "environments" {
  type    = set(string)
  default = ["dev", "test", "prod"]
}

resource "terraform_data" "environment" {
  for_each = var.environments
  input    = each.key
}
```

### Flow

```text
       Set: dev, test, prod
                 |
                 v
              for_each
                 |
       +---------+---------+
       |         |         |
       v         v         v
      dev       test      prod
       |         |         |
       v         v         v
 environment["dev"]
 environment["test"]
 environment["prod"]
```

Set mein `each.key` aur `each.value` dono current element ko represent karte hain.

## B. Map example

```hcl
variable "instance_types" {
  type = map(string)
  default = {
    dev  = "t3.micro"
    prod = "t3.small"
  }
}

resource "terraform_data" "server_type" {
  for_each = var.instance_types
  input    = "${each.key} - ${each.value}"
}
```

### Flow

```text
       Map
   +------------------+
   | dev  = t3.micro  |
   | prod = t3.small  |
   +------------------+
            |
            v
         for_each
            |
      +-----+------+
      |            |
      v            v
  each.key=dev  each.key=prod
  each.value=   each.value=
  t3.micro      t3.small
```

## Key concepts

- `each.key` = current key
- `each.value` = current value
- Set of strings mein key aur value same hote hain.
- Map mein key aur value alag ho sakte hain.
- `for_each` ke liye Set ya Map use karo; normal list ko directly dene ke bajaye suitable case mein `toset()` convert kar sakte ho.

## Practice

1. Set mein `stage` add karo.
2. Map mein `stage = "t3.small"` add karo.
3. `terraform plan` run karo.
4. `terraform state list` mein keyed addresses dekho.

## Commands

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform state list
terraform destroy
```

**Interview answer:** The `for_each` meta-argument creates one resource instance for each element in a map or set, using `each.key` and `each.value` to access the current element.
