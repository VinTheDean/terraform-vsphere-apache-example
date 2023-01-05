terraform {
   required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = ">= 2.2.0"
    }
  }
}

provider "vsphere" {
  # Configuration options
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_hostname


  allow_unverified_ssl = true
}
