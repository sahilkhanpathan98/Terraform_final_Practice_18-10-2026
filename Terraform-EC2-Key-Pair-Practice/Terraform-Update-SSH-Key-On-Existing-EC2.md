# Terraform -- Update SSH Key Pair on an Existing EC2 Instance

## Goal

Samajhna hai ki agar Terraform se new SSH Key Pair generate karke
existing EC2 ke saath use karna chahte hain, toh `terraform apply` par
kya hoga.

**Short answer:** - `aws_instance` ke `key_name` ko change karne par
Terraform AWS provider normally EC2 instance ko replace karta hai. - EC2
ko same rakhna hai, toh existing instance ke andar new Public Key ko
`~/.ssh/authorized_keys` mein add karna hota hai. Iske liye pehle se koi
working access method chahiye.

------------------------------------------------------------------------

## 1. Existing EC2 ka setup

Maan lo tumhare paas pehle se EC2 hai aur woh old Key Pair se launch hua
tha.

``` text
             AWS
              |
              v
       Existing EC2
              |
              v
        Old Public Key
              |
              v
    Laptop par Old Private Key
              |
              v
          SSH Login
```

EC2 launch ke waqt select ki gayi Key Pair ki Public Key instance par
SSH access ke liye configure hoti hai. AWS tumhari Private Key ko EC2
mein store nahi karta.

## 2. Terraform se New Key Pair generate karna

### `tls_private_key` -- new key material generate karta hai

``` hcl
resource "tls_private_key" "new_key" {
  algorithm = "ED25519"
}
```

Ye matching Public Key aur Private Key generate karta hai.

### `aws_key_pair` -- Public Key AWS mein register karta hai

``` hcl
resource "aws_key_pair" "new_key" {
  key_name   = "new-ec2-key"
  public_key = tls_private_key.new_key.public_key_openssh
}
```

AWS mein Public Key register hoti hai. Private Key ko securely apne paas
rakhna hota hai. `tls_private_key` ka private-key value Terraform state
mein bhi store hota hai, isliye state file ko secure rakho.

### New key ka flow

``` text
       Terraform
           |
           v
  tls_private_key.new_key
           |
      Generate Keys
           |
      +----+----+
      |         |
      v         v
  Public Key  Private Key
      |         |
      v         v
 aws_key_pair  Securely save
      |        on laptop
      v
 AWS Key Pair
```

## 3. Method A -- Existing EC2 resource ka `key_name` change karna

Maan lo tumhara existing EC2 resource hai:

``` hcl
resource "aws_instance" "my_ec2" {
  ami           = var.ami_id
  instance_type = "t2.micro"

  key_name = "old-key"
}
```

Ab tum `key_name` ko new Key Pair se replace karte ho:

``` hcl
resource "aws_instance" "my_ec2" {
  ami           = var.ami_id
  instance_type = "t2.micro"

  key_name = aws_key_pair.new_key.key_name
}
```

### `terraform plan` / `apply` par kya hoga?

EC2 instance ka launch-time `key_name` setting in-place update nahi
hota. AWS provider is change ke liye instance replacement plan karta
hai.

``` text
       Existing EC2
       old-key attached
             |
             v
     Terraform configuration
       key_name changes
             |
             v
       terraform plan
             |
             v
      EC2 replacement shown
             |
             v
       terraform apply
             |
       +-----+------+
       |            |
       v            v
  Old EC2       New EC2
  terminated    created
                with new-key
```

**Result:** Ye sirf EC2 ko stop karke key update nahi karta. Instance
replace hota hai.

### Important impact

-   New EC2 ko naya Public IP mil sakta hai.
-   Old instance par locally stored data lose ho sakta hai, agar woh
    persistent storage/backup mein nahi hai.
-   Attached EBS volumes aur delete settings ka impact alag se check
    karo.
