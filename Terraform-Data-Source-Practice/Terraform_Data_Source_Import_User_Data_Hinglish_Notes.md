# Terraform -- Data Source, Import aur EC2 User Data

## Simple Hinglish Notes with Flow Diagrams + Interview Answers

## 1. Sabse pehle 4 concepts samjho

Terraform mein ye concepts alag-alag kaam karte hain:

  -----------------------------------------------------------------------
  Concept                             Simple meaning
  ----------------------------------- -----------------------------------
  **Data Source**                     Existing AWS resource ki
                                      information read/fetch karna

  **Import**                          Existing AWS resource ko Terraform
                                      ke management aur State mein lana

  **Resource**                        AWS infrastructure create aur
                                      manage karna

  **User Data**                       EC2 ke first boot par Shell Script
                                      execute karke initial setup karna
  -----------------------------------------------------------------------

**Shortcut yaad rakho:**

-   Data Source = Details read karo.
-   Import = Existing resource ko Terraform State se connect karo.
-   Resource = Infrastructure create/manage karo.
-   User Data = EC2 ka initial setup automate karo.

------------------------------------------------------------------------

# Part A -- Data Source

## 2. Data Source kya hota hai?

Maan lo AWS mein pehle se VPC, Subnet ya AMI available hai. Ab Terraform
se naya EC2 banana hai aur us existing resource ki ID chahiye.

ID manually likhne ke bajaye hum **Data Source** se uski information
fetch kar sakte hain.

Data Source existing resource ko create nahi karta. Ye sirf uski
information read karta hai.

### Real-life example

Office mein employee pehle se hai. Tum usko dobara hire nahi kar rahe;
bas record se uski employee ID nikal rahe ho.

Terraform Data Source bhi existing AWS resource ki details read karta
hai.

## 3. Data Source flow diagram

``` text
AWS Account
    |
    v
Existing Resources
(VPC / Subnet / AMI)
    |
    v
Terraform Data Source
    |
    |  Information read karta hai
    v
Resource ki details / ID milti hai
    |
    v
Terraform configuration mein use
(Example: naya EC2 create karna)
```

## 4. Data Source syntax

``` hcl
data "aws_vpc" "existing" {
  default = true
}
```

-   `data` -- Existing resource ki information read karni hai.
-   `aws_vpc` -- AWS VPC data source.
-   `existing` -- Terraform configuration ke andar local naam.
-   `default = true` -- AWS ka default VPC find karo.

Fetched VPC ID:

``` hcl
data.aws_vpc.existing.id
```

**Important:** `existing` Terraform ka local reference name hai. Ye AWS
mein VPC ka actual naam hona zaroori nahi.

## 5. Common Data Sources

  Data Source                Kya information read karta hai?
  -------------------------- ------------------------------------
  `aws_ami`                  Existing AMI ki details
  `aws_vpc`                  Existing VPC ki details
  `aws_subnet`               Existing Subnet ki details
  `aws_security_group`       Existing Security Group ki details
  `aws_availability_zones`   Available Availability Zones

## 6. Example -- Existing AMI find karna

``` hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}
```

Simple explanation:

-   `aws_ami` -- AMI ki information read karni hai.
-   `most_recent = true` -- Matching AMIs mein latest select karo.
-   `owners = ["amazon"]` -- Amazon-owned AMIs search karo.
-   `filter` -- AMI ke name ke basis par search karo.

AMI ID use karne ke liye:

``` hcl
data.aws_ami.amazon_linux.id
```

> Note: AMI availability AWS Region ke hisaab se alag ho sakti hai.

------------------------------------------------------------------------

# Part B -- Terraform Import

## 7. Terraform Import kya hota hai?

Maan lo AWS Console se tumne manually ek EC2 instance create kiya. Ab
tum chahte ho ki Terraform bhi us EC2 ko manage kare.

Lekin wo EC2 Terraform se create nahi hua tha, isliye Terraform ke State
file mein uski tracking nahi hai.

**Terraform Import** existing AWS resource ko Terraform State ke saath
associate karta hai, taaki Terraform us resource ko manage kar sake.

### Real-life example

Maan lo office mein ek employee pehle se kaam kar raha hai, lekin
company ke official employee records mein uska naam add nahi hua. Import
ka concept us employee ko official record mein add karne jaisa hai.

## 8. Import flow diagram

``` text
AWS Console
    |
    v
Existing EC2 Instance
(Already created manually)
    |
    v
Terraform Configuration
(resource block likho)
    |
    v
Terraform Import
    |
    v
Terraform State File
(EC2 ki tracking add hoti hai)
    |
    v
Terraform ab EC2 ko manage kar sakta hai
```

