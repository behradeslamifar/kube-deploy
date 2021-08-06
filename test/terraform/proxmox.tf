terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }
}

# Proxmox Connection Information
variable "pve_information" {
  type = object({
    user     = string
    password = string
    host     = string
  })
  default = {
    user     = "root"
    password = "password"
    host     = "192.168.1.100"
  }  
  sensitive = true
}

variable "vm_count" {
  type    = number
  default = 3
}

variable "domain_name" {
  type    = string
  default = "linuxmotto.ir"
} 

data "template_file" "user_data" {
  count    = var.vm_count
  template = file("${path.module}/files/user_data.cfg")
  vars = {
    pubkey   = file("~/.ssh/id_rsa.pub")
    hostname = "master-${count.index}"
    fqdn     = "master-${count.index}.${var.domain_name}"
  }
}

resource "local_file" "cloud_init_user_data_file" {
  count    = var.vm_count
  content  = data.template_file.user_data[count.index].rendered
  filename = "${path.module}/files/user_data_${count.index}.cfg"
}

resource "null_resource" "cloud_init_config_files" {
  count = var.vm_count
  connection {
    type     = "ssh"
    user     = "${var.pve_information.user}"
    password = "${var.pve_information.password}"
    host     = "${var.pve_information.host}"
  }

  provisioner "file" {
    source      = local_file.cloud_init_user_data_file[count.index].filename
    destination = "/var/lib/vz/snippets/user_data_master-${count.index}.yml"
  }
}

provider "proxmox" {
    pm_tls_insecure = true
    pm_api_url = "https://${var.pve_information.host}:8006/api2/json"
    pm_password = var.pve_information.password
    pm_user = "${var.pve_information.user}@pam"
}

resource "proxmox_vm_qemu" "proxmox_vm" {
  depends_on = [
    null_resource.cloud_init_config_files,
  ]

  count             = var.vm_count
  name              = "master-${count.index}"
  hotplug	    = "network,disk,usb"
  bios		    = "seabios"
  boot		    = "c"
  additional_wait   = 15
  numa		    = false
  define_connection_info = false
  onboot	    = true
  clone_wait	    = 15
  guest_agent_ready_timeout = 600
  force_create	    = false
  kvm		    = true
  balloon	    = 0
  agent 	    = 1
  target_node       = "pve1"
  clone             = "ubuntu2004-k8s-1205"
  full_clone	    = true
  pool		    = ""
  cores             = 2
  sockets           = 1
  cpu               = "kvm64"
  vcpus		    = 0
  memory            = 2048
  scsihw            = "virtio-scsi-pci"
  bootdisk          = "scsi0"
  os_type	    = "cloud-init"

  ipconfig0 = "ip=192.168.1.15${count.index + 1}/24,gw=192.168.1.1"
  nameserver = "8.8.8.8"
  cicustom = "user=local:snippets/user_data_master-${count.index}.yml"
  /* Create the cloud-init drive on the "local-lvm" storage */
#  cloudinit_cdrom_storage = "local-lvm"

  lifecycle {
      ignore_changes  = [
        network,
      ]
    }

  network {
      model     = "virtio"
      bridge    = "vmbr0"
      firewall  = false
      link_down = false
  }
}
