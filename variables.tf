# Read keys/tokens from env
variable "DO_TOKEN" {
  type = string
}

variable "DO_SPACES_ACCESS_KEY" {
  type = string
}

variable "DO_SPACES_SECRET_KEY" {
  type = string
}

variable "do_region" {
  type = string
  default = "nyc1"
}

variable "project_name" {
  type = string
  default = "dsm-k8"
}