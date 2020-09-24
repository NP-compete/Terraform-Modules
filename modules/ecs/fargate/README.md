## TODO: Complete this readme 

## Usage

```hcl
data "template_file" "container_definitions" {
  template = file("${path.module}/ecs/demo.json")

  vars = {
    container_name  = "container_name"
    container_image = "container_image"
    container_port  = 9080
    health_check    = ""
    app             = "ecs-app"
    environment     = "dev"
    region          = "us-east-1"
  }
}

module "ecs" {
  source               = "./modules/aws/ecs"
  app                  = "testapp"
  internal             = true
  region               = "us-east-1"
  environment          = "personal"

  container_definition = data.template_file.container_definitions.rendered
  container_port = 80
  lb_port = 80
  replicas = 1
  container_name = "container_name"
  container_image = "container_image"

  create_cluster       = true
  create_service       = true

  create_role          = true
  app_role             = ""
  ecsTaskExecutionRole = ""

  cpu_utilization_high_threshold = 80
  cpu_utilization_low_threshold  = 20
  memory_utilization_high_threshold = 80
  memory_utilization_low_threshold = 20
  cpu_reservation_high_threshold = 80
  cpu_reservation_low_threshold  = 20
  memory_reservation_high_threshold = 80
  memory_reservation_low_threshold = 20
  
  logs_retention_in_days = 90
  lb_access_logs_expiration_days = "3"

  scale_up_cron = "cron(0 11 ? * MON-FRI *)"
  scale_down_cron = "cron(0 23 * * ? *)"

  vpc = ""
  private_subnets = []
  public_subnets = []
  security_groups = []
  
  ecs_autoscale_min_instances = 1
  ecs_autoscale_max_instances = 8
  scale_down_min_capacity = 1
  scale_down_max_capacity = 2

  deregistration_delay = "30"
    
  health_check = ""
  health_check_interval = "30"
  health_check_timeout = "10"
  health_check_matcher = "200"

  certificate_arn = ""

  notify = []

  tags = {
    "app" = "testapp"
  }
}
```

## Input

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app | The name of the application | string | "ecs-app" | yes |
| internal | True, if app belongs inside an organization | 
| source | . | . | . | . |                         
| app | . | . | . | . |                              
| internal | . | . | . | . |                         
| region | . | . | . | . |                           
| environment | . | . | . | . |                      
| container_definition | . | . | . | . |             
| container_port | . | . | . | . |                   
| lb_port | . | . | . | . |                          
| replicas | . | . | . | . |                         
| container_name | . | . | . | . |                   
| container_image | . | . | . | . |                  
| create_cluster | . | . | . | . |                   
| create_service | . | . | . | . |                   
| create_role | . | . | . | . |                      
| app_role | . | . | . | . |                         
| ecsTaskExecutionRole | . | . | . | . |             
| cpu_utilization_high_threshold | . | . | . | . |   
| cpu_utilization_low_threshold | . | . | . | . |    
| memory_utilization_high_threshold | . | . | . | . |
| memory_utilization_low_threshold | . | . | . | . | 
| cpu_reservation_high_threshold | . | . | . | . |   
| cpu_reservation_low_threshold | . | . | . | . |    
| memory_reservation_high_threshold | . | . | . | . |
| memory_reservation_low_threshold | . | . | . | . | 
| logs_retention_in_days | . | . | . | . |           
| lb_access_logs_expiration_days | . | . | . | . |   
| scale_up_cron | . | . | . | . |                    
| scale_down_cron | . | . | . | . |                  
| vpc | . | . | . | . |                              
| private_subnets | . | . | . | . |                  
| public_subnets | . | . | . | . |                   
| security_groups | . | . | . | . |                  
| ecs_autoscale_min_instances | . | . | . | . |      
| ecs_autoscale_max_instances | . | . | . | . |      
| scale_down_min_capacity | . | . | . | . |          
| scale_down_max_capacity | . | . | . | . |          
| deregistration_delay | . | . | . | . |             
| health_check | . | . | . | . |                     
| health_check_interval | . | . | . | . |            
| health_check_timeout | . | . | . | . |             
| health_check_matcher | . | . | . | . |             
| certificate_arn | . | . | . | . |                  
| notify | . | . | . | . |                           
| tags | . | . | . | . |

## Outputs

| Name | Description |
|------|-------------|
| cluster_arn | The ARN of fargate cluster |
| task_definition_arn | The ARN of task definition |
| task_definition_family | The family of task definition |
| task_definition_revision | The revision of task definition |
| lb_dns | The DNS of the load balancer |

