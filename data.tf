data "aws_iam_policy_document" "pipline_notifications" {
  count = var.enable_codestar_notifications ? 1 : 0
  statement {
    actions = ["sns:Publish"]

    principals {
      type        = "Service"
      identifiers = ["codestar-notifications.amazonaws.com"]
    }

    resources = [aws_sns_topic.pipline_notifications[count.index].arn]
  }
}