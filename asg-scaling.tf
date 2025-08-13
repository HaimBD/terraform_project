# Get the actual ASG name from the module output
data "aws_autoscaling_group" "asg" {
  name = module.aws_asg.autoscaling_group_name
}

# Create a scaling policy for CPU utilization
resource "aws_autoscaling_policy" "cpu_scale_out" {
  name                   = "cpu-scale-out"
  autoscaling_group_name = data.aws_autoscaling_group.asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0  # scale when CPU reaches 60%
  }
}

# (Optional) Scaling in policy to avoid runaway scaling
resource "aws_autoscaling_policy" "cpu_scale_in" {
  name                   = "cpu-scale-in"
  autoscaling_group_name = data.aws_autoscaling_group.asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 30.0  # scale down when CPU drops below 30%
  }
}
