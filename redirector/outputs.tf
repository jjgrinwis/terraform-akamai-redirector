output "dv_records" {
  description = "Our CNAME records for SBD will also contain the deployment status"
  value       = local.dv_records
}

output "activated_version" {
  description = "The activated version"
  value       = resource.akamai_property_activation.aka_staging.version
}