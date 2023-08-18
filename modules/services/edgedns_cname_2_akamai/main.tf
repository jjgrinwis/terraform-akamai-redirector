# our terraform module to create TXT records for secure by default
# zone should already be active!
# 
# in our main.tf we explicit reference to a provider using an alias, just to test permissions in .tf file
# https://developer.hashicorp.com/terraform/language/modules/develop/providers#passing-providers-explicitly
# you now have the option to define the credentials in your main.tf file instead of in this module.
# 
# provider "akamai" {
#  edgerc         = "~/.edgerc"
#  config_section = "gss_training"
#  alias          = "edgedns"
# }
# 
# in the module section of your .tf just reference to this alias:
# providers = {
#   akamai = akamai.edgedns
# }

# tested with 5.1.0 but new versions should also work.
terraform {
  required_providers {
    akamai = {
      source = "akamai/akamai"
      version = "5.1.0"
    }
  }
}

# create a single CNAME record to point to akamai
resource "akamai_dns_record" "akamai_cname" {

  # get the key or value, same in this instance 
  zone = regex("([\\w-]*)\\.([\\w-\\.]*)", var.hostname)[1]
  name = var.hostname

  # let's lookup target value from our map of maps with value from hostnames[] as key
  target = [var.edge_hostname]

  # TTL of CNAME should be longer but for demo it's fine.
  recordtype = "CNAME"
  ttl        = 60
}
