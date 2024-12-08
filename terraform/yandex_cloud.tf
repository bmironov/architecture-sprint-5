terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
#      version = "0.129.0"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
#  token     = "example-oauth-token"       # OAuth-токен
  service_account_key_file = "/home/boris/repos/architecture-sprint-5/terraform/key.json"
  cloud_id  = "b1gqhrf6lmga1844othe"      # Cloud ID
  folder_id = "b1gh5s4fc5irg7l1gvs2"      # ID
  zone      = "ru-central1-a"             # Указание региона провайдера
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_disk" "boot-disk-1" {
  name     = "boot-disk-1"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  block_size = 4096
  size     = "20"
  image_id = "fd84gg15m6kjdembasoq"
}

resource "yandex_compute_disk_placement_group" "this" {
  zone = "ru-central1-a"
}

resource "yandex_compute_instance" "vm-1" {
  name = "terraform1"
  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-1.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/yandex_cloud")}"
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network-1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}
