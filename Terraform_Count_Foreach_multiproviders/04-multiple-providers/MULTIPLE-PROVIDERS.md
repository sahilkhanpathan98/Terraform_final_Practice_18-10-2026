# Topic 4 – Multiple Providers and Alias

## Simple meaning

Ek Terraform configuration mein same provider ke multiple configurations bana sakte hain. Example: AWS ke resources Mumbai aur Virginia dono regions mein manage karna.

## Flow diagram

```text
                  Terraform
                      |
             +--------+--------+
             |                 |
             v                 v
       Default AWS        Aliased AWS
       provider            provider
       region:             alias:
       ap-south-1          virginia
             |             region:
             |             us-east-1
             v                 v
        Mumbai S3          Virginia S3
          Bucket              Bucket
```

## Provider configuration

```hcl
provider "aws" {
  region = "ap-south-1"
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}
```

- Default provider: jisme alias nahi diya.
- Aliased provider: additional configuration jise unique alias diya.
- `provider = aws.virginia`: resource ko aliased configuration use karne ke liye select karta hai.

## Resource selection

```hcl
resource "aws_s3_bucket" "mumbai" {
  bucket = var.mumbai_bucket_name
}

resource "aws_s3_bucket" "virginia" {
  provider = aws.virginia
  bucket   = var.virginia_bucket_name
}
```

First bucket default provider se Mumbai mein jayega. Second bucket explicitly Virginia provider use karega.

## Before running

1. AWS CLI profile `sahil` configured hona chahiye, ya `terraform.tfvars` mein apna profile name set karo.
2. Dono S3 bucket names globally unique hone chahiye.
3. AWS identity ko S3 bucket create, tag aur delete karne ki permission chahiye.
4. Apply se pehle `terraform plan` carefully check karo.

Create `terraform.tfvars` in this folder:

```hcl
aws_profile          = "sahil"
mumbai_bucket_name   = "your-unique-name-mumbai-12345"
virginia_bucket_name = "your-unique-name-virginia-12345"
```

Names ko apne globally unique names se replace karo.

## Run commands

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform state list
terraform destroy
```

S3 buckets mein objects upload mat karo; destroy se pehle bucket empty hona chahiye.

## Important: different AWS accounts

Different accounts ke liye provider configurations mein alag credentials/profile ya role assume configuration use kar sakte ho. Sirf region alias karne se account change nahi hota.

**Interview answer:** Multiple provider configurations allow one Terraform configuration to manage resources across different regions or accounts. An alias identifies an additional provider configuration, and a resource selects it with the `provider` meta-argument.