## 9. Import karne se pehle Resource block likho

Example:

``` hcl
resource "aws_instance" "my_ec2" {
  # Existing EC2 ki matching configuration
}
```

Yahan:

-   `aws_instance` -- Terraform AWS EC2 resource type.
-   `my_ec2` -- Terraform configuration ka local naam.

**Important:** Import command existing EC2 ka complete Terraform
configuration automatically generate nahi karta. Resource configuration
ko khud likhna aur actual resource ke saath match karna hota hai.

## 10. Method 1 -- Terraform CLI Import

Command:

``` bash
terraform import aws_instance.my_ec2 i-0123456789abcdef0
```

Iska meaning:

-   `terraform import` -- Import operation run karo.
-   `aws_instance.my_ec2` -- Terraform configuration mein resource
    address.
-   `i-0123456789abcdef0` -- AWS ka existing EC2 Instance ID.

### CLI Import ka step-by-step flow

``` text
Step 1: Existing EC2 AWS mein available hai
                 |
                 v
Step 2: Terraform mein resource block likho
                 |
                 v
Step 3: terraform init
                 |
                 v
Step 4: terraform import command run karo
                 |
                 v
Step 5: Terraform State mein resource add
                 |
                 v
Step 6: terraform plan run karo
                 |
                 v
Step 7: Configuration aur real EC2 ko match karo
```

### Useful commands

``` bash
terraform init
terraform import aws_instance.my_ec2 i-0123456789abcdef0
terraform state list
terraform state show aws_instance.my_ec2
terraform plan
```

-   `terraform state list` -- State mein tracked resources ki list.
-   `terraform state show` -- Imported resource ki recorded details.
-   `terraform plan` -- Configuration aur real infrastructure ke beech
    difference check karta hai.

**Important:** `terraform import` State ko update karta hai, lekin `.tf`
configuration file ko automatically complete nahi banata. Import ke baad
configuration ko properly match karna zaroori hai.

## 11. Method 2 -- Terraform Import Block

Terraform mein declarative `import` block bhi use kar sakte hain.

Example:

``` hcl
import {
  to = aws_instance.my_ec2
  id = "i-0123456789abcdef0"
}

resource "aws_instance" "my_ec2" {
  # Existing EC2 ke according configuration likho
}
```

Ab commands:

``` bash
terraform init
terraform plan
terraform apply
```

Explanation:

-   `to` -- Terraform mein kis resource address par import karna hai.
-   `id` -- AWS ka existing resource ID.
-   `resource` block -- Imported resource ki desired configuration
    define karta hai.
-   `terraform plan` -- Import aur proposed changes preview karta hai.
-   `terraform apply` -- Import operation aur approved changes apply
    karta hai.

**Note:** Import block Terraform configuration mein rehta hai aur apply
ke through import hota hai. CLI `terraform import` aur declarative
`import` block, dono ka purpose existing resource ko Terraform State
mein lana hai.

## 12. CLI Import vs Import Block

  -----------------------------------------------------------------------
  CLI Import                          Import Block
  ----------------------------------- -----------------------------------
  Command line se run hota hai        `.tf` file mein define hota hai

  `terraform import ...`              `import { ... }`

  Direct State import operation       Plan/apply workflow ka part

  Import details command mein dete    Import details configuration mein
  hain                                dete hain
  -----------------------------------------------------------------------

## 13. Import ke baad kya check karna hai?

1.  `terraform state list` se check karo resource State mein aaya ya
    nahi.
2.  `terraform state show` se imported resource ki details dekho.
3.  `.tf` configuration ko existing EC2 ke saath match karo.
4.  `terraform plan` run karke proposed changes samjho.
5.  Unwanted changes ya EC2 replacement dikh raha ho toh reason samjhe
    bina `apply` mat karo.

**Important:** Import ka matlab EC2 ko dobara create karna nahi hai.
Import existing EC2 ko Terraform State mein track karne ke liye hota
hai.

------------------------------------------------------------------------

# Part C -- EC2 User Data

## 14. User Data kya hota hai?

Jab hum EC2 instance launch karte hain, tab uske saath ek Shell Script
provide kar sakte hain. Is script ko **EC2 User Data** kehte hain.

Linux EC2 ke first boot par User Data script automatically execute ho
sakti hai.

Iska use initial setup aur automation ke liye hota hai:

-   Apache ya Nginx install karna.
-   Packages update karna.
-   Application files configure karna.
-   Web server start aur enable karna.

