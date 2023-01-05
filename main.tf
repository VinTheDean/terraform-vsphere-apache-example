

#### RETRIEVE DATA INFORMATION ON VCENTER ####
data "vsphere_datacenter" "datacenter" {
  name = "HomeLab"
}

data "vsphere_datastore" "datastore" {
  name          = "ds-esx02"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = "Basement"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "template" {
  name          = "UBUNTU-TMP"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_content_library" "library" {
  name = "VRATemplates"
}

data "template_file" "user_data" {
  template = file("${abspath(path.module)}/userdata.yaml")
}

data "template_cloudinit_config" "example" {
  gzip = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content = <<-EOF
      #cloud-config
      packages:
        - httpd
      runcmd:
        - systemctl start httpd
        - sudo systemctl enable httpd
      EOF
  }
}

#### VM CREATION ####
resource "vsphere_virtual_machine" "vm" {
  name             = var.hostname
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 2
  memory   = 2048
  annotation = "My VM Note"
  guest_id  = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }
  disk {
    label = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned

  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = var.hostname
        domain    = "vtech.local"
      }
      #network_interface {
      #  ipv4_address = "192.168.1.101"
      #  ipv4_netmask = 24
      #}
      #ipv4_gateway = "192.168.1.1"
      network_interface {
        
      }
    }
  }

  /* extra_config = {
    "guestinfo.userdata"          = base64encode(file("${path.module}/userdata.yaml"))
    "guestinfo.userdata.encoding" = "base64"
  }*/

  provisioner "remote-exec" { 
    inline = ["sudo dnf -y install cloud-init"] 
    connection {
      type     = "ssh"
      user     = ""
      password = ""
      host     = self.guest_ip_addresses[0]
    }
  }



   extra_config = {
    "guestinfo.userdata" = data.template_cloudinit_config.example.rendered
    "guestinfo.userdata.encoding" = "gzip+base64"
  }
}



