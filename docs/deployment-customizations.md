# Deployment customization

## Secret Manager

the secrets denoted by `_sm_` are required to be placed in the google secret manager prior to their named values being used in the  `tfvars` file.

## TLS

Certificates are provided at startup via startup script. the TLS certs need to be base64 encoded on save to the Google Secret manager

## Customizing options

Use the `terraform.tfvars.example` file to customize various options for your Consul deployment. By modifying this file, you can set specific values for the variables used in the module, such as the number of nodes, redundancy settings, and other configurations. Simply edit the `terraform.tfvars.example` file with your desired settings, save it with a `.tfvars` extension (removing `.example`), and run your Terraform commands to apply them.

### Configuration options

- **consul_nodes**: Set to `6` to ensure proper configuration for redundancy. This specifies the number of Consul nodes to deploy.
