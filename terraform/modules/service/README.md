# service

This module contains packaged functionality which could be used by a developer
to rapidly deploy a service on top of the core cloud infrastructure.

## Requirements

No requirements.

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                     | Type        |
| ---------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_ecr_repository.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository)                 | resource    |
| [aws_ecs_service.ecs_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service)                   | resource    |
| [aws_ecs_task_definition.ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition)      | resource    |
| [aws_iam_role.execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                      | resource    |
| [aws_iam_role.task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                           | resource    |
| [aws_lb_listener_rule.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule)             | resource    |
| [aws_lb_target_group.target_group_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group)   | resource    |
| [aws_iam_policy.execution_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy)        | data source |
| [aws_ssm_parameter.aws_vpc_main_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter)        | data source |
| [aws_ssm_parameter.ecs_fargate_cluster_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.fargate_shared_sg_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter)   | data source |
| [aws_ssm_parameter.lb_lister_public_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter)   | data source |
| [aws_subnets.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets)                             | data source |

## Inputs

| Name                                                                                          | Description                                                                                                                                                                     | Type     | Default | Required |
| --------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------- | :------: |
| <a name="input_cpu"></a> [cpu](#input_cpu)                                                    | Defined in CPU shares. Subject to Fargate task sizing requirements: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-tasks-services.html#fargate-tasks-size. | `number` | `256`   |    no    |
| <a name="input_iam_role_policy_json"></a> [iam_role_policy_json](#input_iam_role_policy_json) | n/a                                                                                                                                                                             | `string` | `""`    |    no    |
| <a name="input_image_tag"></a> [image_tag](#input_image_tag)                                  | n/a                                                                                                                                                                             | `string` | n/a     |   yes    |
| <a name="input_memory"></a> [memory](#input_memory)                                           | Defined in MiB. Subject to Fargate task sizing requirements: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-tasks-services.html#fargate-tasks-size.        | `number` | `512`   |    no    |
| <a name="input_platform_name_prefix"></a> [platform_name_prefix](#input_platform_name_prefix) | n/a                                                                                                                                                                             | `string` | `"ecs"` |    no    |
| <a name="input_port"></a> [port](#input_port)                                                 | n/a                                                                                                                                                                             | `number` | `8080`  |    no    |
| <a name="input_replica_count"></a> [replica_count](#input_replica_count)                      | n/a                                                                                                                                                                             | `number` | `1`     |    no    |
| <a name="input_service_name"></a> [service_name](#input_service_name)                         | n/a                                                                                                                                                                             | `string` | n/a     |   yes    |

## Outputs

No outputs.
