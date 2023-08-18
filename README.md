# Terraform Akamai Redirect Infrastructure Project

This project provides infrastructure automation using Terraform for the Akamai platform.
If will create a single Akamai configuration just to create redirects. 

## Table of Contents

- [Terraform Infrastructure Project](#terraform-infrastructure-project)
  - [Description](#description)
  - [Features](#features)
  - [Prerequisites](#prerequisites)
  - [Getting Started](#getting-started)
  - [Usage](#usage)


## Description

This project demonstrates how to use Terraform to provision and manage infrastructure resources on the Akamai Edge. It will create an Akamai Delivery Configuration just for redirects. Akamai has a special Cloudlet for this usage but in this project doing everything just in a single delivery configuration. You will find a lot of comments in the TF files with links to documentation etc.

## Features

List the key features of your Terraform project:

- Akamai Infrastructure provisioning with code.
- Creates an Akamai Delivery configuration with a dynamic redirects section.
- Automatically request certificates using Secure By Default (SBD) option.
- Will create CNAME records in EdgeDNS (Feel free to add your own DNS provider)

It's my first test with generating some dynamic JSON using the templatefile() function en jsonencode() in the .tftp template file itself.
https://developer.hashicorp.com/terraform/language/functions/templatefile#generating-json-or-yaml-from-a-template

## Prerequisites

Specify any prerequisites that users need to have before using your Terraform project:

- Terraform installed (version 1.5.x)
- Make sure to have Secure By Default (SBD) active on your Akamai contract.
- Have the Correct Akamai PAPI and EdgeDNS API credentials.
- DNS Zone should be available in EdgeDNS, we're not going to create EdgeDNS zones!

## Getting Started

Instructions on how to get started with your Terraform project:

1. Clone this repository:

   ```shell
   $ git clone https://github.com/jjgrinwis/terraform-akamai-redirector
   $ cd terraform-akamai-redirector/redirector

2. Set the correct credentials in .edgerc or use env vars.
- https://techdocs.akamai.com/terraform/docs/overview
- https://techdocs.akamai.com/terraform/docs/gs-authentication#set-environment-variables

3. And off you go
   ```shell
   $ terraform init
   $ terraform plan
   $ terraform apply

## Usage

Just set the correct values in the terraform.tfvars file and add your hostname:target combinations in the var.hostnames{} map:
```
hostnames = {
  "beta.great-demo.com"         = "beta-target.grinwis.com",
  "www-beta.great-demo.com"     = "www-beta-target.grinwis.com"
  "www-nora.great-demo.com"     = "www-nora-target.grinwis.com"
  "www-flap.great-demo.com"     = "www-flap-target.grinwis.com"
  "www-marcello.great-demo.com" = "www-marcello-target.grinwis.com"
}
```
And after the apply you will see something like this:
![image](https://github.com/jjgrinwis/terraform-akamai-redirector/assets/3455889/6511cfb6-7216-4649-8a0d-0683a0ee08fb)
![image](https://github.com/jjgrinwis/terraform-akamai-redirector/assets/3455889/a623c8f2-1d49-433d-b3a2-b7a30008dd6d)

have fun!
