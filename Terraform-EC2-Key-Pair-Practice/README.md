# Terraform EC2 Key Pair Practice – Complete Guide

Is repository mein hum seekhenge ki **Terraform ke through EC2 instance ke saath SSH Key Pair kaise use karte hain**.

Is project ko 3 alag scenarios mein divide kiya gaya hai. Har scenario ka apna folder, Terraform configuration files aur detailed README guide hai.

---

## 1. Sabse pehle SSH Key Pair samjho

SSH ka full form **Secure Shell** hai. SSH ki help se hum apne laptop/terminal se remote Linux EC2 instance mein securely login kar sakte hain.

SSH Key Pair mein 2 related keys hoti hain:

| Key | Kahan rehti hai? | Kaam |
|---|---|---|
| Public Key | AWS ke EC2 Key Pair record mein | EC2 par login ko verify karne ke liye |
| Private Key | Aapke laptop par | SSH login ke waqt apni identity prove karne ke liye |

**Simple example:** Public Key ko AWS/EC2 mein register karte hain. Uski matching Private Key apne paas safe rakhte hain. Login karte waqt SSH client Private Key use karta hai; EC2 uska matching public key se verification karta hai.

> Private Key kabhi AWS par upload nahi karni aur kisi ke saath share nahi karni.

## 2. Complete SSH Login Flow

```text
                 YOUR LAPTOP
                      |
               SSH Key Pair
                /         \
               /           \
        Public Key       Private Key
            |                 |
            |                 | stays on laptop
            v                 |
       Terraform               |
            |                 |
            v                 |
       AWS Key Pair            |
       registration            |
            |                 |
            v                 |
        EC2 Instance           |
            |                 |
            +--------+--------+
                     |
              SSH authentication
                     |
                     v
                EC2 Login
```

AWS par Key Pair register karna aur EC2 ke saath us Key Pair ko select karna do alag steps hain:
1. Public Key ko AWS mein register karna.
2. EC2 create karte waqt us Key Pair ka naam `key_name` mein dena.

---

## 3. Is project mein 3 scenarios hain

| Folder | Aapki starting situation | Terraform kya karega? |
|---|---|---|
| `01-Register-My-Laptop-Public-Key-In-AWS` | Laptop par SSH key pair pehle se hai | Local public key read karke AWS mein register karega |
| `02-Use-An-Existing-AWS-Key-Pair-With-EC2` | AWS mein Key Pair pehle se bana hua hai | Data Source se us Key Pair ko find/read karega |
| `03-Generate-A-New-SSH-Key-Pair-With-Terraform` | Nayi SSH key pair generate karni hai | Terraform nayi keys generate karega aur public key AWS mein register karega |

### Scenario 1 – Laptop ki existing Public Key AWS mein register karna

**Situation:** Aapke laptop mein pehle se ye files hain:

```text
~/.ssh/
├── id_ed25519       # Private Key
└── id_ed25519.pub   # Public Key
```

Terraform ka `file()` function public key file ka content read karta hai. `pathexpand()` `~` ko home-directory path mein expand karta hai.

```hcl
resource "aws_key_pair" "laptop_key" {
  key_name   = "my-laptop-key"
  public_key = file(pathexpand("~/.ssh/id_ed25519.pub"))
}
```

Is code mein `resource "aws_key_pair"` AWS mein Key Pair registration create karta hai. Ye laptop ki existing key ko use karta hai; Terraform nayi local key generate nahi karta.

Uske baad EC2 mein:

```hcl
key_name = aws_key_pair.laptop_key.key_name
```

**Flow:**

```text
Laptop ki existing key pair
          |
          v
Public key (.pub) file()
          |
          v
Terraform aws_key_pair resource
          |
          v
AWS mein public key register
          |
          v
EC2 ke saath Key Pair attach
          |
          v
Laptop ki matching private key se SSH
```

### Scenario 2 – AWS mein pehle se available Key Pair use karna

**Situation:** AWS Console mein EC2 → Key Pairs ke andar ek Key Pair pehle se bana hua hai.

Is baar Terraform ko naya Key Pair create nahi karna. Hum Data Source use karke existing Key Pair ko lookup karenge.

```hcl
data "aws_key_pair" "existing" {
  key_name = "my-existing-key"
}
```

EC2 mein:

```hcl
key_name = data.aws_key_pair.existing.key_name
```

**Flow:**

