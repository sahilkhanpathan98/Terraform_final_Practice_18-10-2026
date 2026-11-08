# Terraform Modules – EC2 and S3 in One Source Module vs Separate Modules

## Doubt

The source directory's `main.tf` contains both EC2 and S3 resources, but I want to create only EC2 from the execution directory. How can I do that?

## 1. If EC2 and S3 are in the same module

Example:

```text
Terraform-Project/
├── Source-Directory/
│   ├── main.tf
│   └── variables.tf
└── Execution-Directory/
    └── main.tf
```

`Source-Directory/main.tf`:

```hcl
resource "aws_instance" "ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "module-ec2"
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}
```

`Source-Directory/variables.tf`:

```hcl
variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "bucket_name" {
  type = string
}
```

`Execution-Directory/main.tf`:

```hcl
module "app" {
  source = "../Source-Directory"

  ami_id        = "ami-xxxxxxxxxxxxxxxxx"
  instance_type = "t2.micro"
  bucket_name   = "replace-with-a-globally-unique-bucket-name"
}
```

**Result:** Calling this module includes both resource blocks. Terraform plans/manages both EC2 and S3. The module name `app` does not select an individual resource.

## 2. Recommended approach: create separate modules

Use this structure when you want to choose EC2 and S3 independently:

```text
Terraform-Project/
├── Modules/
│   ├── EC2/
│   │   ├── main.tf
│   │   └── variables.tf
│   └── S3/
│       ├── main.tf
│       └── variables.tf
└── Execution-Directory/
    └── main.tf
```

`Modules/EC2/main.tf`:

```hcl
resource "aws_instance" "ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "module-ec2"
  }
}
```

`Modules/EC2/variables.tf`:

```hcl
variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}
```

`Modules/S3/main.tf`:

```hcl
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}
```

`Modules/S3/variables.tf`:

```hcl
variable "bucket_name" {
  type = string
}
```

### Execution directory – call only EC2

`Execution-Directory/main.tf`:

```hcl
module "ec2" {
  source = "../Modules/EC2"

  ami_id        = "ami-xxxxxxxxxxxxxxxxx"
  instance_type = "t2.micro"
}
```

This calls only the EC2 module. The S3 module is not called, so its resources are not part of this root configuration.

### Execution directory – call both EC2 and S3

```hcl
module "ec2" {
  source = "../Modules/EC2"

  ami_id        = "ami-xxxxxxxxxxxxxxxxx"
  instance_type = "t2.micro"
}

module "s3" {
  source = "../Modules/S3"

  bucket_name = "replace-with-a-globally-unique-bucket-name"
}
```

## 3. Important points

- `module` tells Terraform that a module block is being declared.
- `"ec2"` or `"app"` is the local name of the module call. It is not required to match the folder name.
- `source` tells Terraform where the module code is located.
- Terraform processes all applicable `.tf` files in the selected module directory.
- Terraform does not automatically select only the EC2 resource based on the module block name.
- Separate modules are the clean approach when EC2 and S3 need to be called independently.

## Interview answer

A module call executes the configuration in the selected module directory. If that module contains both EC2 and S3 resource blocks, both are included in the root configuration. To manage them independently, I create separate EC2 and S3 modules and call only the module I need.
