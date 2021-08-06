# Test Environment
This environment is used for test `kube-deploy`

## Setup Lab with Proxmox
Requirement for Terraform lab with Proxmox
* Proxmox host: a computer with installed Proxmox.
* Management host: management host for run command and build template with following tools
  * [Packer](https://learn.hashicorp.com/tutorials/packer/get-started-install-cli#installing-packer)
  * [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform)
  * [Qemu/KVM](https://github.com/behradeslamifar/Linux-Professional-Institute-Certifications/tree/main/LPI304/labs#3303-kvm)

Version of all tools that use in this repo
| Tools     |   Version   |
| --------- |:-----------:|
| Ubuntu    | 20.04 Focal |
| Proxmox   | 6.4-1       |
| Packer    | v1.7.4      |
| Terraform | v1.0.3      |
| Qemu-kvm  | 4.2         |



