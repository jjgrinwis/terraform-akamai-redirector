# group to create resources in
group_name = "Ion Standard Beta Jam 1-3-16TWBVX"

# this is an exising cpcode name connected to the right product (ion)
# you can find cpcodes via akamai pm lcp -g grp_id -c ctr_id
cpcode = "demo.grinwis.com"

# what user to inform when hostname has been created
email = "nobody@akamai.com"

# first part of our shared edge_hostname
# the edgekey|edgesuite.net part based on selected platform
hostname = "redirect.great-demo.com"

# our hostnames for redirect part that our going to be dynamically created
# not using redirect cloudlet, writing it dynamically to our json rules source
# the map is a hostname = redirect_target pair.
hostnames = {
  "beta.great-demo.com"         = "beta-target.grinwis.com",
  "www-beta.great-demo.com"     = "www-beta-target.grinwis.com"
  "www-nora.great-demo.com"     = "www-nora-target.grinwis.com"
  "www-flap.great-demo.com"     = "www-flap-target.grinwis.com"
  "www-marcello.great-demo.com" = "www-marcello-target.grinwis.com"
}