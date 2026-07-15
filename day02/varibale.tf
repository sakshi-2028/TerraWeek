# -------------------------------
# Primitive Types
# -------------------------------

variable "user_name" {
  description = "Name of the user"
  type        = string
  default     = "user1"
}

variable "user_id" {
  description = "User ID"
  type        = number
  default     = 1
}

variable "user_valid" {
  description = "Whether the user is valid"
  type        = bool
  default     = true
}

# -------------------------------
# Collection Types
# -------------------------------

variable "user_all" {
  description = "List of all users"
  type        = list(string)

  default = [
    "user1",
    "user2",
    "user2",
    "user3"
  ]
}

variable "user_details" {
  description = "User details"
  type        = map(string)

  default = {
    Name = "Neha"
    Team = "DevOps"
  }
}

variable "user_seat" {
  description = "Set of user seat numbers"
  type        = set(string)

  default = [
    "11",
    "22",
    "33"
  ]
}

# -------------------------------
# Structural Types
# -------------------------------

variable "user_info" {
  description = "User information"
  type = object({
    name = string
    age  = number
    team = string
  })

  default = {
    name = "Neha"
    age  = 26
    team = "DevOps"
  }
}

variable "user_tuple" {
  description = "Tuple containing name, ID and active status"
  type        = tuple([string, number, bool])

  default = [
    "Neha",
    101,
    true
  ]
}

# -------------------------------
# Validation Example
# -------------------------------

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# -------------------------------
# Sensitive Variable
# -------------------------------

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}