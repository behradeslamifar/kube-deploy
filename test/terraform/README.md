# Terraform 

## Create Proxmox Template
* Copy builded image to PVE machine
```
scp output/${image_name} root@pve_ip:
```

* ssh to PVE host
* Create basic virtual machine
```
qm create 9000 --name 'tempalte_name' --description 'Description' \
  --ostype l26 \
  --bios seabios \
  --boot c \
  --bootdisk scsi0 \
  --agent 1 \
  --cpu cputype=kvm64 --sockets 1 --cores 2 --vcpu 2 --memory 2048 --balloon 0 \
  --net0 virtio,bridge=vmbr0 \
  --scsihw virtio-scsi-pci \
  --scsi0 local-lvm:vm-9000-disk-0 \
  --vga qxl \
  --hotplug disk,network,usb --serial0 socket \
  --ide2 local-lvm:cloudinit
```

* Import builded image in first step
```
qm importdisk 9000 /path/to/${image_name} local-lvm
```

* Resize image
```
qm resize 9000 scsi0 15G
```

* Convert basic vm to template
```
qm template 9000
```

