# Enabling multicloud with Equinix and Oracle

This repository explores multicloud connectivity between Oracle Cloud (OCI) and Amazon Web Services (AWS) facilitated through Equinix's private connectivity (Fabric) and virtualised network functions (Network Edge)

*Insert Diagram

## Pre-requisites

-Equinix Fabric Account
    - 
- AWS Account
    - Within this account, a deployed Direct Connect Gateway
    - An IAM user with permission to create related Direct Connect features.  The user's secret and id must be loaded into the *.tfvars files
- Oracle Cloud Account
    - Within this account, a deployed Oracle Cloud Dynamic Routing Gateway


## Requirements

There are a number of requirements for this code to execute correctly:
- Network Edge Device must be a Cisco Catalyst 8000v.  The configuration of the Network Edge device is configured using the ios_xe Terraform provider (insert provider here)
- The machine executing the Terraform code much have support to Except.  More details on this in the "other consideration" section discussing RESTCONF


## Other considerations

There are some components of this deployment that would not be considered production grade:
- No redundancy built in at any layer: * insert docs for redundancy on each provider
- RESTCONF interface on Network Edge device opened by a relative Except script that interfaces with the interactive CLI for the Cisco Catalyst 8000v.  This is done for the express purpose of automating the end-to-end configuration and should not be considered for production workloads
