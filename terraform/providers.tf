# Providers needed by the project, with pinned versions.
terraform {
  required_version = ">= 1.6"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54"
    }
  }
}

# Credentials come from the OS_* environment variables (source ~/devstack/asl-openrc).
provider "openstack" {}
