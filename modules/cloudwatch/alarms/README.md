## Usage

### Basic Example
```hcl
    module "alarm" {
      source                    = "./modules/aws/cloudwatch/alarms"
      name                      = "alarm"
      application               = "App"
      environment               = "test"
      label_order               = ["environment", "name", "application"]
      alarm_name                = "cpu-alarm"
      comparison_operator       = "LessThanThreshold"
      evaluation_periods        = 2
      metric_name               = "CPUUtilization"
      namespace                 = "AWS/EC2"
      period                    = "60"
      statistic                 = "Average"
      threshold                 = "40"
      alarm_description         = "This metric monitors ec2 cpu utilization"
      alarm_actions             = ["arn:aws:sns:eu-west-1:xxxxxxxxxxx:test"]
      actions_enabled           = true
      insufficient_data_actions = []
      ok_actions                = []
      dimensions                = {
                    instance_id = "i-xxxxxxxxxxxxx"
      }
  }
```

### Anomaly Example
```hcl
    module "alarm" {
      source                    = "./modules/aws/cloudwatch/alarms"
      name                      = "alarm"
      application               = "App"
      environment               = "test"
      label_order               = ["environment", "name", "application"]
      alarm_name                = "cpu-alarm"
      comparison_operator       = "GreaterThanUpperThreshold"
      evaluation_periods        = 2
      threshold_metric_id       = "e1"
      query_expressions         = [{
        id          = "e1"
        expression  = "ANOMALY_DETECTION_BAND(m1)"
        label       = "CPUUtilization (Expected)"
        return_data = "true"
      }]
      query_metrics             = [{
        id          = "m1"
        return_data = "true"
        metric_name = "CPUUtilization"
        namespace   = "AWS/EC2"
        period      = "120"
        stat        = "Average"
        unit        = "Count"
        dimensions  = {
          InstanceId = module.ec2.instance_id[0]
        }
      }]
      alarm_description         = "This metric monitors ec2 cpu utilization"
      alarm_actions             = []
      actions_enabled           = true
      insufficient_data_actions = []
      ok_actions                = []
  }
```

### Expression Example
```hcl
    module "alarm" {
      source                    = "./modules/aws/cloudwatch/alarms"
      name                      = "alarm"
      application               = "App"
      environment               = "test"
      label_order               = ["environment", "name", "application"]
      expression_enabled        = true
      alarm_name                = "cpu-alarm"
      comparison_operator       = "GreaterThanUpperThreshold"
      evaluation_periods        = 2
      threshold                 = 40
      query_expressions         = [{
        id          = "e1"
        expression  = "ANOMALY_DETECTION_BAND(m1)"
        label       = "CPUUtilization (Expected)"
        return_data = "true"
      }]
      query_metrics             = [{
        id          = "m1"
        return_data = "true"
        metric_name = "CPUUtilization"
        namespace   = "AWS/EC2"
        period      = "120"
        stat        = "Average"
        unit        = "Count"
        dimensions  = {
          InstanceId = module.ec2.instance_id[0]
        }
      }]
      alarm_description         = "This metric monitors ec2 cpu utilization"
      alarm_actions             = []
      actions_enabled           = true
      insufficient_data_actions = []
      ok_actions                = []
  }
```






## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| actions\_enabled | Indicates whether or not actions should be executed during any changes to the alarm's state. | bool | `"true"` | no |
| alarm\_actions | The list of actions to execute when this alarm transitions into an ALARM state from any other state. | list | `<list>` | no |
| alarm\_description | The description for the alarm. | string | `""` | no |
| alarm\_name | The descriptive name for the alarm. | string | n/a | yes |
| comparison\_operator | The arithmetic operation to use when comparing the specified Statistic and Threshold. | string | n/a | yes |
| dimensions | Dimensions for metrics. | map | `<map>` | no |
| enabled | Enable alarm. | bool | `"true"` | no |
| evaluation\_periods | The number of periods over which data is compared to the specified threshold. | number | n/a | yes |
| expression\_enabled | Enable alarm with expression. | bool | `"false"` | no |
| instance\_id | The instance ID. | string | `""` | no |
| insufficient\_data\_actions | The list of actions to execute when this alarm transitions into an INSUFFICIENT\_DATA state from any other state. | list | `<list>` | no |
| metric\_name | The name for the alarm's associated metric. | string | `"CPUUtilization"` | no |
| namespace | The namespace for the alarm's associated metric. | string | `"AWS/EC2"` | no |
| ok\_actions | The list of actions to execute when this alarm transitions into an OK state from any other state. | list | `<list>` | no |
| period | The period in seconds over which the specified statistic is applied. | number | `"120"` | no |
| query\_expressions | values for metric query expression. | map | `<map>` | no |
| query\_metrics | values for metric query metrics. | map | `<map>` | no |
| statistic | The statistic to apply to the alarm's associated metric. | string | `"Average"` | no |
| threshold | The value against which the specified statistic is compared. | number | `"40"` | no |
| threshold\_metric\_id | If this is an alarm based on an anomaly detection model, make this value match the ID of the ANOMALY\_DETECTION\_BAND function. | string | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The ARN of the cloudwatch metric alarm. |
| id | The ID of the health check. |