# Terraform Dependency — Practical Flow

## 1. Complete Infrastructure Flow

```text
             Terraform main.tf
                    |
                    |
                  VPC
                    |
             Implicit Dependency
                    |
                    v
                  Subnet
                    |
             Implicit Dependency
                    |
                    v
                   EC2
                    |
             Explicit Dependency
                (depends_on)
                    |
                    v
                S3 Bucket
```

## 2. Creation Flow

Jab hum `terraform apply` run karte hain:

```text
1. VPC Create
      |
      v
2. Subnet Create
      |
      v
3. EC2 Create
      |
      v
4. S3 Bucket Create
```

**Reason:**
- Subnet ko VPC ID chahiye.
- EC2 ko Subnet ID chahiye.
- S3 ko `depends_on` ke through EC2 par dependent banaya hai.

## 3. Destruction Flow

Jab hum `terraform destroy` run karte hain:

```text
1. S3 Bucket Destroy
      |
      v
2. EC2 Destroy
      |
      v
3. Subnet Destroy
      |
      v
4. VPC Destroy
```

**Rule:** Creation order ka reverse destruction order hota hai.

## 4. Implicit Dependency

Terraform automatically dependency identify karta hai.

Example:

```hcl
resource "aws_subnet" "demo" {
  vpc_id     = aws_vpc.demo.id
  cidr_block = "10.0.1.0/24"
}
```

Flow:

```text
VPC
 |
 | Reference: aws_vpc.demo.id
 |
 v
Subnet
```

## 5. Explicit Dependency

Hum manually dependency define karte hain.

Example:

```hcl
resource "aws_s3_bucket" "demo" {
  bucket = "my-unique-bucket-name"

  depends_on = [
    aws_instance.demo
  ]
}
```

Flow:

```text
EC2
 |
 | depends_on
 |
 v
S3 Bucket
```

## 6. Important Terraform Commands

```bash
terraform init

terraform validate

terraform plan

terraform graph

terraform apply

terraform destroy
```

### Interview Revision

- Implicit Dependency = Automatic dependency through resource references.
- Explicit Dependency = Manually defined dependency using `depends_on`.
- Creation = Dependency first, dependent resource second.
- Destruction = Dependent resource first, dependency second.
- `terraform graph` = Terraform dependency graph visualize karne ke liye.
