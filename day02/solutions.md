# 🧩 TerraWeek Day 2 — HCL Deep Dive: Variables, Types & Expressions

**Date:** 15 July 2026 · **Terraform:** v1.15.8 · **Provider:** kreuzwerker/docker

Today is about the **language** behind Terraform — HCL — so configs become flexible and reusable using variables, types, locals, outputs, and functions.

---

## Task 1: HCL Syntax Basics

### Anatomy of a block

```hcl
block_type "label_one" "label_two" {
  argument = value
}
```

Real example from my config:

```hcl
resource "docker_container" "web" {   # block_type="resource", labels="docker_container" & "web"
  name  = "tws-web"                   # argument = value
  image = docker_image.nginx.image_id # reference to another resource
}
```

### Argument vs. Block

- **Argument** → assigns a value: `external_port = 8080` (has an `=`).
- **Block** → a container with `{ }` that holds arguments or more blocks: `ports { ... }` (no `=`).

### Expressions

- **String interpolation** — insert a value into a string: `"tws-${var.environment}"` → `tws-dev`
- **Reference** — point to another object's attribute: `docker_image.nginx.image_id`
- **Operators** — math/logic/comparison: `var.external_port > 1024 && var.external_port < 65535`

---

## Task 2: Variables, Types & Validation

My `variables.tf` covers primitive and collection types, plus a `default`, a `validation` block, and validation rules.

![variables.tf code](screenshots/01-variables-tf.png)

**Types I used:**

| Type category | Type | Variable |
|---|---|---|
| Primitive | `string` | `container_name`, `environment`, `image_tag` |
| Primitive | `number` | `external_port` |
| Collection | `map(string)` | `extra_labels` |

**Validation example** — only allows valid environments:

```hcl
variable "environment" {
  type    = string
  default = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}
```

If I pass `environment=production`, Terraform stops with my error message before doing anything. ✅

---

## Task 3: Locals, Outputs & Functions

### Locals (compute once, reuse everywhere)

```hcl
locals {
  name_prefix   = "tws-${var.environment}"          # uses interpolation
  common_labels = merge({ project = "terraweek" }, var.extra_labels)  # uses merge()
}
```

### Outputs (expose useful values)

```hcl
output "access_url" {
  value = format("http://localhost:%d", var.external_port)  # uses format()
}
```

### Built-in functions — tested live with `terraform console`

![terraform console functions](screenshots/02-terraform-console.png)

```text
> upper("terraweek")
"TERRAWEEK"

> merge({a=1}, {b=2})
{
  "a" = 1
  "b" = 2
}

> join("-", ["tws", "terraweek", "2026"])
"tws-terraweek-2026"

> length(["a","b","c"])
3
```

Functions used: **`upper()`**, **`merge()`**, **`join()`**, **`length()`**, **`format()`** — more than the 3 required. ✅

---

## Task 4: Build Something Real (Docker — no cloud cost) 🐳

The config pulls an Nginx image and runs a container, all driven by variables.

**1. `terraform init`** — downloads the docker provider:

![terraform init](screenshots/03-terraform-init.png)

**2. `terraform plan`** — preview with variables passed via `-var`:

```bash
terraform plan -var 'container_name=tws-web' -var 'external_port=8080'
```

![terraform plan](screenshots/04-terraform-plan.png)

**3. `terraform apply`** — create the container:

```bash
terraform apply -var 'container_name=tws-web' -var 'external_port=8080'
```

![terraform apply](screenshots/05-terraform-apply.png)

**4. Container running** — Nginx welcome page at http://localhost:8080:

![nginx running in browser](screenshots/06-nginx-browser.png)

**5. `terraform output`** — the values my config exposes:

![terraform output](screenshots/07-terraform-output.png)

**6. `terraform destroy`** — clean up:

```bash
terraform destroy -var 'container_name=tws-web' -var 'external_port=8080'
```

![terraform destroy](screenshots/08-terraform-destroy.png)

### tfvars vs -var flags

Instead of typing `-var` every time, I created a `terraform.tfvars` file:

```hcl
container_name = "tws-web"
external_port  = 8080
```

Terraform **auto-loads** `terraform.tfvars`, so I could just run `terraform apply` with no flags. Much cleaner for many variables.

---

## 📊 Variable Precedence (highest wins)

```text
-var / -var-file  ▶  *.auto.tfvars  ▶  terraform.tfvars  ▶  TF_VAR_ env vars  ▶  default
```

So a `-var` on the command line always beats a `terraform.tfvars` value, which beats the `default` in `variables.tf`.

---

## 🍫 Bonus

**For expression** (transform a list):
```hcl
[for s in var.names : upper(s)]   # ["a","b"] → ["A","B"]
```

**Conditional expression** (ternary):
```hcl
var.environment == "prod" ? "t3.medium" : "t3.micro"
```

**Optional object attribute:**
```hcl
type = object({
  name = string
  size = optional(string, "small")   # optional with a default
})
```

---

## ✅ Day 2 Complete

- Learned HCL blocks, arguments, and expressions.
- Built variables with types, defaults, validation, and a map.
- Used locals, outputs, and 5 built-in functions.
- Ran a real Nginx container fully driven by variables.
- Understood variable precedence and tfvars vs -var.

#TrainWithShubham #TerraWeekChallenge