```text
AWS mein existing Key Pair
          |
          v
Terraform data "aws_key_pair"
          |
          v
Existing Key Pair ki information read
          |
          v
EC2 ke key_name mein reference
          |
          v
EC2 launch
          |
          v
Us Key Pair ki matching private key se SSH
```

**Important:** Data Source sirf AWS mein existing Key Pair ki information read karta hai. Ye Private Key ko download, recover ya generate nahi karta. SSH login ke liye matching Private Key aapke paas honi zaroori hai.

### Scenario 3 – Terraform se nayi SSH Key Pair generate karna

**Situation:** Aapke laptop par required SSH key pair available nahi hai aur aap Terraform se nayi key pair banana chahte hain.

Is case mein `tls_private_key` resource use hota hai:

```hcl
resource "tls_private_key" "ec2_key" {
  algorithm = "ED25519"
}
```

Ye Public Key aur Private Key generate karta hai.

Public Key AWS mein register karenge:

```hcl
resource "aws_key_pair" "generated" {
  key_name   = "terraform-generated-key"
  public_key = tls_private_key.ec2_key.public_key_openssh
}
```

EC2 mein:

```hcl
key_name = aws_key_pair.generated.key_name
```

**Flow:**

```text
Terraform tls_private_key
          |
          v
    New SSH Key Pair
       /       \
      /         \
Public Key    Private Key
    |              |
    v              v
AWS Key Pair    Securely save
    |              |
    v              |
   EC2             |
    |              |
    +------+-------+
           |
           v
    SSH authentication
           |
           v
       EC2 login
```

**Security warning:** `tls_private_key` se generate hui Private Key Terraform state file mein store hoti hai. `sensitive = true` output ko screen par hide karta hai, lekin state se secret remove nahi karta. State file ko securely store karein, access restrict karein aur GitHub par kabhi commit na karein.

---

## 4. Resource aur Data Source mein difference

Ye project ka important Terraform concept hai:

| `resource` | `data` |
|---|---|
| Infrastructure create/manage karta hai | Existing infrastructure ki information read karta hai |
| Example: `resource "aws_key_pair"` | Example: `data "aws_key_pair"` |
| Terraform state mein managed object track hota hai | Data Source se read ki hui information state mein record hoti hai, lekin object data block se create/manage nahi hota |

Yaad rakhein: Data Source ka matlab ye nahi ki object Terraform state mein bilkul nahi aata. Terraform read ki hui data-source information ko bhi state mein record karta hai.

---

## 5. Project Folder Structure

```text
Terraform-EC2-Key-Pair-Practice/
│
├── 01-Register-My-Laptop-Public-Key-In-AWS/
│   ├── README-How-To-Register-My-Laptop-Public-Key-And-Use-It-With-EC2.md
│   ├── provider.tf
│   ├── variables.tf
│   ├── key-pair-register-existing-public-key.tf
│   ├── ec2-use-registered-key-pair.tf
│   └── terraform.tfvars.example
│
├── 02-Use-An-Existing-AWS-Key-Pair-With-EC2/
│   ├── README-How-To-Find-An-Existing-AWS-Key-Pair-And-Attach-It-To-EC2.md
│   ├── provider.tf
│   ├── variables.tf
│   ├── data-find-existing-aws-key-pair.tf
│   ├── ec2-attach-existing-aws-key-pair.tf
│   └── terraform.tfvars.example
│
├── 03-Generate-A-New-SSH-Key-Pair-With-Terraform/
│   ├── README-How-To-Generate-A-New-SSH-Key-Pair-And-Use-It-With-EC2.md
│   ├── provider.tf
│   ├── variables.tf
│   ├── generate-new-ssh-key-pair.tf
│   ├── register-generated-public-key-in-aws.tf
│   ├── ec2-use-generated-key-pair.tf
│   ├── outputs-show-private-key-safely.tf
│   └── terraform.tfvars.example
│
└── README.md
```

---

## 6. Practice karne se pehle kya ready hona chahiye?

1. Terraform installed ho.
2. AWS CLI credentials/profile configured ho, ya environment mein AWS credentials available hon.
3. AWS region pata ho. Is project mein default `ap-south-1` hai.
4. Valid AMI ID, existing Subnet ID aur existing Security Group ID ready hon.
5. EC2 create karne ki AWS permissions hon.
6. Scenario 1 ke liye laptop par existing SSH public/private key pair ho.
7. Scenario 2 ke liye AWS mein existing Key Pair aur uski matching private key ho.
8. Scenario 3 mein Terraform `tls` provider use hoga; `terraform init` provider install karega.

