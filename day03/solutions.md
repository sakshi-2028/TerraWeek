# ☁️ TerraWeek Day 3 — Providers, Resources & Your First Cloud Infra

**Date:** 15 July 2026 · **Terraform:** v1.15.8 · **Cloud:** AWS (`hashicorp/aws ~> 6.0`) · **Region:** us-east-1

Today I touched **real cloud infrastructure** — configured the AWS provider, used **data sources** and **meta-arguments**, and built a small **VPC + EC2** network stack.

---

## ⚙️ Setup: Authenticate AWS

I configured the AWS CLI so Terraform can use my credentials (never hard-code keys in `.tf` files!):

```bash
aws configure          # stores keys in ~/.aws/credentials
aws sts get-caller-identity   # confirms I'm authenticated

## 🗺️ The stack I built

```
Internet ──▶ [IGW] ──▶ [Route Table] ──▶ [ Public Subnet ] ──▶ [SG] ──▶ [EC2]
                                          (inside the VPC)
```

| Block | What it is |
|---|---|
| **VPC** | My own private network (`10.0.0.0/16`) |
| **Subnet** | A slice of the VPC (`10.0.1.0/24`) in one AZ |
| **Internet Gateway** | The door to the public internet |
| **Route Table** | Sends internet traffic through the IGW |
| **Security Group** | Firewall — allows HTTP (port 80) in |
| **EC2 Instance** | The VM running Nginx |

---

## Task 1: Providers & Version Pinning

```hcl
terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"     # pessimistic operator
    }
  }
}
```

**Why version pinning matters:** without it, `terraform init` could grab a newer provider that changes behavior and breaks my config. Pinning keeps builds **predictable and repeatable** across my machine, teammates, and CI.

**What `~>` (pessimistic operator) does:** allows patch/minor updates but blocks breaking major ones.
- `~> 6.0` → any `6.x` (6.1, 6.9…) but **not** 7.0
- `~> 6.1.0` → any `6.1.x` but **not** 6.2

**Bonus — provider alias** (used to work with two regions at once):
```hcl
provider "aws" {
  alias  = "east"
  region = "us-east-1"
}
provider "aws" {
  alias  = "west"
  region = "us-west-2"
}
# use with: provider = aws.west
```
Use an alias when one config manages resources in **multiple regions or accounts**.

---

## Task 2: Resources vs Data Sources

| | Resource | Data Source |
|---|---|---|
| **Does what** | **Creates & manages** infra | **Only reads** existing info |
| **Keyword** | `resource "..." {}` | `data "..." {}` |
| **Example in my config** | `aws_vpc`, `aws_instance` | `aws_ami`, `aws_availability_zones` |

My config uses a **data source** to auto-find the latest Amazon Linux 2023 AMI (so I never hard-code an AMI ID):

```hcl
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}
# used as: ami = data.aws_ami.al2023.id
```

**In short:** resources **create**, data sources **look up**.

---

## Task 3: Provision the Cloud Stack

**1. `terraform init`** — downloads the AWS provider:

<img width="888" height="621" alt="WhatsApp Image 2026-07-17 at 2 35 44 PM" src="https://github.com/user-attachments/assets/1c720c0c-0cd3-4c8c-bd5d-b4948cc333e0" />


**2. `terraform validate`** — config is valid:

**3. `terraform plan`** — preview all the resources it will create:

<img width="1111" height="1009" alt="WhatsApp Image 2026-07-17 at 2 35 59 PM" src="https://github.com/user-attachments/assets/2511cc4a-1465-4ae2-ab70-061b9d05c0fd" />

**4. `terraform apply`** — build the real infrastructure (typed `yes`):

**5. `terraform state list`** — everything Terraform now manages:

```text
data.aws_ami.al2023
data.aws_availability_zones.available
aws_instance.web
aws_internet_gateway.igw
aws_route_table.public
aws_route_table_association.public
aws_security_group.web
aws_subnet.public
aws_vpc.main
```

**6. AWS Console** — my resources really exist (VPC / EC2):

<img width="1600" height="461" alt="WhatsApp Image 2026-07-17 at 2 36 04 PM" src="https://github.com/user-attachments/assets/c4b59066-8743-48f0-ac8f-34f77a40e5ab" />

<img width="1600" height="495" alt="WhatsApp Image 2026-07-17 at 2 36 07 PM" src="https://github.com/user-attachments/assets/7cb20450-c165-41c9-9cba-91e61a0cadc2" />

<img width="1600" height="774" alt="WhatsApp Image 2026-07-17 at 2 36 11 PM" src="https://github.com/user-attachments/assets/6d11437a-944e-4d51-ad2d-9e1c4e55b8c7" />

<img width="1136" height="771" alt="WhatsApp Image 2026-07-17 at 2 36 19 PM" src="https://github.com/user-attachments/assets/6e69eea9-210f-4ff0-8dd3-f6b7dfd40a7a" />

---

## Task 4: Meta-Arguments in Action

| Meta-argument | What it does | Example |
|---|---|---|
| **`count`** | Create N identical copies | `count = 2` → 2 EC2s, indexed `[0]`, `[1]` |
| **`for_each`** | Create from a map/set (named) | `for_each = toset(["web","api"])` |
| **`depends_on`** | Force explicit ordering | `depends_on = [aws_internet_gateway.igw]` |
| **`lifecycle`** | Control create/update/delete behavior | see below |

**My config already uses `lifecycle`** on the EC2 instance:
```hcl
lifecycle {
  create_before_destroy = true   # make the new one before killing the old
}
```

Other lifecycle options I learned:
- `prevent_destroy = true` — blocks accidental deletion.
- `ignore_changes = [tags]` — ignore drift on certain attributes.

**`count` vs `for_each`:**
- **`count`** → N identical, interchangeable resources.
- **`for_each`** → each has a stable name/key, so deleting one won't reindex the others. Preferred for named things.

---

<img width="1600" height="485" alt="WhatsApp Image 2026-07-17 at 2 36 23 PM" src="https://github.com/user-attachments/assets/ffb6c2f1-361b-4753-8dd7-1052bfc57862" />

<img width="1600" height="564" alt="WhatsApp Image 2026-07-17 at 2 36 27 PM" src="https://github.com/user-attachments/assets/559d5464-0b55-4462-b00a-11355946ecaa" />

<img width="1244" height="690" alt="WhatsApp Image 2026-07-17 at 2 36 33 PM" src="https://github.com/user-attachments/assets/ed67ecd9-108a-469c-93af-91e54e645aff" />

<img width="1128" height="398" alt="WhatsApp Image 2026-07-17 at 2 36 37 PM" src="https://github.com/user-attachments/assets/ba31c27a-d151-4b74-bb37-3245dd93d801" />



## Task 5: Update & Destroy

**Update:** I changed a tag / `instance_type` and ran `terraform plan` to read the diff:

- A **tag change** = in-place update (`~`).
- Changing `instance_type` on some settings = **replace** (`-/+`, force new resource).

Reading the diff symbols:
- `+` create · `-` destroy · `~` update in place · `-/+` replace

**Destroy** — always clean up to avoid bills:
```bash
terraform destroy   # type: yes
```

<img width="1136" height="771" alt="WhatsApp Image 2026-07-17 at 2 36 19 PM" src="https://github.com/user-attachments/assets/17c1fd6c-3980-4845-8df6-8b4b755db192" />

```text
Destroy complete! Resources: X destroyed.
```

---

## 🍫 Bonus

- **`terraform graph`** — visualize the dependency graph:
  ```bash
  terraform graph | dot -Tpng > graph.png
  ```
- **User-data** — my EC2 already installs Nginx on boot via a startup script.
- **`moved` block** — rename a resource without destroying it.

---

## ✅ Day 3 Complete

- Configured the AWS provider with version pinning (`~> 6.0`) and understood the `~>` operator.
- Learned the difference: **resources create, data sources read**.
- Built a full VPC + subnet + IGW + route table + security group + EC2 stack.
- Practiced meta-arguments: `count`, `for_each`, `depends_on`, `lifecycle`.
- Read plan diffs (in-place vs replace) and destroyed everything to avoid charges.

#TrainWithShubham #TerraWeekChallenge
