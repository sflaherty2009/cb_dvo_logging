resource "random_integer" "delivery" {
  min     = 01
  max     = 99
}

resource "azurerm_resource_group" "delivery" {
  name     = "AZ-RG-CHEF-DELIVERY"
  location = "${var.location}"
}
resource "azurerm_public_ip" "delivery" {
  name                         = "${var.vm_name}-${random_integer.delivery.result}-pubip"
  location                     = "${azurerm_resource_group.delivery.location}"
  resource_group_name          = "${azurerm_resource_group.delivery.name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label            = "${var.vm_name}-${random_integer.delivery.result}-${lower(azurerm_resource_group.delivery.name)}"
  count                        = "${var.count_vms}"
}

resource "azurerm_network_interface" "delivery" {
  name                = "${var.vm_name}-${random_integer.delivery.result}-nic"
  location            = "${azurerm_resource_group.delivery.location}"
  resource_group_name = "${azurerm_resource_group.delivery.name}"
  count               = "${var.count_vms}"

  ip_configuration {
    name                          = "${var.vm_name}-${random_integer.delivery.result}-ipconf"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.delivery.*.id, count.index)}"
  }
}

resource "azurerm_storage_account" "delivery" {
  name                     = "azlchefdeli${random_integer.delivery.result}s"
  resource_group_name      = "${azurerm_resource_group.delivery.name}"
  location                 = "${azurerm_resource_group.delivery.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  count                    = "${var.count_vms}"
}

resource "azurerm_storage_container" "delivery" {
  name                  = "vhds"
  resource_group_name   = "${azurerm_resource_group.delivery.name}"
  storage_account_name  = "${element(azurerm_storage_account.delivery.*.name, count.index)}"
  container_access_type = "private"
  count                 = "${var.count_vms}"
}

resource "azurerm_virtual_machine" "delivery" {
  name                  = "${var.vm_name}-${random_integer.delivery.result}"
  location              = "${azurerm_resource_group.delivery.location}"
  resource_group_name   = "${azurerm_resource_group.delivery.name}"
  network_interface_ids = ["${element(azurerm_network_interface.delivery.*.id, count.index)}"]
  vm_size               = "${var.vm_size}"
  count                 = "${var.count_vms}"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "${var.lin_image_publisher}"
    offer     = "${var.lin_image_offer}"
    sku       = "${var.lin_image_sku}"
    version   = "${var.lin_image_version}"
  }

  storage_os_disk {
    name          = "osdisk"
    vhd_uri       = "${element(azurerm_storage_account.delivery.*.primary_blob_endpoint, count.index)}${element(azurerm_storage_container.delivery.*.name, count.index)}/osdisk.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "${var.vm_name}-${random_integer.delivery.result}"
    admin_username = "${var.admin_user}"
    admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = "false"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${var.admin_password} | sudo -S sudo su -c 'echo 10.16.192.7 azl-chef-srvr-01 >> /etc/hosts'",
      "echo ${var.admin_password} | sudo -S sudo su -c 'echo 10.16.192.8 azl-chef-auto-01 >> /etc/hosts'"
    ]

    connection {
      type             = "ssh"
      host             = "${element(azurerm_network_interface.delivery.*.private_ip_address, count.index)}"
      user             = "${var.admin_user}"
      password         = "${var.admin_password}"
      agent            = false
    }
  }

  provisioner "local-exec" {
    command = "knife bootstrap ${element(azurerm_network_interface.delivery.*.private_ip_address, count.index)} -G azl-dev-jmp-01-az-rg-jump-lin.eastus2.cloudapp.azure.com:4222 -N ${var.vm_name}-${random_integer.delivery.result} --environment acceptance-trek-trek-bikes-${var.cookbook_name}-master -x ${var.admin_user} -P ${var.admin_password} --run-list 'recipe[${var.cookbook_name}]' --sudo --yes"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "knife node delete ${var.vm_name}-${random_integer.delivery.result} -y; knife client delete ${var.vm_name}-${random_integer.delivery.result} -y"
  }

  provisioner "remote-exec" {
    when    = "destroy"
    inline = [
      "sudo automate-ctl delete-node --name ${var.vm_name}-${random_integer.delivery.result} -f"
    ]

    connection {
      type             = "ssh"
      host             = "10.16.192.8"
      user             = "${var.admin_user}"
      password         = "${var.admin_password}"
      agent            = false
    }
  }

  tags {
    environment = "Chef Automate"
  }
}
