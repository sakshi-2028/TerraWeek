# 📦 TerraWeek Day 5 — Modules: Reusable, Composable Infrastructure

> **Date:** Thursday, 16th July 2026

Terraform Modules are the building blocks of reusable infrastructure. Instead of duplicating `.tf` files across projects, modules allow us to write infrastructure once and use it multiple times with different configurations.

---

## 🎯 Learning Goals

* Understand what Terraform Modules are.
* Learn the difference between Root Modules and Child Modules.
* Create reusable local modules.
* Consume Terraform Registry and Git modules.
* Lock module versions for reproducible deployments.
* Use `for_each` to instantiate modules multiple times.

---

## 📝 Task 1: Modules — The Why

### What is a Module?

A **Terraform Module** is a collection of Terraform configuration files (`.tf`) that are grouped together to perform a specific task.

Examples:

* Creating an EC2 instance
* Provisioning a VPC
* Setting up an EKS Cluster
* Deploying a complete application stack

Every Terraform configuration has at least one module.

### What is the Root Module?

The directory where we execute Terraform commands (`terraform init`, `terraform plan`, `terraform apply`) is called the **Root Module**.

Example:

```text
example/
├── main.tf
├── variables.tf
├── outputs.tf
└── modules/
    └── ec2_instance/
```

* `example/` → Root Module
* `modules/ec2_instance/` → Child Module

---

### Benefits of Terraform Modules

- **Reusability** – Write the code once and use it multiple times, saving time and reducing errors.

- **Consistency** – Ensures the same infrastructure is created across all environments (Dev, Staging, Production).

- **Encapsulation** – Groups related Terraform resources into a single module, making the code organized and easier to manage.

- **Versioning** – Allows you to use a specific version of a module, ensuring stable and predictable deployments.

- **Testing** – Modules can be tested before using them in production, helping catch errors early.

---

## Standard Module Structure

```text
modules/
└── ec2_instance/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── README.md
```

### File Descriptions
### Files in a Well-Structured Module

- **`main.tf`** – Contains the main Terraform resources.
- **`variables.tf`** – Defines input variables for the module.
- **`outputs.tf`** – Defines the values the module returns.
- **`README.md`** – Explains how to use the module and its inputs/outputs.


---

## 📝 Task 2: Write Your Own Module

### Module Structure

```text
example/
├── main.tf
├── outputs.tf
├── variables.tf
└── modules/
    └── ec2_instance/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### Root Module

```hcl
module "web_server" {
  source                 = "./modules/ec2_instance"

  name                   = "web"
  instance_type          = "t2.micro"
  environment            = "dev"

  ami                    = data.aws_ami.al2023.id
  subnet_id              = local.subnet_id
  vpc_security_group_ids = local.security_group_ids
}
```

### Outputs

```hcl
output "web_public_ip" {
  value = module.web_server.public_ip
}
```

### Why Pass IDs as Inputs?

Instead of performing lookups inside the module:

```hcl
data "aws_subnet" "example" {
  ...
}
```

We pass them as inputs:

```hcl
subnet_id = local.subnet_id
```

Benefits:

* Better performance
* Improved reusability
* Avoid duplicate data source calls
* Easier testing

---

## Terraform Commands

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

### Initialize Module

```bash
terraform init
```

Output:

```text
Initializing modules...
- web_server in modules/ec2_instance
```

---

## 📝 Task 3: Modular Composition using `for_each`

Terraform allows us to create multiple resources using the same module.

### Example

```hcl
module "servers" {
  source   = "./modules/ec2_instance"

  for_each = toset([
    "app",
    "worker",
    "cache"
  ])

  name                   = each.key
  instance_type          = "t2.micro"
  environment            = "dev"

  ami                    = data.aws_ami.al2023.id
  subnet_id              = local.subnet_id
  vpc_security_group_ids = local.security_group_ids
}
```

### Terraform Plan

```text
+ module.servers["app"]
+ module.servers["worker"]
+ module.servers["cache"]
```

### Advantages

* Cleaner code.
* Easy scaling.
* Reduced duplication.
* Better maintainability.

---

## 📝 Task 4: Consume a Terraform Registry Module

Terraform Registry provides community-maintained modules.

### Example: AWS VPC Module

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "terraweek-vpc"
  cidr = "10.0.0.0/16"

  azs = [
    "us-east-1a",
    "us-east-1b"
  ]

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}
```

