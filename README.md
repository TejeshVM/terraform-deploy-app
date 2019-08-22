# RunJavaOnEC2
A Project to run Java Application on EC2 instances using Terraform and balance load via a Classic AWS Loadbalancer.

# A typical Final Output of the same:

Apply complete! Resources: 25 added, 0 changed, 0 destroyed.

Outputs:

az1_instance_ips = [
  [
    "172.16.1.153",
    "172.16.1.42",
    "172.16.1.99",
  ],
]
az2_instance_ips = [
  [
    "172.16.3.105",
    "172.16.3.146",
  ],
]
bastion_ip = 52.59.216.58
elb_dns_name = navvis-demo-elb-498332645.eu-central-1.elb.amazonaws.com
vpc_private_sg_id = sg-03b3ec27fe2254a0a

# To-Do:

1. A better approach to attach instances to ELB can be done by using custom terraform modules.
2. Separating the configuration of provisioner using null_resource module.
3. Adding up AWS ELB Auto Scaling.
