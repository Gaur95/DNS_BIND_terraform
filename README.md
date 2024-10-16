# DNS Server Automation with BIND and Terraform

## Overview

This repository contains the necessary configuration files and Terraform scripts to automate the setup of a DNS server using BIND on Ubuntu. It also demonstrates how to manage DNS zone files, `A` records, and `NS` records, as well as how to provision the required infrastructure using Terraform.

## Features

- **DNS Server Setup**: Configuration of BIND DNS server including forwarders, logging, and zone file management.
- **Infrastructure as Code**: Automated provisioning of EC2 instances with Terraform, using the default VPC and a pre-existing security group.
- **DNS Zone File Management**: Set up `A` and `NS` records for the `akash.eu.org` domain, providing a functional DNS server.

## Prerequisites

- **BIND9**: Installed and configured on an Ubuntu server.
- **Terraform**: Installed on your local machine or CI/CD system.
- **AWS Account**: For provisioning EC2 instances.
- **Domain Name**: Registered domain 

