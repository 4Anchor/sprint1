terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.65.0"
    }
  }
  required_version = ">= 0.13"

}

provider "yandex" {
  zone      = "ru-central1-a"
  token     = "<TOKEN>"
  cloud_id  = "<C_ID>"
  folder_id = "<F_ID>"

}

resource "yandex_vpc_network" "network" {
  name = "work-network"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "subnet3"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

module "work_cluster" {
  source        = "./modules/instance"
  vpc_subnet_id = yandex_vpc_subnet.subnet.id
  master        = 1
  workers       = 1
}
