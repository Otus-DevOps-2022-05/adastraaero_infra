output "external_ip_address_app" {
  value = [ for v in yandex_compute_instance.app : v.network_interface.0.nat_ip_address ]
}
