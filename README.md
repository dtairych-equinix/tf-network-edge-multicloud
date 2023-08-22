# Enabling multicloud with Equinix and Oracle

This repository explores multicloud connectivity between Oracle Cloud (OCI) and Amazon Web Services (AWS) facilitated through Equinix's private connectivity (Fabric) and virtualised network functions (Network Edge)

![alt text](https://github.com/dtairych-equinix/equinix-multicloud/blob/main/img/oci-aws-equinix.drawio.png)

## Pre-requisites

- Equinix Fabric Account
    - Account needs to have permissions for Equinix Fabric and Network Edge which can be configured through ECP
    - User must create a create API credentials through the Developer portal (insert link) which are loaded into the *.tfvars file and consumed by Terraform to create resources (Network Edge device and Fabric)
- AWS Account
    - Within this account, a deployed Direct Connect Gateway
    - An IAM user with permission to create related Direct Connect features.  The user's secret and id must be loaded into the *.tfvars files
- Oracle Cloud Account
    - Within this account, a deployed Oracle Cloud Dynamic Routing Gateway
    - The creation of a FastConnect service with the provider as Equinix.  The OCID of this resource is used by the Equinix Provider to establish connectivity to OCI


## Getting the environment ready

The end to end environment is constructed using a combination of Terraform (for all infrastructure components) and Ansible (for the configuration of Network Edge).  In addition, Ansible makes use of Expect as its initial interface into Network Edge, allowing for the Ansible IOS module to execute against the device.  

Most UNIX/Linux based systems have Expect installed, however, a Windows equivalent can be challenging.  There are some  attempts to create an equivalent experience for Windows, like: https://github.com/hymkor/expect but this code has not been validated with these tools.  

Naturally, building the environment starts with cloning this repo:

```bash
git clone https://github.com/dtairych-equinix/equinix-multicloud

```
```bash
cd equinix-multicloud
```


### Setting up Terraform 

Terraform must be in the PATH for this code to execute.  Depending on your oprtating system, follow the appropriate steps: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

Once installed (and still in the directory above), perform initialise the Terraform environment

```bash
terraform init
```

### Setting up Ansible

The final step is to install Ansible.  Once again, this must be in PATH.  
The installation guides for Ansible are available from the official documentation page: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

One of the dependencies to execute commands against the Network Edge device is the Cisco IOS module.  This can be installed using the following: 

```bash
ansible-galaxy collection install cisco.ios
```

## Deploying the environment

With the setup steps above complete, you can now plan and apply the Terraform environment to build the multicloud network

```bash
terraform plan
```
```bash
terraform apply --auto-approve
```

## Execution Dependencies

In the current format, there are a number of dependencies for this code to execute correctly:
- Network Edge Device must be a Cisco Catalyst 8000v.  The configuration of the Network Edge device is currently only supporting Cisco IOS XE.  Additional interfaces could be written, and loaded, but open_cfg.yml would also need to be appropriately updated to support the correct onboarding of a different vendor / operating system
- As mentioned above, the machine executing the Terraform code much have support to Except.  More details on this in the "other consideration" section discussing RESTCONF

## Other considerations

There are some components of this deployment that would not be considered production grade:
- No redundancy built in at any layer.  Although, this is possible with each provider having their own documentation on best practices for redundancy: 
    - Equinix https://docs.equinix.com/en-us/Content/Interconnection/NE/deploy-guide/NE-architecting-resiliency.htm 
    - Oracle FastConnect: https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/fastconnectresiliency.htm
    - AWS Direct Connect: https://aws.amazon.com/directconnect/resiliency-recommendation/
- To create a one-click deployment, Terraform is used to invoke the Ansible script that is responsible for configuration of the Equinix Network Edge device.  In a production environment, these two processes should be separated from one another
- RESTCONF interface on Network Edge device opened by a relatively crude Except script that interfaces with the interactive CLI for the Cisco Catalyst 8000v.  This is done for the express purpose of automating the end-to-end configuration and should not be considered for production workloads
- In the current form, Terraform creates a dynamic SSH key for the current deployment.  This is stored as plain text in the state file which is not ideal or secure.  Please consider changing the scripts to make use of a local key instead - this was only implemented to keep the codebase as a self-contained deployment