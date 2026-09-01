resource "aws_cloudwatch_metric_alarm" "ec2_status_check" {
  alarm_name          = "${local.project_name}-ec2-status-check"
  alarm_description   = "Alarm when ImageForge EC2 fails its status check"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1

  dimensions = {
    InstanceId = aws_instance.imageforge.id
  }

  treat_missing_data = "breaching"

  tags = local.common_tags
}