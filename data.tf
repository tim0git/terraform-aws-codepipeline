data "aws_iam_policy_document" "pipline_notifications" {
  statement {
    actions = ["sns:Publish"]

    principals {
      type        = "Service"
      identifiers = ["codestar-notifications.amazonaws.com"]
    }

    resources = [aws_sns_topic.pipline_notifications.arn]
  }
}