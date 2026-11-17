# Day 65 – Terraform Data Sources: Practical Project

## Project: Launch EC2 in an Existing VPC and Subnet

### Objective

AWS mein pehle se existing VPC aur Subnet ki information Terraform Data Sources se fetch karni hai. Uske baad fetched VPC ID aur Subnet ID use karke ek naya Security Group aur EC2 instance create karna hai.

**Existing resources ko dobara create nahi karna hai.**

### Architecture

```text
                    AWS ACCOUNT
                         |
              Existing infrastructure
                         |
                 +-------+-------+
                 |               |
               VPC             Subnet
                 |               |
                 +-------+-------+
                         |
                  Terraform Data
                     Sources
                         |
              Fetch VPC / Subnet IDs
                         |
              +----------+----------+
              |                     |
       New Security Group       New EC2
              |                     |
              +----------+----------+
                         |
              EC2 in existing subnet
```

## 1. Prerequisites

AWS region: `ap-south-1`

AWS CLI profile: `sahil`

AWS mein pehle se ye resources hone chahiye:

| Resource | Expected Name |
|---|---|
| VPC | `dev-vpc` |
| Subnet | `dev-subnet` |
| EC2 Key Pair | Apna existing key pair |

VPC aur Subnet par ye tags hone chahiye:

- VPC: `Name = dev-vpc`
- Subnet: `Name = dev-subnet`

Subnet selected VPC ke andar hona chahiye. Agar EC2 ko internet access chahiye, toh subnet ki route table mein Internet Gateway route configured hona chahiye.

### Important

- `key_name` mein AWS ke existing EC2 Key Pair ka exact naam do.
- `my_ip` mein apna public IP `/32` ke saath do, jaise `203.0.113.10/32`. Example IP ko apne actual public IP se replace karna.
- SSH inbound rule sirf tumhare IP ko allow karega.
- `t3.micro` availability aur account limits region ke hisaab se verify karna.

## 2. Folder Structure

```text
Terraform-Data-Source-Practice/
│
├── provider.tf
├── data.tf
├── variables.tf
├── terraform.tfvars
├── main.tf
├── outputs.tf
└── README.md
```

## 3. provider.tf

AWS provider configure karta hai.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "ap-south-1"
  profile = "sahil"
}
```

Agar tumhara AWS CLI profile `sahil` nahi hai, toh apne profile ka naam use karo ya `profile` line remove karke apni configured credentials use karo.

## 4. data.tf

### A. Existing VPC fetch karna

```hcl
data "aws_vpc" "existing" {
  filter {
    name   = "tag:Name"
    values = ["dev-vpc"]
  }
}
```

### B. Existing Subnet fetch karna

```hcl
data "aws_subnet" "existing" {
  filter {
    name   = "tag:Name"
    values = ["dev-subnet"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
}
```

Subnet ke liye do conditions check hoti hain:

1. Subnet ka Name tag `dev-subnet` hona chahiye.
2. Subnet fetched VPC ke andar hona chahiye.

### C. Amazon Linux 2023 AMI fetch karna

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
```

Ye matching Amazon-owned Amazon Linux 2023 AMI mein se latest AMI select karta hai.

## 5. variables.tf

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
}

variable "my_ip" {
  description = "Your public IP address in CIDR notation, for example 203.0.113.10/32"
  type        = string
}
```

## 6. terraform.tfvars

Apni actual values enter karo:

```hcl
instance_type = "t3.micro"

key_name = "YOUR_EXISTING_KEY_PAIR_NAME"

my_ip = "YOUR_PUBLIC_IP/32"
```

`YOUR_EXISTING_KEY_PAIR_NAME` aur `YOUR_PUBLIC_IP/32` ko apni actual values se replace karo.

**Security:** `terraform.tfvars` mein real secrets ya private keys mat rakho. Is file ko Git mein commit karne se pehle `.gitignore` check karo.

## 7. main.tf

### A. New Security Group

```hcl
resource "aws_security_group" "dev_sg" {
  name        = "data-source-sg"
  description = "Security group for Data Source EC2"
  vpc_id      = data.aws_vpc.existing.id

  ingress {
    description = "SSH access from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "data-source-sg"
  }
}
```

### B. New EC2 Instance

```hcl
resource "aws_instance" "dev" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = data.aws_subnet.existing.id
  vpc_security_group_ids      = [aws_security_group.dev_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "Data-Source-EC2"
  }
}
```

## 8. outputs.tf

```hcl
output "vpc_id" {
  description = "ID of the existing VPC"
  value       = data.aws_vpc.existing.id
}

