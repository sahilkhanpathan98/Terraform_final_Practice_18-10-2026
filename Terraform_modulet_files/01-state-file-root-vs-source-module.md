# Terraform State File – Root Module vs Source Module

## 1. Main concept

Terraform normally maintains the state file in the **working directory from which you run Terraform commands**.

When you run `terraform init`, `terraform plan`, or `terraform apply` from the execution directory (root module), the default local state file is created/updated there.

The root module state tracks resources created by the root module **and by its child modules**.

## 2. Example folder structure

```text
Terraform-Project/
├── Source-Directory/
│   ├── main.tf
│   └── variables.tf
└── Execution-Directory/
    └── main.tf
```

- `Source-Directory` contains reusable child-module code.
- `Execution-Directory` contains the root configuration that calls the child module.

## 3. What happens during apply?

Run commands from `Execution-Directory`:

```bash
terraform init
terraform plan
terraform apply
```

Terraform loads the module specified by the `source` argument, evaluates its resources as part of the root configuration, and records the managed resources in the root configuration's state.

With the default local backend, the state file is normally:

```text
Execution-Directory/terraform.tfstate
```

It is **not automatically created inside `Source-Directory`** just because that folder contains the module code.

## 4. Flow

```text
Execution-Directory (Root Module)
          |
          | module "app" { source = "../Source-Directory" }
          v
Source-Directory (Child Module)
          |
          | contains EC2 / S3 resource definitions
          v
Terraform plans and creates resources
          |
          v
Root configuration's state tracks those resources
          |
          v
Execution-Directory/terraform.tfstate
```

## 5. Important clarification

A module does not have an independent state file by default. Child-module resources are tracked in the state belonging to the root configuration that calls them.

If you use a remote backend, the state is stored in that backend instead of a local `terraform.tfstate` file. Its location is determined by the backend configuration.

## Interview answer

Terraform stores state for a configuration in the state backend configured for its root module. Resources created through child modules are also tracked in that same root configuration state. With the default local backend, the `terraform.tfstate` file is created in the directory where Terraform commands are run.
