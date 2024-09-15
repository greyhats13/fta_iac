# Project service arguments
variable "project_id" {
  description = "Project ID"
  type        = string
}

# services arguments
variable "services" {
  description = "Project services"
  type        = map(string)
  default     = {}
}

variable "disable_dependent_services" {
  description = "Disable dependent services"
  type        = bool
  default     = true
}