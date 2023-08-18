variable "group_name" {
  description = "Akamai group to use this resource in"
  type        = string
}

variable "hostname" {
  description = "Used for propery name and first part of edge hostname"
  type        = string
}

# map of akamai products, just to make life easy
variable "aka_products" {
  description = "map of akamai products"
  type        = map(string)

  default = {
    "ion" = "prd_Fresca"
    "dsa" = "prd_Site_Accel"
    "dd"  = "prd_Download_Delivery"
  }
}

variable "cpcode" {
  description = "Your unique Akamai CPcode name to be used with your property"
  type        = string
}

variable "email" {
  description = "Email address of users to inform when property gets created"
  type        = string
}

# akamai product to use
variable "product_name" {
  description = "The Akamai delivery product name"
  type        = string
  default     = "dsa"
}

# IPV4, IPV6_PERFORMANCE or IPV6_COMPLIANCE
variable "ip_behavior" {
  description = "use IPV4 to only use IPv4"
  type        = string
  default     = "IPV6_COMPLIANCE"
}

# FreeFlow=edgesuite.net, ESSL=egekey.net
variable "domain_suffix" {
  description = "edgehostname suffix which decides network to use"
  type        = string
  default     = "edgesuite.net"
}

variable "hostnames" {
  description = "Our map with a hostname and redirect target"
  type        = map(string)
  default = {
    "beta.great-demo.com" = "beta-redirect-target.grinwis.com"
    "nora.great-demo.com" = "nore-redirect-target.grinwis.com"
  }
}