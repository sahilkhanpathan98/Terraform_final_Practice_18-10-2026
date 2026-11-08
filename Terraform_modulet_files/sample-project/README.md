# Sample Terraform module project

This project demonstrates:
1. One child module containing both EC2 and S3.
2. Separate EC2 and S3 modules, so the root configuration can call only EC2 or both.

Before running:
- Install Terraform and configure AWS credentials.
- Use an AMI ID valid in your selected AWS region.
- Replace the sample S3 bucket name with a globally unique name.
- Review `terraform plan` before applying. AWS resources may incur charges.

Run Terraform from the selected execution directory, not from the module source folder.
