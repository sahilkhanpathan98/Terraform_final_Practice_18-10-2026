
# EC2 User Data Using Terraform

## 1. Project Objective

The objective of this project is to create an EC2 instance using Terraform and automatically install and configure Apache Web Server using EC2 User Data.

User Data helps automate the initial configuration of an EC2 instance without manually connecting through SSH.

---

## 2. Project Structure

```text
EC2-User-Data/
│
├── provider.tf
├── main.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
├── test.sh
├── README.md
└── .gitignore
```

---

## 3. File Explanation

| File | Purpose |
|---|---|
| provider.tf | AWS provider configuration |
| main.tf | EC2 resource configuration |
| variables.tf | Variable declarations |
| terraform.tfvars | Actual variable values |
| outputs.tf | Displays EC2 Public IP and Website URL |
| test.sh | Contains User Data startup commands |
| .gitignore | Ignores unnecessary Terraform files |
| README.md | Project documentation |

---

## 4. What is EC2 User Data?

EC2 User Data is a startup script used to automate the initial configuration of an EC2 instance.

For example:
- Install Apache Web Server.
- Start Apache service.
- Create an index.html file.
- Host a website automatically.

Normally, we perform these tasks manually by connecting to EC2 through SSH.

Using User Data, these tasks can be automated during the initial EC2 boot process.

---

## 5. Complete Working Flow

```text
Terraform Configuration
        |
        v
provider.tf + variables.tf
        |
        v
terraform.tfvars
        |
        v
main.tf
        |
        | Reads test.sh using file()
        v
Terraform Apply
        |
        v
AWS EC2 Launch
        |
        v
EC2 First Boot
        |
        v
Cloud-init executes User Data
        |
        v
Apache Installation
        |
        v
Apache Service Started
        |
        v
index.html Created
        |
        v
Website Live on EC2 Public IP
```

---

## 6. User Data Script (test.sh)

```bash
#!/bin/bash

# Install Apache
dnf install -y httpd

# Start Apache and enable on boot
systemctl enable --now httpd

# Create website
echo "<h1>Welcome! AWS Infra created using Terraform</h1>" \
  > /var/www/html/index.html
```

### Explanation

| Command | Purpose |
|---|---|
| `#!/bin/bash` | Defines Bash as the script interpreter |
| `dnf install -y httpd` | Installs Apache Web Server |
| `systemctl enable --now httpd` | Starts Apache and enables it at boot |
| `echo` | Creates website content |
| `/var/www/html/index.html` | Default Apache website location |

Note: This script is intended for Amazon Linux 2023.

---

## 7. Security Group Configuration

For accessing the website through a browser, the EC2 Security Group must allow inbound HTTP traffic.

| Type | Protocol | Port | Source |
|---|---|---|---|
| HTTP | TCP | 80 | 0.0.0.0/0 |
| SSH | TCP | 22 | My IP |

Additional requirements:
- EC2 must have a Public IP.
- Suitable Internet Gateway and routing must exist.
- EC2 must have outbound internet connectivity to install Apache.

### Website Access Flow

```text
Browser
   |
   | HTTP Request (Port 80)
   v
EC2 Security Group
   |
   v
Apache Web Server
   |
   v
index.html
   |
   v
Website Displayed
```

---

## 8. Terraform State and User Data Relationship

Terraform State and User Data have different responsibilities.

### Terraform State

Terraform State tracks managed infrastructure resources and their attributes.

For example:
- EC2 Instance ID
- Public IP
- Instance Type
- Other tracked resource attributes

User Data configuration can also be represented in Terraform State.

### User Data

User Data contains startup instructions that execute inside the EC2 instance.

For example:
- Install Apache.
- Start Apache.
- Create website files.

### Important Difference

Terraform State does not maintain a command-by-command execution log of the User Data script.

If the script fails, Terraform Apply being successful does not guarantee that Apache was installed successfully.

To troubleshoot User Data execution, check:

```bash
sudo cat /var/log/cloud-init-output.log
```

---

## 9. When Does User Data Execute?

By default, EC2 User Data executes during the first boot of an instance.

| Situation | User Data Execution |
|---|---|
| New EC2 first boot | Executes |
| Normal Terraform Apply without EC2 replacement | Does not automatically execute again |
| Normal EC2 reboot | Does not automatically execute again |
| New EC2 instance launch | Executes on first boot |

Note: User Data can be configured to run on subsequent boots using cloud-init configuration, but that is not the default behavior.

---

## 10. What is .gitignore?

The `.gitignore` file tells Git which files and folders should not be tracked or uploaded to GitHub.

### .gitignore Configuration

```gitignore
.terraform/
*.tfstate
*.tfstate.*
terraform.tfvars
crash.log
```

### Why Do We Ignore These Files?

| File / Folder | Reason |
|---|---|
| `.terraform/` | Contains downloaded providers and Terraform plugins. |
| `*.tfstate` | Contains Terraform state information and resource details. |
| `*.tfstate.*` | Contains state backups and related files. |
| `terraform.tfvars` | Contains actual variable values and may contain sensitive information. |
| `crash.log` | Contains Terraform crash and debugging information. |

### What is crash.log?

- Terraform may generate `crash.log` when it encounters an unexpected internal crash.
- It contains crash-related and debugging information.
- It helps troubleshoot Terraform problems.
- It is generally not required in the GitHub repository.

**One-line:** `crash.log` is ignored because it contains local Terraform crash and debugging information that is not required in the Git repository.

---

## 11. Terraform Execution Commands

Run these commands inside the project directory.

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

### Command Explanation

| Command | Purpose |
|---|---|
| `terraform init` | Initializes Terraform and downloads providers. |
| `terraform fmt` | Formats Terraform configuration files. |
| `terraform validate` | Checks Terraform configuration syntax. |
| `terraform plan` | Shows proposed infrastructure changes. |
| `terraform apply` | Creates or updates infrastructure. |

---

## 12. Verify Website

After Terraform Apply, get the EC2 Public IP from Terraform output.

Open the following URL in your browser:

```text
http://YOUR_EC2_PUBLIC_IP
```

Expected website output:

```text
Welcome! AWS Infra created using Terraform
```

---

## 13. Important Interview Points

1. User Data is used to automate EC2 initial configuration.
2. Terraform passes User Data during EC2 launch.
3. Cloud-init executes the script during the first boot.
4. User Data normally executes only once by default.
5. Terraform State tracks resource attributes, not command-by-command execution logs.
6. User Data failures can be investigated using `/var/log/cloud-init-output.log`.
7. Security Group must allow HTTP port 80 to access the website.
8. A successful Terraform Apply does not guarantee successful application installation.

---

## 14. Interview-Ready Definition

EC2 User Data is a startup script used to automate the initial configuration of an EC2 instance. Terraform passes the script during instance launch, and cloud-init executes it during the first boot. It is commonly used to install packages, configure services, and deploy applications without manually connecting through SSH.

### Final Flow

```text
Terraform
    |
    v
User Data Script
    |
    v
EC2 Launch
    |
    v
Cloud-init
    |
    v
Apache Installation
    |
    v
Website Live
```
