variable "login" {
  description = "Student identifier (lowercase). Used as a name suffix: k3s-<login>, k3s-<login>-sg."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.login))
    error_message = "The login must contain only lowercase letters and digits."
  }
}

variable "image_name" {
  type    = string
  default = "ubuntu-22.04-asl"
}

variable "flavor_name" {
  type    = string
  default = "m1.medium"
}

variable "keypair_name" {
  type    = string
  default = "asl-key"
}

variable "private_network" {
  type    = string
  default = "asl-net"
}

variable "public_network" {
  type    = string
  default = "public"
}
