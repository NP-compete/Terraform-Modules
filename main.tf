module "kms" {
  source                  = "./modules/kms"
  enabled                 = true
  alias                   = "alias/${var.kms_name}"
  description             = "KMS key"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  policy                  = ""
  tags                    = var.tags
}

module "ecr" {
  source         = "./modules/ecr"
  repo_name      = var.ecr_name
  environment    = var.environment
  product_domain = var.product_name
  scan_on_push   = true
  kms_arn        = module.kms.key_arn
  tags           = var.tags
}

data "template_file" "container_definitions" {
  template = file("modules/ecs/fargate/demo.json")

  vars = {
    container_name  = var.container_name
    container_image = var.container_image
    container_port  = var.container_port
    health_check    = ""
    app             = var.product_name
    environment     = var.environment
    region          = var.region
  }
}

module "ecs" {
  source                            = "./modules/ecs/fargate"
  app                               = var.product_name
  internal                          = true
  region                            = var.region
  environment                       = var.environment
  container_definition              = data.template_file.container_definitions.rendered
  container_port                    = 80
  lb_port                           = 80
  replicas                          = 1
  container_name                    = var.container_name
  container_image                   = var.container_image
  create_cluster                    = true
  create_service                    = true
  create_role                       = true
  app_role                          = ""
  ecsTaskExecutionRole              = ""
  cpu_utilization_high_threshold    = 80
  cpu_utilization_low_threshold     = 20
  memory_utilization_high_threshold = 80
  memory_utilization_low_threshold  = 20
  cpu_reservation_high_threshold    = 80
  cpu_reservation_low_threshold     = 20
  memory_reservation_high_threshold = 80
  memory_reservation_low_threshold  = 20
  logs_retention_in_days            = 90
  lb_access_logs_expiration_days    = "3"
  scale_up_cron                     = var.scale_up_cron
  scale_down_cron                   = var.scale_down_cron
  vpc                               = ""
  private_subnets                   = []
  public_subnets                    = []
  security_groups                   = []
  ecs_autoscale_min_instances       = 1
  ecs_autoscale_max_instances       = 8
  scale_down_min_capacity           = 1
  scale_down_max_capacity           = 2
  deregistration_delay              = "30"
  health_check                      = ""
  health_check_interval             = "30"
  health_check_timeout              = "10"
  health_check_matcher              = "200"
  certificate_arn                   = ""
  notify                            = []
  tags                              = var.tags
}