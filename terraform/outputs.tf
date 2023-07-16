output "external_ip_address_master" {
  value = module.work_cluster[*].external_ip_address_master
}

output "external_ip_address_worker" {
  value = module.work_cluster[*].external_ip_address_worker
}

output "external_ip_address_srv" {
  value = module.work_cluster[*].external_ip_address_srv
}