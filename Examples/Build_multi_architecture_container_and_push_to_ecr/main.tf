provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

module "build_container_and_push_to_ecr" {
  source  = "../../"
  version = "1.0.0"

  project_name = "example-project"

  enable_container_features = true
  enable_multi_architecture_image_builds = true

  provider_type = "GitHub"

  ## NOTE Env vars must be in PLAINTEXT format as the iam role for ECR access is generated by terraform and uses their PLAINTEXT value.


  build_environment_variables = [
    {
      name  = "AWS_DEFAULT_REGION"
      value = "us-east-1"
      type  = "PLAINTEXT"
    },
    {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
      type  = "PLAINTEXT"
    },
    {
      name  = "IMAGE_REPO_NAME"
      value = "example-ecr-repo-name"
      type  = "PLAINTEXT"
    },
    {
      name  = "IMAGE_TAG"
      value = "latest"
      type  = "PLAINTEXT"
    }
  ]

  full_repository_id = "github-user/example-project"

  branch_name = "main"

  enable_codestar_notifications = true

  pipeline_artifact_access_log_storage_bucket = "example-s3-bucket-name"

  tags = {
    Name = "example-project"
  }
}