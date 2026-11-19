# Terraform -- Existing AWS Key Pair, But Private Key Missing

## Scenario

AWS account mein pehle se EC2 Key Pair available hai, lekin uski
matching Private Key laptop mein available nahi hai.

**Main point:** Terraform Data Source existing AWS Key Pair ki
information read kar sakta hai. Lekin woh AWS se Private Key download ya
recover nahi kar sakta.

------------------------------------------------------------------------

## Step 1 -- AWS mein Existing Key Pair

Maan lo AWS EC2 → Key Pairs mein `my-key` naam ka Key Pair already
available hai.

``` text
AWS Account
    |
    v
Existing Key Pair: my-key
    |
    +--> Public Key: Available in AWS
    |
    +--> Private Key: AWS se download nahi kar sakte
```

AWS mein registered Public Key hoti hai. Matching Private Key user ke
paas securely honi chahiye.

## Step 2 -- Terraform Data Source se Existing Key Pair Find Karna

``` hcl
data "aws_key_pair" "existing" {
  key_name = "my-key"
}
```

Is code ka matlab:

-   `data` = AWS mein already existing Key Pair ki information read
    karo.
-   `aws_key_pair` = AWS EC2 Key Pair data source.
-   `existing` = Terraform mein diya gaya local label.
-   `key_name` = AWS mein existing Key Pair ka naam.

**Data Source Key Pair create nahi karta aur Private Key retrieve nahi
karta.**

### Flow

``` text
AWS Existing Key Pair
          |
          v
Terraform Data Source
          |
          v
Existing Key Pair ki information read
          |
          v
Key Pair Name: my-key
```

## Step 3 -- EC2 ke Saath Existing Key Pair Attach Karna

``` hcl
resource "aws_instance" "my_ec2" {
  ami           = var.ami_id
  instance_type = "t2.micro"

  key_name = data.aws_key_pair.existing.key_name
}
```

Explanation:

-   `resource "aws_instance"` = EC2 instance create/manage karta hai.
-   `key_name` = EC2 launch ke waqt use hone wale AWS Key Pair ka naam.
-   `data.aws_key_pair.existing.key_name` = Data Source se mila existing
    Key Pair name.

``` text
AWS Existing Key Pair: my-key
             |
             v
    Terraform Data Source
             |
             v
       Key Pair Name
             |
             v
       EC2 Instance
       (my-key attached)
```

**Important:** Key Pair attach karne se Private Key laptop mein
automatically nahi aati.

## Step 4 -- SSH Login Karne Ki Koshish

Example command:

``` bash
ssh -i my-key.pem ec2-user@<EC2-PUBLIC-IP>
```

Agar `my-key.pem` tumhare laptop mein nahi hai, toh SSH client matching
Private Key use nahi kar sakta.

### AWS aur Laptop ki Situation

  Location   Kya available hai?
  ---------- ----------------------------------
  AWS        Public Key registered hai
  Laptop     Matching Private Key missing hai

``` text
          SSH Login
              |
              v
   Matching Private Key available?
              |
          +---+---+
          |       |
         YES      NO
          |       |
          v       v
      Login     Login nahi
      proceed   kar paoge
```

## Step 5 -- Private Key Missing Ho Toh Kya Karein?

``` text
Private Key laptop mein nahi hai
              |
              v
   Kya secure backup available hai?
              |
          +---+---+
          |       |
         YES      NO
          |       |
          v       v
    Backup se   Original Private Key
    recover     recover nahi ho sakti
    karo             |
          |          v
          |     New Key Pair generate karo
          |          |
          |          v
          |     EC2 par new Public Key
          |     install/update karo
          |          |
          +----------+
              |
              v
          SSH Login
```

Agar original Private Key permanently lost ho gayi hai:

1.  AWS se original Private Key dobara download nahi kar sakte.
2.  Nayi Public/Private Key Pair generate karo.
3.  EC2 par pehle se available access method use karo, jaise Systems
    Manager Session Manager ya EC2 Instance Connect, agar woh configured
    aur supported ho.
4.  EC2 ke authorized SSH access mein new Public Key install/update
    karo.
5.  Matching new Private Key ko laptop par securely save karo.
6.  New Private Key se SSH login karo.

Agar pehle se koi access method configured nahi hai, toh recovery ke
liye suitable instance recovery procedure ki zarurat ho sakti hai.

------------------------------------------------------------------------

## Terraform ke 3 Important Blocks -- Difference

  -----------------------------------------------------------------------
  Terraform block                     Kaam
  ----------------------------------- -----------------------------------
  `resource "aws_key_pair"`           Public Key AWS mein register/create
                                      karta hai

  `data "aws_key_pair"`               AWS mein existing Key Pair ki
                                      information read karta hai

  `resource "tls_private_key"`        Nayi Public aur Private Key
                                      generate karta hai
  -----------------------------------------------------------------------

## Final Revision

-   AWS Key Pair mein registered Public Key se matching Private Key user
    ke paas honi chahiye.
-   Terraform Data Source sirf existing Key Pair ki information read
    karta hai.
-   Data Source Private Key download ya recover nahi kar sakta.
-   Private Key missing ho toh backup recover karo; backup nahi hai toh
    new key generate karke EC2 par new Public Key install karo.
-   EC2 par SSH login ke liye matching Private Key, correct username,
    network access aur Security Group mein allowed SSH (TCP 22) zaroori
    hain.

## Interview Answer

A Terraform data source can read the metadata of an existing AWS EC2 Key
Pair and attach its name to a new EC2 instance. However, AWS does not
provide the private key for download. The matching private key must
already be available to the user. If it is permanently lost, a new key
pair must be generated and its public key installed on the instance
through an existing access or recovery method.
