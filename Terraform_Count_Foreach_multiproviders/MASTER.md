# MASTER NOTES – Day 66: Count, For_each & Multiple Providers

## Learning roadmap

```text
Terraform Meta-Arguments
        |
        +---- count
        |       |
        |       +--> Same type ke multiple instances
        |       +--> count.index (0, 1, 2...)
        |
        +---- for_each
        |       |
        |       +--> Set
        |       +--> Map
        |       +--> each.key / each.value
        |
        +---- count vs for_each
        |       |
        |       +--> Index identity vs Key identity
        |
        +---- Multiple Providers
                |
                +--> Default provider
                +--> Alias provider
                +--> Different AWS regions/accounts
```

---

# 1. Count

`count` ka use ek hi resource block se multiple similar resource instances create karne ke liye hota hai.

```hcl
resource "terraform_data" "student" {
  count = 3

  input = "Student-${count.index}"
}
```

### Flow

```text
count = 3
   |
   v
Terraform resource block ko 3 instances mein expand karta hai
   |
   +--> terraform_data.student[0]
   +--> terraform_data.student[1]
   +--> terraform_data.student[2]
```

- `count` number leta hai.
- `count.index` zero se start hota hai.
- Resource address mein index aata hai: `[0]`, `[1]`, `[2]`.

### List variable ke saath

```hcl
variable "names" {
  type    = list(string)
  default = ["Sahil", "Aman", "Ravi"]
}

resource "terraform_data" "person" {
  count = length(var.names)

  input = var.names[count.index]
}
```

`length(var.names)` list ke elements count karta hai.

Practice: `01-count/` folder dekho.

---

# 2. For_each

`for_each` ka use Set ya Map ke har unique element ke liye resource instance banane ke liye hota hai.

## Set example

```hcl
variable "environments" {
  type    = set(string)
  default = ["dev", "test", "prod"]
}

resource "terraform_data" "environment" {
  for_each = var.environments

  input = each.key
}
```

### Flow

```text
Set: {dev, test, prod}
          |
          v
       for_each
          |
   +------+------+------+
   |      |      |      |
  dev   test   prod
   |      |      |
   v      v      v
environment["dev"]
environment["test"]
environment["prod"]
```

Set ke case mein `each.key` aur `each.value` same hote hain.

## Map example

```hcl
variable "instance_types" {
  type = map(string)
  default = {
    dev  = "t3.micro"
    prod = "t3.small"
  }
}

resource "terraform_data" "server" {
  for_each = var.instance_types

  input = "${each.key} - ${each.value}"
}
```

Map mein:
- `each.key` = map ki key, jaise `dev`
- `each.value` = us key ki value, jaise `t3.micro`

Practice: `02-for-each/` folder dekho.

---

# 3. Count vs For_each

| Point | count | for_each |
|---|---|---|
| Input | Number | Set / Map |
| Identity | Numeric index | Key |
| Reference | `resource.name[0]` | `resource.name["dev"]` |
| Best use | Similar numbered instances | Named/keyed instances |

### Count mein index shifting

```text
Initial list: [dev, test, prod]

Index:          0     1     2

Remove "test":

New list:      [dev, prod]

Index:          0     1
```

Ab `prod` index 2 se index 1 par aa gaya. Terraform ko existing index-addressed instances ke values mein changes dikh sakte hain. Resource aur changed attributes ke hisaab se update ya replacement ho sakta hai.

### For_each mein stable keys

```text
Initial keys: dev, test, prod

Remove "test":

Remaining keys:
  dev
  prod

Only "test" key wala instance remove hota hai;
dev aur prod ki key identity same rehti hai.
```

Practice: `03-count-vs-for-each/` mein example aur explanation dekho.

---

# 4. Multiple Providers

Ek Terraform configuration mein multiple provider configurations use kar sakte ho.

Example:
- Default AWS provider → Mumbai (`ap-south-1`)
- Aliased AWS provider → Virginia (`us-east-1`)

### Flow

```text
                 Terraform Configuration
                          |
                 +--------+--------+
                 |                 |
                 v                 v
          Default Provider   Aliased Provider
          provider "aws"     provider "aws"
          ap-south-1         us-east-1
                 |                 |
                 v                 v
          Mumbai S3 Bucket   Virginia S3 Bucket
```

Provider alias:

```hcl
provider "aws" {
  region = "ap-south-1"
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}
```

Aliased provider ko resource mein select karna:

```hcl
resource "aws_s3_bucket" "virginia" {
  provider = aws.virginia
  bucket   = "your-globally-unique-bucket-name"
}
```

- Jis provider mein `alias` nahi hota, woh default provider hota hai.
- `alias` additional provider configuration ko identify karta hai.
- `provider = aws.virginia` resource ko Virginia provider use karne ko kehta hai.
- Different AWS accounts ke liye alag credentials/profile bhi configure kiye ja sakte hain.

Practice: `04-multiple-providers/` folder dekho.

---

# 5. Practice commands

Har subfolder ke andar terminal open karke:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform state list
terraform destroy
```

`terraform apply` se pehle plan dhyan se check karo.

## Multiple-provider folder ke liye extra setup

`04-multiple-providers/terraform.tfvars` file banao:

```hcl
aws_profile       = "sahil"
mumbai_bucket_name  = "replace-with-your-unique-mumbai-bucket-name"
virginia_bucket_name = "replace-with-your-unique-virginia-bucket-name"
```

Bucket names:
- globally unique hone chahiye
- lowercase letters, numbers aur hyphens use karo
- dono names alag hone chahiye
- placeholder names ko apne unique names se replace karo

## Interview quick revision

1. **What is count?** `count` creates multiple instances of a resource using a numeric value.
2. **What is count.index?** It identifies the current instance with a zero-based index.
3. **What is for_each?** It creates one instance for each element in a Set or Map.
4. **What are each.key and each.value?** They represent the current key and value in a `for_each` iteration.
5. **Count vs for_each?** `count` uses numeric indexes; `for_each` uses stable keys.
6. **What is a provider alias?** It identifies an additional provider configuration, such as another AWS region.

## Recommended practice order

1. `01-count/COUNT.md`
2. Run the count example.
3. `02-for-each/FOR_EACH.md`
4. Run Set and Map examples.
5. `03-count-vs-for-each/COUNT-VS-FOR_EACH.md`
6. `04-multiple-providers/MULTIPLE-PROVIDERS.md`
7. Run the AWS example only after configuring unique bucket names and credentials.
