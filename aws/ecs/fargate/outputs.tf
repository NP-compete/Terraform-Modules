output "lb_dns" {
  description = "The load balancer DNS name"
  value = aws_alb.main.dns_name
}

output "cluster_arn" {
  description = "The cluster ARN"
  value = aws_ecs_cluster.app[0].arn
}

output "task_definition_arn" {
  description = "The task definition ARN"
  value = aws_ecs_task_definition.app.arn
}

output "task_definition_family" {
  description = "The task definition family"
  value = aws_ecs_task_definition.app.family
}

output "task_definition_revision" {
  description = "The task definition family"
  value = aws_ecs_task_definition.app.revision
}