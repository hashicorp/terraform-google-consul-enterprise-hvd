
# Deployment customization

## TLS

Certificates are provided at startup via startup script.


## Customizing options with tf.autovars.tfvars

Use the `terraform.tfvars.example` file to customize various options for your Consul deployment. Copy the file to a `*.tfvars` file. By then modifying this file, you can set specific values for the variables used in the module, such as the number of nodes, redundancy settings, and other configurations.  Then with your desired settings and run your Terraform workflow to apply them.

### Configuration options

- **consul_nodes**: Set to `6` to ensure proper configuration for redundancy. This specifies the number of Consul nodes to deploy.
