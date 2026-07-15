# 🌱 TerraWeek Day 1 — My Notes & Solutions

**Date:** 15 July 2026
**Machine:** macOS (Apple Silicon, darwin_arm64) · **Terraform:** v1.15.8

---

## Task 1: Understand IaC & Terraform

### What is Infrastructure as Code (IaC)?

Infrastructure as Code means defining your servers, networks, storage, and other infrastructure in **text files (code)** instead of creating them manually by clicking around a cloud console.

Problems it solves compared to "ClickOps":

- **Repeatable** — the same config produces the same infrastructure every time; no "it worked on my account" surprises.
- **Version controlled** — configs live in Git, so you get history, code review, and easy rollback.
- **Documented by default** — the code *is* the documentation of what exists and why.
- **Scalable** — creating 50 identical environments is a loop, not 50 afternoons of clicking.
- **Fewer human errors** — no forgotten checkbox or wrong region selected at 2 AM.

### What is Terraform, and why is it so popular?

Terraform is an **IaC tool by HashiCorp** that lets you describe infrastructure declaratively in HCL, then creates/updates/deletes real resources to match that description.

Why it's popular:

- **Declarative** — you describe the *desired end state*; Terraform figures out the steps.
- **Provider-agnostic** — one tool and one language for AWS, Azure, GCP, Kubernetes, GitHub, Docker, and thousands more.
- **Plan before apply** — you always get a preview of changes before anything is touched.
- **State tracking** — Terraform knows what it created, so it can update or destroy it cleanly.
- **Huge ecosystem** — thousands of providers and reusable modules in the public registry.

### Terraform vs the alternatives (one-liners)

| Tool | Compared to Terraform |
|---|---|
| **OpenTofu** | Open-source fork of Terraform (created after the license change) — nearly identical syntax and workflow, community/Linux Foundation governed. |
| **Pulumi** | Same idea, but you write real programming languages (Python, TypeScript, Go) instead of HCL. |
| **CloudFormation** | AWS's native IaC — works only with AWS, while Terraform is multi-cloud. |
| **Ansible** | Primarily a *configuration management* tool (installing/configuring software on existing servers); Terraform is for *provisioning* the infrastructure itself. They're often used together. |

---

## Task 2: Install Terraform

```text
$ terraform version
Terraform v1.15.8
on darwin_arm64
```

📸 *Screenshot: `terraform version` + `terraform -help` output* ✅ (captured)

VS Code extension: **HashiCorp Terraform** installed for syntax highlighting, autocomplete, and the language server.

---

## Task 3: Six Crucial Terraform Terminologies

1. **Provider** — a plugin that teaches Terraform how to talk to a specific platform.
   *Example: `hashicorp/local` lets Terraform manage files on my machine; `hashicorp/aws` would manage AWS.*

2. **Resource** — a single piece of infrastructure Terraform creates and manages.
   *Example: `resource "local_file" "greeting" { ... }` creates a file; on AWS it could be an EC2 instance.*

3. **State** — Terraform's record (the `terraform.tfstate` file) of everything it manages, used to map config to real-world objects.
   *Example: after apply, my state stored the generated pet name `certain-manatee` so future plans know it already exists.*

4. **Plan** — a dry-run preview showing exactly what Terraform *would* create, change, or destroy.
   *Example: my plan showed `Plan: 2 to add, 0 to change, 0 to destroy` before I applied.*

5. **HCL** — HashiCorp Configuration Language, the human-friendly declarative syntax `.tf` files are written in.
   *Example: `length = 2` inside a `resource` block.*

6. **Module** — a reusable, packaged group of Terraform configuration you can call like a function.
   *Example: a `vpc` module you call with different CIDR ranges for dev and prod.*

---

## Task 4: My First Terraform Config (zero cloud cost!)

The config uses only the `random` and `local` providers — no credentials, no bill.

### The workflow I ran

```bash
cd day01/example
terraform init      # downloaded hashicorp/random v3.9.0 + hashicorp/local v2.9.0
terraform fmt       # formatted the .tf files
terraform validate  # "Success! The configuration is valid."
terraform plan      # Plan: 2 to add, 0 to change, 0 to destroy
terraform apply     # typed "yes" → Apply complete! Resources: 2 added
cat greeting.txt
terraform destroy   # typed "yes" → Destroy complete! Resources: 2 destroyed
```

### Results

```text
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:
file_path = "./greeting.txt"
pet_name  = "certain-manatee"
```

```text
$ cat greeting.txt
Hello from TerraWeek 2026! 🚀
Your infra pet name is: certain-manatee
```

### Clean up

```text
$ terraform destroy
random_pet.name: Refreshing state... [id=certain-manatee]
local_file.greeting: Refreshing state... [id=0c13658d4f6e72c4993aeb0b5e3ab4354618f2e4]

Plan: 0 to add, 0 to change, 2 to destroy.

Do you really want to destroy all resources?
  Enter a value: yes

local_file.greeting: Destroying... [id=0c13658d4f6e72c4993aeb0b5e3ab4354618f2e4]
local_file.greeting: Destruction complete after 0s
random_pet.name: Destroying... [id=certain-manatee]
random_pet.name: Destruction complete after 0s

Destroy complete! Resources: 2 destroyed.
```

After destroy, `greeting.txt` is deleted and `terraform.tfstate` is empty (`"resources": []`) — Terraform cleaned up everything it created.

### Screenshot checklist

📸 `terraform version` + `terraform -help` ✅
📸 `terraform init` ✅
📸 `terraform validate` + `terraform plan` ✅
📸 `terraform apply` with outputs ✅
📸 `cat greeting.txt` + `terraform destroy` ✅

---

## 🍫 Bonus

### Tab completion

```bash
terraform -install-autocomplete   # then restart the shell (zsh)
```

### The `.terraform.lock.hcl` lock file

Created by `terraform init`, it **pins the exact provider versions and their checksums** (e.g. `random v3.9.0`, `local v2.9.0`). It should be **committed to Git** so every teammate — and CI — gets the *same* provider versions, even if the version constraint (`~> 2.5`) would allow newer ones. It's the same idea as `package-lock.json` in Node.js.

### OpenTofu

OpenTofu (`brew install opentofu`, then `tofu init` / `tofu plan` / `tofu apply`) is a drop-in fork — the same HCL config runs unchanged; the main differences are governance (Linux Foundation), the MPL open-source license, and some newer features like state encryption.

---

## Key takeaways

- The core loop is **write → init → plan → apply → destroy** — everything else builds on this.
- `terraform plan` before `apply` is the safety net: never skip reading it.
- State is the single source of truth for what Terraform manages — protect it.
- You can learn Terraform for free: `local` + `random` providers cost nothing.

#TrainWithShubham #TerraWeekChallenge
