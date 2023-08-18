# A TF project to create a redirector property
#
# it will:
# 1: add hostname to property
# 2: automatically request secure by default certificate
# 3: create new redirect behavior for that hostname
# 
# $ export AKAMAI_CLIENT_SECRET="your_secret"
# $ export AKAMAI_HOST="your_host"
# $ export AKAMAI_ACCESS_TOKEN="your_access_token"
# $ export AKAMAI_CLIENT_TOKEN="your_client_token"
provider "akamai" {
  edgerc         = "~/.edgerc"
  config_section = "betajam"
}

# our explicit reference to a provider using an alias, just to test permissions in .tf file
# using this provider section also give us the option to use for_each with a module
# https://developer.hashicorp.com/terraform/language/modules/develop/providers#passing-providers-explicitly
provider "akamai" {
  edgerc         = "~/.edgerc"
  config_section = "gss_training"
  alias          = "edgedns"
}

# just use group_name to lookup our contract_id and group_id
# this will simplify our variables file as this contains contract and group id
# use the akamai cli "akamai pm lg" to find all your groups.
data "akamai_contract" "contract" {
  group_name = var.group_name
}

locals {
  # create a normal cpcode id, remove that cpc_ part
  cp_code_id = tonumber(trimprefix(resource.akamai_cp_code.cp_code.id, "cpc_"))

  # convert the list of maps to a map of maps with entry.hostname as key of the map
  # this map of maps will be fed into our EdgeDNS module to create the CNAME records.
  dv_records = { for entry in resource.akamai_property.aka_property.hostnames[*].cert_status[0] : entry.hostname => entry }
}

# for the demo don't create cpcode's over and over again, just reuse existing one
# if cpcode already existst it will take the existing one.
resource "akamai_cp_code" "cp_code" {
  name        = var.cpcode
  contract_id = data.akamai_contract.contract.id
  group_id    = data.akamai_contract.contract.group_id
  product_id  = lookup(var.aka_products, lower(var.product_name))
}

# we're just going to use one edgehostname
# no need to create separate edgehostname per property hostname
resource "akamai_edge_hostname" "aka_edge" {

  product_id  = resource.akamai_cp_code.cp_code.product_id
  contract_id = data.akamai_contract.contract.id
  group_id    = data.akamai_contract.contract.group_id
  ip_behavior = var.ip_behavior

  # edgehostname based on hostname + network(FF/ESSL)
  edge_hostname = "${var.hostname}.${var.domain_suffix}"
}

# our dedicated redirect property. 
resource "akamai_property" "aka_property" {
  name        = var.hostname
  contract_id = data.akamai_contract.contract.id
  group_id    = data.akamai_contract.contract.group_id
  product_id  = resource.akamai_cp_code.cp_code.product_id

  # our dynamic hostname part using secure by default certs (SBD)
  # hostname is the key from our map, target edge hostname is always the same
  dynamic "hostnames" {
    for_each = var.hostnames
    content {
      cname_from             = hostnames.key
      cname_to               = resource.akamai_edge_hostname.aka_edge.edge_hostname
      cert_provisioning_type = "DEFAULT"
    }
  }

  # template file will create some dynamic json output for the redirect part of the rules file
  # in the template file using jsonencode() to create some proper json automatically.
  # because using jsonencode()we can use normal terraform expression syntax instead of using template syntax
  # https://developer.hashicorp.com/terraform/language/functions/templatefile
  # a for loop using ${var} and non-for loop just use var name like cp_code_id for example
  rules = templatefile("templates/rules.tftpl", { hostnames = var.hostnames, cp_code_id = local.cp_code_id, cp_code_name = var.cpcode })
}

# let's activate this property on staging
# staging will always use latest version but when useing on production a version number should be provided.
resource "akamai_property_activation" "aka_staging" {
  property_id = resource.akamai_property.aka_property.id
  contact     = [var.email]
  version     = resource.akamai_property.aka_property.latest_version
  network     = "STAGING"
  note        = "Action triggered by Terraform."

  # set to true otherwise activation will fail
  auto_acknowledge_rule_warnings = true
}

# if you your DNS provider has a Terraform module just use it here to create the CNAME records
# let's create our DV records using a module with with different credentials.
# Terraform used to have limitations regarding using count and for_each with a module and separate provider configs
# should be fixed now using that provider option this version still using legacy method.
# Providers cannot be configured within modules using count, for_each or depends_on
# so just feeding our edgehostname created dv strings into our edgedns_cname module as a test for secure_by_default
module "edgedns_cert_cname" {
  source = "../modules/services/edgedns_cert_cname"

  # our modules needs a pre-defined list so use the keys from our map to create a set
  # we can't use for_each in a module on dynamically created vars so we need to get our predefined hostnames
  hostnames = keys(var.hostnames)

  # our secure by default converted dv_keys output, lets feed into our edgedns module
  # feeding our local created map of maps var
  dv_records = local.dv_records

  # using the providers option so we don't have to specify credentials in the module itself.
  # this also gives us the option to use for_each etc.
  # https://developer.hashicorp.com/terraform/language/modules/develop/providers#passing-providers-explicitly
  providers = {
    akamai = akamai.edgedns
  }
}

# let's directly cname to akamai, it's for a demo only you might want to do this in a separate run
# using staging environment but let's wait until property has been activated.
module "edgedns_cname" {
  source = "../modules/services/edgedns_cname_2_akamai"

  # just call this module a couple of times to create CNAME records to edge hostname
  for_each = var.hostnames

  # hostname is the key from our hostnames var, value is the redirect target
  hostname = each.key

  # we're going to replace our edgehostname with -staging.net
  # edge_hostname = replace(resource.akamai_edge_hostname.aka_edge.edge_hostname, "/\\.net$/", "-staging.net")
  edge_hostname = replace(resource.akamai_edge_hostname.aka_edge.edge_hostname, "/\\.net$/", "-staging.net")

  # we're now able to use depends_on with a module by making this explicit reference in our main module 
  providers = {
    akamai = akamai.edgedns
  }

  # with our explict reference to a provider we should now be able to use depends_on
  # so let's wait until our property is active before creating the CNAME to our edgehostname.
  depends_on = [
    akamai_property_activation.aka_staging
  ]
}