-   `create_before_destroy` use karne par temporary period mein old aur
    new dono EC2 exist kar sakte hain; iske liye capacity, IP, naming
    aur other dependencies check karo.
-   `terraform plan` ko carefully review karo before `apply`.

## 4. Method B -- Existing EC2 ko replace kiye bina New Public Key add karna

Agar tum existing EC2 ko same rakhna chahte ho, toh sirf Terraform
`key_name` change mat karo.

Instead, EC2 ke andar user ke SSH folder ki `authorized_keys` file mein
new Public Key add karo.

### Flow diagram

``` text
       Terraform generates
          New Key Pair
               |
          +----+----+
          |         |
          v         v
      Public Key  Private Key
          |         |
          |         v
          |    Securely save
          |    on laptop
          v
  Existing EC2 ke andar
  authorized_keys mein
  New Public Key add karo
          |
          v
   Existing EC2 remains
       the same
          |
          v
   New Private Key se
       SSH Login
```

### New Public Key kaise add hogi?

Pehle se working access method zaroori hai, jaise: - Existing SSH
Private Key se login. - AWS Systems Manager Session Manager, agar
configured hai. - EC2 Instance Connect, agar supported/configured hai.

Linux EC2 par correct user ke liye `~/.ssh/authorized_keys` file mein
new Public Key add karni hoti hai. File permissions aur ownership sahi
rehni chahiye.

Example concept:

``` bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
# New public key ko authorized_keys mein append karo
chmod 600 ~/.ssh/authorized_keys
```

`authorized_keys` mein new Public Key ki poori line add karo. Existing
Public Key ko replace karne ke bajaye append karna safer hai, taaki old
access bhi kaam karta rahe.

**Note:** Ye commands EC2 ke correct login user ke context mein run honi
chahiye. Terraform ka `aws_key_pair` resource sirf AWS account mein key
register karta hai; woh automatically running EC2 ki `authorized_keys`
file update nahi karta.

## 5. Dono methods ka comparison

  -----------------------------------------------------------------------
  Point                   Method A: `key_name`    Method B:
                          change                  `authorized_keys`
                                                  update
  ----------------------- ----------------------- -----------------------
  Existing EC2            Replace hota hai        Same rehta hai

  Key update              New instance launch par Running instance ke
                                                  andar

  Existing access method  Replacement ke liye     New key add karne ke
                          zaroori nahi, lekin     liye zaroori
                          other dependencies      
                          matter                  

  Public IP               Change ho sakta hai     Normally same rehta hai

  Data risk               Instance/local data ka  Instance replace nahi
                          impact check karo       hota
  -----------------------------------------------------------------------

## 6. Important Terraform concepts

-   `tls_private_key`: new Public/Private Key generate karta hai.
-   `aws_key_pair`: Public Key ko AWS EC2 Key Pairs mein register karta
    hai.
-   `aws_instance.key_name`: EC2 launch ke waqt Key Pair select karta
    hai.
-   `authorized_keys`: Linux instance par allowed SSH Public Keys ki
    list hoti hai.
-   Terraform `aws_key_pair` resource create karne se running EC2 ki
    `authorized_keys` automatically update nahi hoti.

## 7. Safe practice before applying

1.  `terraform plan` run karo.
2.  Check karo ki plan mein EC2 ke saamne `-/+` replacement dikh raha
    hai ya nahi.
3.  Existing EC2 ke important data ka backup lo.
4.  SSH access aur recovery method confirm karo.
5.  Private Key aur Terraform state file ko secure rakho.
6.  Production EC2 par bina impact samjhe `terraform apply` mat karo.

## Interview Answer

Changing the `key_name` of a Terraform-managed EC2 instance normally
forces instance replacement because the EC2 launch Key Pair setting is
not updated in place. To retain the existing instance, add the new
public key to the appropriate user's `authorized_keys` file using an
existing access method such as SSH or Systems Manager. Registering a key
with the AWS `aws_key_pair` resource alone does not update a running
instance.