### Real-life example

Naya computer start karne ke baad software install aur settings
configure karni hoti hain. User Data EC2 ke first startup par initial
setup automate karne mein help karta hai.

## 15. User Data flow diagram

``` text
Terraform
    |
    v
EC2 Resource Configuration
    |
    |  user_data mein Shell Script
    v
AWS EC2 Instance Launch
    |
    v
EC2 ka First Boot
    |
    v
User Data Script Execute
    |
    v
Software Installation
+ Initial Configuration
    |
    v
EC2 Ready for Use
```

## 16. Terraform mein User Data example

Amazon Linux EC2 par Apache install karna:

``` hcl
resource "aws_instance" "web_server" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t2.micro"

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install httpd -y
    systemctl start httpd
    systemctl enable httpd
    echo "Hello from Terraform User Data" > /var/www/html/index.html
  EOF

  tags = {
    Name = "My-Web-Server"
  }
}
```

### Code ko simple language mein samjho

  -----------------------------------------------------------------------
  Code                                Meaning
  ----------------------------------- -----------------------------------
  `user_data =`                       EC2 ko startup script dena

  `#!/bin/bash`                       Script Bash shell mein run hogi

  `yum update -y`                     Package updates install karna

  `yum install httpd -y`              Apache web server install karna

  `systemctl start httpd`             Apache ko start karna

  `systemctl enable httpd`            System startup par Apache ko start
                                      karne ke liye enable karna

  `echo ...`                          Website ki HTML file create karna
  -----------------------------------------------------------------------

**Important:** - Ye example Amazon Linux ke liye hai. Ubuntu mein
generally `apt` / `apt-get` commands use hoti hain. - `ami-xxxxxxxx` ki
jagah apne AWS Region ki valid AMI ID deni hogi. - User Data normally
first boot par execute hota hai. Har reboot par automatically dobara run
nahi hota. - Terraform mein `user_data` change hone par
provider/resource settings ke hisaab se EC2 replacement ho sakta hai;
plan zaroor check karo.

## 17. User Data ka result kaise check karein?

1.  EC2 instance launch hone ka wait karo.
2.  EC2 ke public IP ko browser mein open karo.
3.  Security Group inbound rule mein HTTP TCP port 80 allow hona
    chahiye.
4.  Agar network aur script sahi hain, page par ye message dikh sakta
    hai:

``` text
Hello from Terraform User Data
```

Agar page nahi khulta, toh check karo:

-   EC2 instance running hai ya nahi.
-   Security Group mein port 80 allowed hai ya nahi.
-   Instance ke paas internet/package access hai ya required packages
    available hain.
-   User Data script successfully execute hui ya nahi.

------------------------------------------------------------------------

# Part D -- Data Source + Import + Resource + User Data Together

## 18. Chaaro concepts ka difference practical example se

Maan lo:

-   AWS mein ek VPC already available hai.
-   AWS mein ek manually created EC2 bhi available hai.
-   Ab tum ek naya EC2 Terraform se create karna chahte ho.
-   Naye EC2 par Apache install karna hai.

Is situation mein:

1.  **Data Source:** Existing VPC ki ID read kar sakta hai.
2.  **Import:** Manually created EC2 ko Terraform State mein la sakta
    hai.
3.  **Resource:** Naya EC2 create kar sakta hai.
4.  **User Data:** Naye EC2 ke first boot par Apache install kar sakta
    hai.

### Combined flow diagram

``` text
                AWS ACCOUNT
                     |
          +----------+----------+
          |                     |
          v                     v
    Existing VPC         Existing Manual EC2
          |                     |
          v                     v
     DATA SOURCE              IMPORT
   VPC ID fetch karo     Terraform State mein lao
          |                     |
          v                     v
   New EC2 mein use       Terraform manages it
          |
          v
     EC2 RESOURCE
     Naya EC2 create
          |
          v
      USER DATA
    Shell Script run
          |
          v
   Apache install/start
          |
          v
      Web Server Ready
```

## 19. Complete Terraform example -- Data Source + Resource + User Data

``` hcl
# Step 1: Existing default VPC ki information fetch karo

data "aws_vpc" "existing" {
  default = true
}

# Step 2: Existing VPC ke andar subnet ki information fetch karo

data "aws_subnets" "existing" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
}

# Step 3: Latest matching Amazon Linux AMI fetch karo

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# Step 4: Naya EC2 create karo

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  subnet_id = data.aws_subnets.existing.ids[0]

  # Step 5: EC2 ke first boot par script run hogi

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install httpd -y
    systemctl enable --now httpd
    echo "Apache installed using Terraform User Data" > /var/www/html/index.html
  EOF

  tags = {
    Name = "Data-Source-User-Data-EC2"
  }
}
```

