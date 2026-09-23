# Copyright 2026 Bitshift ED (https://www.bitshifted.com)


locals {
  enable_auto_scaling = var.auto_scaling_config.enabled && var.capacity_config.billing_mode == "PROVISIONED"
}

resource "aws_appautoscaling_target" "table_read_autoscaling_target" {
  count              = local.enable_auto_scaling ? 1 : 0
  min_capacity       = var.auto_scaling_config.read_config.min_capacity
  max_capacity       = var.auto_scaling_config.read_config.max_capacity
  resource_id        = "table/${aws_dynamodb_table.db_table.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
  tags               = local.merged_tags
}

resource "aws_appautoscaling_target" "table_write_autoscaling_target" {
  count              = local.enable_auto_scaling ? 1 : 0
  min_capacity       = var.auto_scaling_config.write_config.min_capacity
  max_capacity       = var.auto_scaling_config.write_config.max_capacity
  resource_id        = "table/${aws_dynamodb_table.db_table.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
  tags               = local.merged_tags
}



resource "aws_appautoscaling_policy" "table_read_autoscaling_policy" {
  count              = local.enable_auto_scaling ? 1 : 0
  name               = "${aws_dynamodb_table.db_table.name}-read-autoscaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.table_read_autoscaling_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.table_read_autoscaling_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.table_read_autoscaling_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0
    scale_in_cooldown  = 900
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "table_write_autoscaling_policy" {
  count              = local.enable_auto_scaling ? 1 : 0
  name               = "${aws_dynamodb_table.db_table.name}-write-autoscaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.table_write_autoscaling_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.table_write_autoscaling_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.table_write_autoscaling_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0
    scale_in_cooldown  = 900
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
  }
}

# GSI auto scaling resources

resource "aws_appautoscaling_target" "gsi_read_autoscaling_target" {
  for_each = local.enable_auto_scaling ? { for gsi in var.gsi_list : gsi.name => gsi } : {}

  min_capacity       = var.auto_scaling_config.read_config.min_capacity
  max_capacity       = var.auto_scaling_config.read_config.max_capacity
  resource_id        = "table/${aws_dynamodb_table.db_table.name}/index/${each.value.name}"
  scalable_dimension = "dynamodb:index:ReadCapacityUnits"
  service_namespace  = "dynamodb"
  tags               = local.merged_tags
}

resource "aws_appautoscaling_target" "gsi_write_autoscaling_target" {
  for_each = local.enable_auto_scaling ? { for gsi in var.gsi_list : gsi.name => gsi } : {}

  min_capacity       = var.auto_scaling_config.write_config.min_capacity
  max_capacity       = var.auto_scaling_config.write_config.max_capacity
  resource_id        = "table/${aws_dynamodb_table.db_table.name}/index/${each.value.name}"
  scalable_dimension = "dynamodb:index:WriteCapacityUnits"
  service_namespace  = "dynamodb"
  tags               = local.merged_tags
}

resource "aws_appautoscaling_policy" "gsi_read_autoscaling_policy" {
  for_each = aws_appautoscaling_target.gsi_read_autoscaling_target

  name               = "${aws_dynamodb_table.db_table.name}-${each.key}-read-autoscaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = each.value.resource_id
  scalable_dimension = each.value.scalable_dimension
  service_namespace  = each.value.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0
    scale_in_cooldown  = 900
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "gsi_write_autoscaling_policy" {
  for_each = aws_appautoscaling_target.gsi_write_autoscaling_target

  name               = "${aws_dynamodb_table.db_table.name}-${each.key}-write-autoscaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = each.value.resource_id
  scalable_dimension = each.value.scalable_dimension
  service_namespace  = each.value.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0
    scale_in_cooldown  = 900
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
  }
}



