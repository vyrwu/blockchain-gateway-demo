# platform

The following module represents core cloud infrastructure incl. networks,
compute, load balancing, etc. It could be located in a separate git repository.

## Requirements

No requirements.

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                                       | Type     |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_ecs_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster)                                            | resource |
| [aws_eip.ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)                                                              | resource |
| [aws_internet_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)                                  | resource |
| [aws_lb.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb)                                                            | resource |
| [aws_lb_listener.public_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener)                                     | resource |
| [aws_nat_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway)                                            | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                                         | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                                          | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)                 | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)                  | resource |
| [aws_security_group.ecs_fargate_shared_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                     | resource |
| [aws_security_group.public_lb_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                          | resource |
| [aws_ssm_parameter.aws_ecs_cluster_main_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter)                     | resource |
| [aws_ssm_parameter.aws_lb_listener_public_http_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter)             | resource |
| [aws_ssm_parameter.aws_security_group_ecs_fargate_shared_sg_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.aws_vpc_main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter)                                | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                                   | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                                    | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)                                                            | resource |

## Inputs

| Name                                                                        | Description | Type     | Default | Required |
| --------------------------------------------------------------------------- | ----------- | -------- | ------- | :------: |
| <a name="input_name_prefix"></a> [name_prefix](#input_name_prefix)          | n/a         | `string` | `"ecs"` |    no    |
| <a name="input_region"></a> [region](#input_region)                         | n/a         | `string` | n/a     |   yes    |
| <a name="input_vpc_cidr_block"></a> [vpc_cidr_block](#input_vpc_cidr_block) | n/a         | `string` | n/a     |   yes    |

## Outputs

No outputs.