### Is example mein kya ho raha hai?

1.  `data.aws_vpc.existing` existing default VPC ki details read karta
    hai.
2.  `data.aws_subnets.existing` us VPC ke subnets find karta hai.
3.  `data.aws_ami.amazon_linux` latest matching Amazon Linux AMI find
    karta hai.
4.  `resource "aws_instance"` naya EC2 create karta hai.
5.  `user_data` first boot par Apache install aur configure karta hai.

**Important:** Ye example ek suitable subnet assume karta hai.
Production use se pehle subnet selection, public/private routing,
Security Group, HTTP port 80, IAM permissions aur package internet
access configure/check karna zaroori hai.

**Import is example mein alag workflow hai:** Agar koi EC2 pehle se
manually bana hua hai, usko `terraform import` ya `import` block se
State mein lana hoga. Data Source us EC2 ko Terraform ke through manage
karne ka substitute nahi hai.

------------------------------------------------------------------------

# Part E -- Final Difference Table

## 20. Data Source vs Import vs Resource vs User Data

  -----------------------------------------------------------------------------------
  Point          Data Source    Import               Resource         User Data
  -------------- -------------- -------------------- ---------------- ---------------
  Main purpose   Existing       Existing resource ko Infrastructure   EC2 initial
                 details read   State mein lana      create/manage    setup automate
                 karna                               karna            karna

  Syntax         `data` block   `terraform import` / `resource` block `user_data`
                                `import` block                        argument

  Example        VPC ID fetch   Existing EC2 State   New EC2 create   Apache install
                                mein lana                             

  AWS resource   Nahi           Nahi                 Haan, as         Khud se nahi
  create karta                                       configured       
  hai?                                                                

  State mein kya Read operation Existing resource ko Managed resource EC2 resource ki
  role?          ke results use track karwata hai    track hota hai   configuration
                 karta hai                                            ka part
  -----------------------------------------------------------------------------------

------------------------------------------------------------------------

# Part F -- Interview Preparation

## 21. What is a Data Source in Terraform?

**Answer:**

A Data Source in Terraform is used to read information about existing
infrastructure or resources. It allows us to use details such as AMI ID,
VPC ID, and Subnet ID in our Terraform configuration without creating
those resources again.

## 22. What is Terraform Import?

**Answer:**

Terraform Import is used to bring an existing infrastructure resource
under Terraform management by associating it with a resource address in
the Terraform State. The resource configuration must also be written and
aligned with the real infrastructure.

## 23. What is the difference between Data Source and Import?

**Answer:**

A Data Source reads information about an existing resource, whereas
Import associates an existing resource with a Terraform resource address
in the State so that Terraform can manage it.

## 24. What is EC2 User Data?

**Answer:**

EC2 User Data allows us to pass scripts to an EC2 instance during
launch. These scripts are commonly used to automate initial
configuration tasks such as installing software, updating packages, and
starting services.

## 25. Can we use Data Source and User Data together?

**Answer:**

Yes. We can use a Data Source to fetch an existing AMI ID and pass that
ID to an EC2 Resource. We can also provide User Data to install and
configure software automatically during the EC2 instance's first boot.

------------------------------------------------------------------------

# Final Revision -- Ek Minute Mein Yaad Karo

``` text
DATA SOURCE
    |
    v
Existing AWS resource ki details read karo
    |
    v
AMI ID / VPC ID / Subnet ID


IMPORT
    |
    v
Existing AWS resource ko Terraform State se connect karo
    |
    v
Terraform us resource ko manage kar sakta hai


RESOURCE
    |
    v
AWS infrastructure create/manage karo
    |
    v
Example: EC2 / VPC / S3


USER DATA
    |
    v
EC2 ko Shell Script do
    |
    v
First Boot par initial setup automate karo
```

## Sabse important 4 lines

1.  **Data Source = Existing AWS resources ki information fetch karna.**
2.  **Import = Existing AWS resource ko Terraform State mein lana.**
3.  **Resource = AWS infrastructure create aur manage karna.**
4.  **User Data = EC2 ke first boot par Shell Script execute karke
    initial setup automate karna.**

**Final shortcut:** Data Source details laata hai, Import existing
resource ko Terraform State se connect karta hai, Resource
infrastructure manage karta hai, aur User Data EC2 configure karta hai.
