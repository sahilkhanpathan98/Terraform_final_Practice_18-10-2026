# Topic 1 – Count Meta-Argument

## Simple meaning

`count` ka matlab: ek resource block se same type ke multiple instances banana.

## Example

```hcl
resource "terraform_data" "student" {
  count = 3
  input = "Student-${count.index}"
}
```

## Flow diagram

```text
             count = 3
                 |
                 v
          Terraform evaluate
                 |
       +---------+---------+
       |         |         |
       v         v         v
      [0]       [1]       [2]
       |         |         |
       v         v         v
   Student-0 Student-1 Student-2
```

## Important points

- `count` ek number accept karta hai.
- `count.index` zero-based hota hai.
- Terraform state addresses: `terraform_data.student[0]`, `[1]`, `[2]`.
- List variable ke saath `length(var.names)` use karke instance count calculate kar sakte hain.

## List variable flow

```text
var.names = ["Sahil", "Aman", "Ravi"]
                    |
                    v
             length(var.names)
                    |
                    v
                 count = 3
                    |
                    v
             count.index se item select
                    |
          +---------+---------+
          |         |         |
        names[0]  names[1]  names[2]
          |         |         |
        Sahil      Aman      Ravi
```

## Practice

1. `count = 3` ko `count = 4` karo.
2. `names` list mein ek aur naam add karo.
3. `terraform plan` run karke changes dekho.
4. `terraform state list` se resource addresses dekho.

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

**Interview answer:** The `count` meta-argument creates multiple instances of a resource using a numeric value, and `count.index` identifies each instance starting from zero.