### Security Group requirement

Har scenario mein existing Security Group ID diya jayega. Us Security Group ke inbound rules mein:
- Type: SSH
- Protocol: TCP
- Port: 22
- Source: **aapka trusted public IP `/32`**

SSH port ko `0.0.0.0/0` se open karna avoid karein. EC2 ko SSH se access karne ke liye network route aur public IP (ya suitable private connectivity) bhi required hai.

---

## 7. Project run kaise karna hai?

Har scenario ko **uske apne folder ke andar** run karein.

### Step 1 – Example variables file copy karein

Git Bash:

```bash
cp terraform.tfvars.example terraform.tfvars
```

PowerShell:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

Ab `terraform.tfvars` open karke apni real values fill karein.

Example:

```hcl
ami_id             = "ami-your-valid-id"
subnet_id          = "subnet-your-existing-id"
security_group_ids = ["sg-your-existing-id"]
```

Scenario 2 mein existing Key Pair ka exact name bhi fill karein.

### Step 2 – Terraform commands

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

| Command | Kaam |
|---|---|
| `terraform init` | Required providers initialize/download karta hai |
| `terraform fmt` | Terraform files format karta hai |
| `terraform validate` | Configuration syntax/structure check karta hai |
| `terraform plan` | Proposed changes dikhata hai |
| `terraform apply` | AWS mein resources create karta hai |

### Step 3 – EC2 ka Public IP dekhein

EC2 Console mein instance ka Public IPv4 address dekhein. Phir relevant private key ke saath SSH login karein.

Amazon Linux example:

```bash
ssh -i /path/to/private-key ec2-user@<EC2-PUBLIC-IP>
```

Username AMI ke hisaab se change hota hai. Ubuntu AMI mein aam taur par `ubuntu` hota hai.

### Step 4 – Resources delete karein

Practice complete hone par usi scenario folder mein:

```bash
terraform destroy
```

Destroy se pehle plan/check karein ki kaunse resources delete honge.

---

## 8. Common mistakes aur unke solutions

| Error / problem | Kya check karein? |
|---|---|
| Public key file not found | `public_key_path` sahi hai? File sach mein exist karti hai? |
| Key Pair already exists | AWS account/region mein same name ka Key Pair pehle se toh nahi? |
| Data Source cannot find Key Pair | Exact Key Pair name, AWS account aur region check karein |
| Invalid AMI ID | AMI ID selected region ki hai? |
| Invalid subnet / Security Group | IDs same VPC aur region ke hain? |
| SSH connection timed out | Public IP, route, port 22 inbound rule aur network access check karein |
| Permission denied (publickey) | Matching private key aur correct AMI username use ho raha hai? |
| Private key permissions warning | Private key file permissions restrict karein |

---

## 9. GitHub par kya upload nahi karna hai?

`.gitignore` file mein sensitive/generated files ignore ki gayi hain.

```gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfplan
crash.log
crash.*.log
terraform.tfvars
*.pem
*.key
```

**Kabhi GitHub par upload na karein:**
- `terraform.tfstate` / `terraform.tfstate.backup`
- Private SSH key
- Real `terraform.tfvars` containing secrets
- Credentials ya access keys

`terraform.tfvars.example` safe template hai, isliye use repository mein rakh sakte hain—bas usmein real secrets na daalein.

---

## 10. Best learning sequence

Recommended order:

1. **Scenario 1:** Existing local public key AWS mein register karna seekho.
2. **Scenario 2:** `data` block se AWS ka existing Key Pair read karna seekho.
3. **Scenario 3:** `tls_private_key` se new key pair generate karna seekho.

### Final revision – 3 cases ek line mein

- **Case 1:** Laptop ki existing Public Key → Terraform resource → AWS Key Pair → EC2.
- **Case 2:** AWS ka existing Key Pair → Terraform Data Source → EC2.
- **Case 3:** Terraform `tls_private_key` → New Public/Private Key → AWS Key Pair → EC2.

**Main difference yaad rakho:** Case 1 mein public key laptop se aati hai, Case 2 mein Key Pair AWS mein pehle se hota hai, aur Case 3 mein Terraform nayi key pair generate karta hai.
