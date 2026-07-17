# 🚀 TerraWeek Day 6 — Advanced Terraform + Capstone Project

> **Date:** Friday, 17th July 2026

The finale of TerraWeek! 🎉 Day 6 focused on advanced Terraform concepts including Workspaces, Native Testing, Security Scanning, CI/CD automation using GitHub Actions, and Terraform Best Practices.

---

## 🎯 Learning Goals

- Manage multiple environments with Terraform Workspaces.
- Automatically format, validate, and test Terraform configurations.
- Perform security scanning before deployment.
- Automate Terraform workflows using GitHub Actions.
- Understand Terraform production best practices.
- Build a Capstone Project demonstrating all concepts learned during TerraWeek.

---

## 📁 Project Structure

```text
day06/
├── README.md
├── example/
│   ├── main.tf
│   ├── terraform.tf
│   ├── tests/
│   │   └── basic.tftest.hcl
│   └── terraform.tfstate.d/
└── .github/
    └── workflows/
        └── terraform.yml
```

---

# 📝 Task 1: Workspaces & Environments

Terraform Workspaces provide isolated state files for multiple environments.

### Commands Used

```bash
terraform workspace list
terraform workspace new staging
terraform workspace select staging
terraform workspace show
```

### Workspace List

```text
default
dev
prod
* staging
```

### Example Configuration

```hcl
locals {
  instance_type = terraform.workspace == "prod" ? "t3.medium" : "t3.micro"
}
```

### Workspace Demonstration

| Workspace | Instance Type |
|----------|---------------|
| dev | t3.micro |
| staging | t3.micro |
| prod | t3.medium |

### Workspaces vs Separate Backends

| Workspaces | Separate Backends |
|------------|------------------|
| Easy to manage | Better isolation |
| Single codebase | Better for production |
| Shared backend | Dedicated backend per environment |
| Good for small projects | Recommended for enterprise |

---

# 📝 Task 2: Quality Gates

Terraform quality checks ensure infrastructure code remains clean and reliable.

### Format Terraform Files

```bash
terraform fmt -recursive
```

### Validate Configuration

```bash
terraform validate
```

### Run Terraform Tests

```bash
cd example
terraform init
terraform test
```

### Test Result

```text
Success! 4 passed, 0 failed.
```

### Plan-Based vs Apply-Based Tests

| Type | Description |
|------|-------------|
| Plan | Evaluates resources without creating them. |
| Apply | Creates resources and validates actual infrastructure behavior. |

---

# 📝 Task 3: Security & Cost Scanning

Static analysis tools help identify Terraform security issues before deployment.

### Tool Used

- Trivy v0.72.0

### Install Trivy

```bash
brew install trivy
```

### Run Security Scan

```bash
trivy config .
```

### Result

```text
Report Summary

Target: .
Type: terraform
Misconfigurations: 0
```

### Optional Tools

```bash
checkov -d .
tfsec .
```

### Bonus: Infracost

```bash
terraform plan -out=tfplan
infracost breakdown --path .
```

---

# 📝 Task 4: CI/CD with GitHub Actions

Implemented GitHub Actions to automatically validate Terraform code.

## Workflow File

```text
.github/workflows/terraform.yml
```

### Workflow

```yaml
name: Terraform CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  terraform:
    runs-on: ubuntu-latest

    defaults:
      run:
        working-directory: ./day06/example

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Format Check
        run: terraform fmt -check -recursive

      - name: Terraform Init
        run: terraform init -backend=false

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Test
        run: terraform test

      - name: Security Scan (Trivy)
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: config
          scan-ref: ./day06/example
          exit-code: "0"
```

---

## CI/CD Pipeline Flow

```text
Push / Pull Request
        |
        v
Checkout Repository
        |
        v
Setup Terraform
        |
        v
terraform fmt -check
        |
        v
terraform init
        |
        v
terraform validate
        |
        v
terraform test
        |
        v
Trivy Security Scan
        |
        v
PASS / FAIL
```

### Step Explanation

| Step | Description |
|------|-------------|
| Checkout | Downloads repository code. |
| Setup Terraform | Installs Terraform on the runner. |
| Terraform Format Check | Verifies Terraform formatting. |
| Terraform Init | Initializes providers and modules. |
| Terraform Validate | Validates Terraform syntax. |
| Terraform Test | Executes native Terraform tests. |
| Security Scan | Detects Terraform misconfigurations using Trivy. |

