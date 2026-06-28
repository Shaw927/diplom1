variable "yandex_token" {
  description = "IAM/OAuth токен для Yandex Cloud"
  type        = string
  sensitive   = true
}

variable "cloud_id" {
  description = "ID облака в Yandex Cloud"
  type        = string
}

variable "folder_id" {
  description = "ID каталога (folder) в Yandex Cloud"
  type        = string
}

variable "default_zone" {
  description = "Зона по умолчанию для ресурсов"
  type        = string
  default     = "ru-central1-a"
}

variable "vpc_name" {
  description = "Базовое имя для VPC и связанных ресурсов"
  type        = string
  default     = "diplom-vpc"
}

variable "vm_count" {
  description = "Число веб-серверов в target group"
  type        = number
  default     = 2
}

variable "zones" {
  description = "Список зон доступности для распределения ресурсов"
  type        = list(string)
  default     = ["ru-central1-a", "ru-central1-b"]
}

variable "private_subnets" {
  description = "Список приватных подсетей: каждая — объект с именем, зоной и CIDR"
  type = list(object({
    name = string
    zone = string
    cidr = string
  }))
  default = [
    { name = "web-private-a", zone = "ru-central1-a", cidr = "10.0.1.0/24" },
    { name = "web-private-b", zone = "ru-central1-b", cidr = "10.0.2.0/24" }
  ]
}

variable "public_subnets" {
  description = "Список публичных подсетей"
  type = list(object({
    name = string
    zone = string
    cidr = string
  }))
  default = [
    { name = "public-a", zone = "ru-central1-a", cidr = "10.0.10.0/24" }
  ]
}
