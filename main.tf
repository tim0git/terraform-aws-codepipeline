locals {
  enable_default_build_project = var.enable_container_features ?  [] : [true]
  container_architectures = var.enable_multi_architecture_image_builds ? ["arm64", "amd64"] : var.enable_container_features ? ["amd64"] : []
}

module "codestar_connection" {
  source  = "tim0git/codestar-connection/aws"
  version = "1.1.1"

  name = var.project_name

  provider_type = var.provider_type

  tags = var.tags
}

module "code_build" {
  count = var.enable_container_features ? 0 : 1
  source  = "tim0git/codebuild/aws"
  version = "1.3.0"

  project_name = var.project_name

  environment_variables = var.build_environment_variables

  tags = var.tags
}

module "code_build_container" {
  count = var.enable_container_features ? length(local.container_architectures) : 0
  source  = "tim0git/codebuild/aws"
  version = "1.3.0"

  project_name = "${var.project_name}-${local.container_architectures[count.index]}"

  environment_variables = var.build_environment_variables

  enable_container_features = var.enable_container_features

  container_architecture  = local.container_architectures[count.index]

  tags = var.tags
}

resource "aws_codepipeline" "codepipeline" {
  name     = "${var.project_name}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = module.codestar_connection.arn
        FullRepositoryId = var.full_repository_id
        BranchName       = var.branch_name
      }
    }
  }

  stage {
    name = "Build"

    dynamic "action" {
      for_each = local.enable_default_build_project
      content {
        name             = "Build"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["source_output"]
        output_artifacts = ["build_output"]
        version          = "1"

        configuration = {
          ProjectName = "${var.project_name}-codebuild"
        }
      }
    }

    dynamic "action" {
      for_each = local.container_architectures
      content {
        name             = action.value
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["source_output"]
        output_artifacts = ["build_output-${action.value}"]
        version          = "1"

        configuration = {
          ProjectName = "${var.project_name}-${action.value}-codebuild"
        }
      }
    }

  }
  tags = var.tags
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = lower("${var.project_name}-codepipeline-artifacts-store")
  tags = var.tags
}

resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  acl    = "private"
}

resource "aws_sns_topic" "pipline_notifications" {
  count = var.enable_codestar_notifications ? 1 : 0
  name = "${var.project_name}-pipline-sns-topic"
  tags = var.tags
}

resource "aws_codestarnotifications_notification_rule" "pipline_notifications" {
  count = var.enable_codestar_notifications ? 1 : 0
  detail_type    = "BASIC"
  event_type_ids = ["codepipeline-pipeline-pipeline-execution-started", "codepipeline-pipeline-pipeline-execution-succeeded", "codepipeline-pipeline-pipeline-execution-failed", "codepipeline-pipeline-pipeline-execution-canceled"]
  name     = "${var.project_name}-pipline-notification-rule"
  resource = aws_codepipeline.codepipeline.arn

  target {
    address = aws_sns_topic.pipline_notifications[count.index].arn
  }

  tags = var.tags
}

resource "aws_sns_topic_policy" "pipline_notifications" {
  count = var.enable_codestar_notifications ? 1 : 0
  arn    = aws_sns_topic.pipline_notifications[count.index].arn
  policy = data.aws_iam_policy_document.pipline_notifications[count.index].json
}

resource "aws_iam_role" "codepipeline_role" {
  name = "${var.project_name}-codepipline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_role.json
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${var.project_name}-codepipeline_policy"
  role = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}