---

# 📝 Task 5: Terraform Best Practices Checklist

## Remote State with Locking

- Implemented S3 backend.
- Enabled native locking.
- Never committed `.tfstate` files.

```hcl
terraform {
  backend "s3" {
    bucket       = "terraweek-2026-state-bucket-sakshi"
    key          = "day04/backend_demo/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

---

## Version Pinning

```hcl
terraform {
  required_version = ">= 1.10"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}
```

---

## Reusable Modules

- Created reusable modules during Day 5.
- Followed consistent naming conventions.

```hcl
locals {
  name_prefix = "${var.app_name}-${var.environment}"
}
```

Example:

```text
terraweek-dev
terraweek-staging
terraweek-prod
```

---

## Secrets Management

No hard-coded secrets were used.

Secrets are managed using:

- Terraform Variables
- Environment Variables
- GitHub Secrets
- AWS Profiles

```bash
export AWS_PROFILE=terraweek
```

---

## Quality Gates

Implemented:

```bash
terraform fmt -recursive
terraform validate
terraform test
trivy config .
```

---

## Cleanup

Infrastructure supports clean destruction.

```bash
terraform destroy
```

---

## Best Practices Summary

| Best Practice | Status |
|---------------|--------|
| Remote State with Locking | ✅ |
| Terraform Version Pinning | ✅ |
| Provider Version Pinning | ✅ |
| Reusable Modules | ✅ |
| Consistent Naming | ✅ |
| No Hard-Coded Secrets | ✅ |
| fmt + validate + test | ✅ |
| Security Scan | ✅ |
| GitHub Actions CI | ✅ |
| README Documentation | ✅ |
| terraform destroy | ✅ |

---

# 🚫 Provisioners

Provisioners (`remote-exec`, `local-exec`) should be used as a last resort because:

- They break Terraform's declarative model.
- Require SSH access.
- Are difficult to maintain.
- Fail unpredictably.

### Recommended Alternatives

- `user_data`
- `cloud-init`
- Packer
- Ansible
- Containers

---

# 🏗️ Capstone Project

## Project Idea

### Multi-Environment Web Application

```text
                    Internet
                        |
                        v
                  Application
                        |
                        v
                AWS Infrastructure
                        |
        --------------------------------
        |              |              |
        v              v              v
       VPC         EC2 Instance      S3
        |
        v
   Public Subnet
```

### Features

- Custom Terraform Module
- Registry Module
- Remote State
- Native Terraform Tests
- Trivy Security Scanning
- GitHub Actions CI/CD
- Multiple Environments
- Clean Destroy

### Requirements Completed

| Requirement | Status |
|------------|--------|
| Custom Module | ✅ |
| Registry Module | ✅ |
| Remote State | ✅ |
| Variables & Outputs | ✅ |
| Terraform Tests | ✅ |
| Security Scan | ✅ |
| GitHub Actions | ✅ |
| README | ✅ |
| terraform destroy | ✅ |

---

# 📸 Screenshots

Include the following screenshots:

1. `terraform workspace list`
2. `terraform workspace show`
3. `terraform test`
4. `trivy config .`
5. GitHub Actions successful run
6. Pull Request execution
7. Capstone architecture

---

# 📚 Commands Used

```bash
terraform workspace list
terraform workspace new staging
terraform workspace select staging
terraform workspace show

terraform fmt -recursive
terraform validate

terraform init
terraform test

trivy config .

terraform plan

terraform destroy
```

---

# 🎉 Conclusion

TerraWeek Day 6 provided hands-on experience with:

- Terraform Workspaces
- Native Terraform Testing
- Security Scanning
- GitHub Actions CI/CD
- Terraform Best Practices
- Capstone Design

This concludes the **TerraWeek Challenge 2026** and provides a strong foundation for building production-grade Infrastructure as Code using Terraform.

---

## 🏆 TerraWeek Status

| Day | Topic | Status |
|----|------|------|
| Day 1 | Terraform Basics | ✅ |
| Day 2 | HCL Deep Dive | ✅ |
| Day 3 | Terraform Fundamentals | ✅ |
| Day 4 | State & Backends | ✅ |
| Day 5 | Modules | ✅ |
| Day 6 | Advanced Terraform & Capstone | ✅ |

---

> **#TrainWithShubham #TerraWeekChallenge #Terraform #DevOps #AWS #InfrastructureAsCode**