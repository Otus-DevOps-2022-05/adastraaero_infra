variable cloud_id{
  description = "Cloud"
}
variable folder_id {
  description = "Folder"
}
variable zone {
  description = "Zone"
  # Значение по умолчанию
  default = "ru-central1-a"
}
variable public_key_path {
  # Описание переменной
  description = "/home/mity/.ssh/id_rsa.pub"
}
variable image_id {
  description = "Disk image"
}
variable subnet_id{
  description = "Subnet"
}
variable service_account_key_file{
  description = "/home/mity/Documents/OtusDevops/terraform.json"
}
variable private_key_path {
  description = "/home/mity/.ssh/id_rsa"
}

variable instance_count {
  description = "count instances"
  default     = 1
}
	# add new variables
variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}
variable db_disk_image {
  description = "Disk image for mongodb"
  default     = "reddit-db-base"
}