output "subnet_id" {
  description = "ID of the existing subnet"
  value       = data.aws_subnet.existing.id
}

output "ami_id" {
  description = "Selected Amazon Linux AMI ID"
  value       = data.aws_ami.amazon_linux.id
}

output "ec2_public_ip" {
  description = "Public IP of the new EC2 instance"
  value       = aws_instance.dev.public_ip
}

output "ec2_private_ip" {
  description = "Private IP of the new EC2 instance"
  value       = aws_instance.dev.private_ip
}
```

## 9. Execution Commands

Terminal mein project folder open karke commands run karo:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

`terraform apply` par plan review karo. Sab correct ho tabhi `yes` enter karo.

Outputs dekhne ke liye:

```bash
terraform output
```

## 10. Expected Terraform Changes

Expected plan mein normally ye do managed resources create honge:

| Resource | Action |
|---|---|
| `aws_security_group.dev_sg` | Create |
| `aws_instance.dev` | Create |
| Existing VPC Data Source | Read |
| Existing Subnet Data Source | Read |
| AMI Data Source | Read |

Exact plan provider aur AWS account ki current condition par depend karega.

## 11. Verification in AWS Console

Apply successful hone ke baad verify karo:

1. VPC Console: existing `dev-vpc` use hua hai.
2. Subnet Console: existing `dev-subnet` use hua hai.
3. EC2 Console: `Data-Source-EC2` instance create hua hai.
4. Security Groups: `data-source-sg` create hua hai.

## 12. Cleanup

Practice complete hone ke baad:

```bash
terraform destroy
```

Plan carefully review karo aur confirm karne ke liye `yes` tabhi enter karo jab resources sahi hon.

`terraform destroy` is configuration ke managed EC2 aur Security Group ko delete karega. Data Sources se read kiye gaye existing VPC, Subnet aur AMI ko delete nahi karega.

## 13. Important Concepts

| Expression | Meaning |
|---|---|
| `data.aws_vpc.existing.id` | Existing VPC ki ID |
| `data.aws_subnet.existing.id` | Existing Subnet ki ID |
| `data.aws_ami.amazon_linux.id` | Selected AMI ki ID |
| `aws_security_group.dev_sg.id` | Is project mein create hua Security Group ID |

**Syntax:**

```hcl
data.<data_source_type>.<local_name>.<attribute>
```

Example:

```hcl
data.aws_subnet.existing.id
```

## 14. Import vs Data Source

| Import | Data Source |
|---|---|
| Existing resource ko Terraform management mein lane ke liye | Existing resource ki information read karne ke liye |
| Managed resource state entry banata hai | Data resource state entry record karta hai |
| Resource configuration manage karni hoti hai | Existing resource ko is configuration se manage nahi karta |
| `terraform import` ya `import` block | `data` block |

## 15. Interview Questions

1. What is a Data Source in Terraform?
2. How do you fetch an existing VPC ID?
3. How do you fetch an existing subnet ID?
4. Can Data Source attributes be used inside a resource block?
5. What is the difference between `data.aws_subnet.existing.id` and `aws_subnet.example.id`?
6. Does a Data Source create an AWS resource?
7. What happens if a Data Source cannot find a matching subnet?
8. What is the difference between Import and Data Source?

### Interview Answer

A Data Source in Terraform is used to retrieve information about existing infrastructure resources without managing those resources. For example, we can fetch an existing AWS subnet ID using the `aws_subnet` Data Source and use that ID while creating a new EC2 instance.

## 16. Practice Assignment

- [ ] Fetch an existing VPC using a Data Source.
- [ ] Fetch a subnet belonging to that VPC.
- [ ] Fetch the latest matching Amazon Linux 2023 AMI.
- [ ] Create a new Security Group in the existing VPC.
- [ ] Create a new EC2 instance in the existing subnet.
- [ ] Display VPC ID, Subnet ID, AMI ID and EC2 IPs using outputs.
- [ ] Destroy only the resources created by this project.

---

**Revision Flow:**

`Existing AWS Resource → Data Source → Fetch Attributes → Use in New Resource`
