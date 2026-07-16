# 🧩 TerraWeek Day 2 — HCL Deep Dive: Variables, Types & Expressions

> **Date:** 15 July 2026
> **Terraform Version:** v1.15.8
> **Provider:** `kreuzwerker/docker`

Today was all about learning the language behind Terraform—HCL (HashiCorp Configuration Language)—and using variables, expressions, locals, outputs, and functions to build reusable infrastructure.

---

## 📂 Repository Structure

```text
day02/
├── README.md
├── variables.tf
├── local.tf
├── outputs.tf
├── solutions.md
├── example/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
└── screenshots/
    ├── 01-variables-tf.png
    ├── console.png
    ├── init_plan.png
    ├── apply.png
    └── terraform-destroy.png
```

### Quick Navigation

* [`variables.tf`](./variables.tf)
* [`local.tf`](./local.tf)
* [`outputs.tf`](./outputs.tf)
* [`solutions.md`](./solutions.md)
* [`example/main.tf`](./example/main.tf)
* [`example/variables.tf`](./example/variables.tf)
* [`example/outputs.tf`](./example/outputs.tf)
* [`example/terraform.tfvars`](./example/terraform.tfvars)
* [`screenshots/`](./screenshots)

---

## Task 1: Master HCL Syntax

### Anatomy of a Block

Terraform uses blocks to define infrastructure.

```hcl
block_type "label_one" "label_two" {
  argument = value
}
```

Example:

```hcl
resource "docker_container" "web" {
  name  = "tws-web"
  image = docker_image.nginx.image_id
}
```

* `resource` → Block type
* `docker_container` → First label
* `web` → Second label
* `name` and `image` → Arguments

---

### Argument vs Block

| Argument        | Block                         |
| --------------- | ----------------------------- |
| Uses `=`        | Uses `{}`                     |
| Assigns a value | Contains nested configuration |

Example:

```hcl
resource "docker_container" "web" {
  name = "tws-web"

  ports {
    internal = 80
    external = 8080
  }
}
```

* `name` is an argument.
* `ports` is a block.

---

### Expressions

#### String Interpolation

```hcl
"tws-${var.environment}"
```

#### References

```hcl
docker_image.nginx.image_id
var.container_name
local.name_prefix
```

#### Operators

```hcl
var.external_port > 1024
var.environment == "prod"
```

---

## Task 2: Variables, Types & Validation

Source: [`variables.tf`](./variables.tf)

Terraform supports several variable types.

| Category   | Type            | Example          |
| ---------- | --------------- | ---------------- |
| Primitive  | `string`        | `container_name` |
| Primitive  | `number`        | `external_port`  |
| Primitive  | `bool`          | `enable_logging` |
| Collection | `list(string)`  | `regions`        |
| Collection | `map(string)`   | `extra_labels`   |
| Collection | `set(string)`   | `allowed_ports`  |
| Structural | `object({...})` | `server_config`  |
| Structural | `tuple([...])`  | `tuple_example`  |

### Validation Example

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

### Sensitive Variable

```hcl
variable "db_password" {
  type      = string
  sensitive = true
}
```

---

## Task 3: Locals, Outputs & Functions

### Locals

Source: [`local.tf`](./local.tf)

```hcl
locals {
  name_prefix = "tws-${var.environment}"

  common_tags = merge(
    { project = "terraweek" },
    var.extra_labels
  )
}
```

---

### Outputs

Source: [`outputs.tf`](./outputs.tf)

```hcl
output "access_url" {
  value = format("http://localhost:%d", var.external_port)
}
```

---

### Built-in Functions

| Function   | Example                                   |
| ---------- | ----------------------------------------- |
| `upper()`  | `upper("terraweek")`                      |
| `merge()`  | `merge({a=1}, {b=2})`                     |
| `join()`   | `join("-", ["tws", "terraweek", "2026"])` |
| `length()` | `length(["a","b","c"])`                   |
| `format()` | `format("%s-%s", "dev", "01")`            |

### Terraform Console

```bash
terraform console
```

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
```

See: [`screenshots/console.png`](./screenshots/console.png)

---

## Task 4: Build Something Real (Docker Provider)

Source: [`example/`](./example)

### Initialize Terraform

```bash
cd example
terraform init
```

### Plan

```bash
terraform plan \
-var 'container_name=tws-web' \
-var 'external_port=8080'
```

### Apply

```bash
terraform apply \
-var 'container_name=tws-web' \
-var 'external_port=8080'
```

### Verify

```bash
docker ps
curl http://localhost:8080
```

Visit:

```text
http://localhost:8080
```

Expected:

```text
Welcome to nginx!
```

### Outputs

```bash
terraform output
```

### Destroy

```bash
terraform destroy \
-var 'container_name=tws-web' \
-var 'external_port=8080'
```

---

## Using `terraform.tfvars`

Source: [`example/terraform.tfvars`](./example/terraform.tfvars)

```hcl
container_name = "tws-web"
external_port  = 8080
```

Now Terraform automatically loads the values:

```bash
terraform plan
terraform apply
terraform output
terraform destroy
```

---

## `terraform.tfvars` vs `-var`

| `-var`             | `terraform.tfvars`           |
| ------------------ | ---------------------------- |
| Manual input       | Auto-loaded                  |
| Useful for testing | Useful for daily development |
| Longer commands    | Cleaner commands             |

---

## Variable Precedence

```text
-var / -var-file
   ↓
*.auto.tfvars
   ↓
terraform.tfvars
   ↓
TF_VAR_ environment variables
   ↓
default values
```

---

## Bonus

### For Expression

```hcl
[for s in var.names : upper(s)]
```

### Conditional Expression

```hcl
var.environment == "prod"
? "t3.medium"
: "t3.micro"
```

### Optional Object Attribute

```hcl
type = object({
  name = string
  size = optional(string, "small")
})
```

---

## Screenshots

| Screenshot        | Link                                                           |
| ----------------- | -------------------------------------------------------------- |
| Variables         | [`01-variables-tf.png`](./screenshots/01-variables-tf.png)     |
| Terraform Console | [`console.png`](./screenshots/console.png)                     |
| Init & Plan       | [`init_plan.png`](./screenshots/init_plan.png)                 |
| Apply             | [`apply.png`](./screenshots/apply.png)                         |
| Destroy           | [`terraform-destroy.png`](./screenshots/terraform-destroy.png) |

---

## ✅ Day 2 Complete

* Learned HCL blocks, arguments, and expressions.
* Implemented all major Terraform variable types.
* Added validation and sensitive variables.
* Used locals and outputs.
* Explored Terraform built-in functions.
* Built and destroyed a Docker-based Nginx container.
* Compared `terraform.tfvars` with `-var`.
* Learned Terraform variable precedence.

---

### Connect

* GitHub: `sakshi-2028`

**#TrainWithShubham #TerraWeekChallenge #Terraform #DevOps**
