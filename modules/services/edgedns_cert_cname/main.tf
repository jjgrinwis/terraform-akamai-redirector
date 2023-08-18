# our terraform module to create TXT records for secure by default
# zone should already be active!
terraform {
  required_providers {
    akamai = {
      source = "akamai/akamai"
      #version = "1.9.1"
    }
  }
}

# using for_each with our pre-configured hostnames list
# we need for_each with unique key as using count() with just index number can cause issues as order of the list might be different
# for_each needs a known list as we can't use a dynamic created map, value needs known during plan fase.
# https://stackoverflow.com/questions/62264013/terraform-failing-with-invalid-for-each-argument-the-given-for-each-argument
resource "akamai_dns_record" "dv_cname" {

  # loop through each item in our known hostnames set
  for_each = var.hostnames

  # get the key or value, same in this instance 
  zone = regex("([\\w-]*)\\.([\\w-\\.]*)", each.key)[1]
  name = "_acme-challenge.${each.value}"

  # let's lookup target value from our map of maps with value from hostnames[] as key
  target = [lookup(var.dv_records["_acme-challenge.${each.value}"], "target")]

  recordtype = "CNAME"
  ttl        = 60
}
