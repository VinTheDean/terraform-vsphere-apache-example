Terraform Module to deploy a Linux VM in vSphere

Not intended for production use.  Just showcasing module creationg in Terraform registry

```hcl

terraform {
  
}

module "apache"{
  source = "./modules/terraform-vsphere-apache-example"
  cpu_count = "2"
  hostname = "tf-apache"
  vsphere_user = ""
  vsphere_password = "!"
  vsphere_hostname = ""
}
 



```