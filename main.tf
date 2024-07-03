terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

locals {
  folder_id = "b1g3hhpc4sj7fmtmdccu"
  cloud_id = "b1gp6qjp3sreksmq9ju1"
}

provider "yandex" {
  zone = "ru-central1-a"
  cloud_id = local.cloud_id
  folder_id = local.folder_id
  service_account_key_file = "/root/authorized_key.json"
}

resource "yandex_compute_instance" "web-1" {
  name = "web-server-1"

  resources {
    core_fraction = 5
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8p3qkkviv008rkeb83"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-zone-a.id
    nat       = true
  }

  metadata = {
    user-data = "${file("./cloud-config.txt")}"
  }

}
resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-zone-a" {
  name           = "subnet-zone-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "subnet-zone-b" {
  name           = "subnet-zone-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.11.0/24"]
}


output "network_id" {
  value = yandex_vpc_network.network-1.id
}

output "subnet_id" {
  value = yandex_vpc_subnet.subnet-zone-a.id
}


output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.web-1.network_interface.0.ip_address
}
output "external_ip_address_vm_1" {
  value = yandex_compute_instance.web-1.network_interface.0.nat_ip_address
}