### Why Use Registry Modules?

* Production ready
* Community tested
* Frequently updated
* Saves development time

---

## 📝 Task 5: Module Version Locking

Version locking ensures predictable and reproducible deployments.

### Registry Version Examples

#### Exact Version

```hcl
version = "5.1.2"
```

#### Pessimistic Constraint

```hcl
version = "~> 5.0"
```

#### Greater Than or Equal

```hcl
version = ">= 5.0"
```

#### Range Constraint

```hcl
version = ">= 5.0, < 6.0"
```

---

## Git Module Source

### Git Tag

```hcl
module "example" {
  source = "git::https://github.com/org/repo.git//path?ref=v1.2.0"
}
```

### Git Branch

```hcl
module "example" {
  source = "git::https://github.com/org/repo.git//path?ref=main"
}
```

### Git Commit SHA

```hcl
module "example" {
  source = "git::https://github.com/org/repo.git//path?ref=6d7f12ab34cd5678efgh9012"
}
```

---

## Why Pin Module Versions?

Without version pinning:

* Builds may become inconsistent.
* Breaking changes can appear unexpectedly.
* Teams may use different module versions.

With version pinning:

* Reproducible infrastructure.
* Stable deployments.
* Easier troubleshooting.
* Better change management.

---

## 🧠 Pessimistic Constraint (`~>`) Cheatsheet

| Constraint | Meaning                               |
| ---------- | ------------------------------------- |
| `~> 5.0`   | Allows `5.x` but not `6.0`.           |
| `~> 5.1.0` | Allows `5.1.x` but not `5.2.0`.       |
| `~> 4.7`   | Allows `4.7.x` and above until `5.0`. |

Examples:

```hcl
version = "~> 5.0"
```

Accepts:

```text
5.0.0
5.1.0
5.5.3
```

Rejects:

```text
6.0.0
```

---

## 🍫 Bonus Tasks

### Add Input Validation

```hcl
variable "instance_type" {
  type = string

  validation {
    condition     = contains(["t2.micro", "t3.micro"], var.instance_type)
    error_message = "Invalid instance type."
  }
}
```

---

### Publish Module to GitHub

```hcl
module "web" {
  source = "git::https://github.com/sakshi-2028/terraform-ec2-module.git?ref=v1.0.0"
}
```

---

### Module Composition

Passing outputs between modules:

```hcl
module "network" {
  source = "./modules/vpc"
}

module "compute" {
  source    = "./modules/ec2"
  subnet_id = module.network.public_subnet_id
}
```

---

## Example Multi-Environment Architecture

```text
my_app_infra_module
│
├── dev
├── stg
└── prd
```

Environment Configuration:

| Environment | Instance Type |
| ----------- | ------------- |
| dev         | t2.micro      |
| stg         | t3.small      |
| prd         | t3.medium     |

---

## Key Takeaways

* Modules are reusable Terraform components.
* Every Terraform project has a Root Module.
* Child Modules improve maintainability.
* Use `for_each` for scalable infrastructure.
* Always lock module versions.
* Registry modules save time and follow best practices.
* Module composition enables building complex infrastructures.

---

## Conclusion

Terraform Modules are essential for managing infrastructure at scale. They promote code reuse, consistency, maintainability, and reliability. By combining local modules, registry modules, version pinning, and `for_each`, we can build production-ready and scalable Infrastructure as Code solutions.

---

### Commands Used

```bash
terraform init
terraform validate
terraform fmt
terraform plan
terraform apply
terraform destroy
```

---

### Connect With Me

* GitHub: `https://github.com/sakshi-2028`
* LinkedIn: `https://www.linkedin.com/in/sakshi-upadhyay-05160b228`

---

### Tags

```text
#Terraform
#TerraformModules
#InfrastructureAsCode
#AWS
#DevOps
#TerraWeekChallenge
#TrainWithShubham
```
