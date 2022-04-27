# -------------------------------------------------------- VARIABLES
variable "zone" {                                # Используем переменную для передачи в конфиг инфраструктуры
  description = "Use specific availability zone" # Опционально описание переменной
  type        = string                           # Опционально тип переменной
  default     = "ru-central1-a"                  # Опционально значение по умолчанию для переменной
}
variable "cloud_id" {                            
  type        = string                           # Опционально тип переменной
  default     = "@AND5_yc_cloud_id@"           # Опционально значение по умолчанию для переменной
}
variable "folder_id" {                            
  type        = string                           # Опционально тип переменной
  default     = "@AND5_yc_folder_id@"           # Опционально значение по умолчанию для переменной
}
variable "cloud_key_file" {                            
  type        = string                           # Опционально тип переменной
  default     = "@AND5_yc_cloud_access_key_file@"           # Опционально значение по умолчанию для переменной
}
variable "ssh_key_file" {                            
  type        = string                           # Опционально тип переменной
  default     = "@AND5_yc_vm_ssh_user_key_file@"
}
variable "config_file" {                            
  type        = string                           # Опционально тип переменной
  default     = "@AND5_yc_vm_ssh_config_file@"
}

# -------------------------------------------------------- PROVIDER
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.70.0" # Фиксируем версию провайдера
    }
  }
}

# Документация к провайдеру тут https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs#configuration-reference
# Настраиваем the Yandex.Cloud provider
provider "yandex" {
  service_account_key_file = var.cloud_key_file
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone # зона, в которая будет использована по умолчанию
}

# -------------------------------------------------------- WORKING CODE

data "yandex_compute_image" "ubuntu_2004" {
  family = "ubuntu-2004-lts-gpu"
}

resource "yandex_compute_instance" "vm1" {
  name               = "vm1"

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2004.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "${file(var.ssh_key_file)}"
	user-data = file(var.config_file)
  }
  
}

resource "yandex_compute_instance" "vm2" {
  name               = "vm2"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2004.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "${file(var.ssh_key_file)}"
	user-data = file(var.config_file)
  }
}

resource "yandex_compute_instance" "vm3" {
  name               = "vm3"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2004.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "${file(var.ssh_key_file)}"
	user-data = file(var.config_file)
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}


output "external_ip_address_vm1" {
  value = yandex_compute_instance.vm1.network_interface.0.nat_ip_address
}
output "external_ip_address_vm2" {
  value = yandex_compute_instance.vm2.network_interface.0.nat_ip_address
}
output "external_ip_address_vm3" {
  value = yandex_compute_instance.vm3.network_interface.0.nat_ip_address
}


output "internal_ip_address_vm1" {
  value = yandex_compute_instance.vm1.network_interface.0.ip_address
}
output "internal_ip_address_vm2" {
  value = yandex_compute_instance.vm2.network_interface.0.ip_address
}
output "internal_ip_address_vm3" {
  value = yandex_compute_instance.vm3.network_interface.0.ip_address
}