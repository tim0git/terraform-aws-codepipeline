provider "aws" {
  region = "us-east-1"
}

module "basic_codepipeline" {
  source                 = "../../"
  version                = "1.0.0"

  project_name                = "example-project"

  provider_type               = "GitHub"

  build_environment_variables = [{
    name  = "AWS_BUCKET"
    value = "example.project.com"
    type = "PLAINTEXT"
  }]

  full_repository_id          = "github-user/example-project"

  branch_name                 = "main"

  enable_codestar_notifications = true

  tags = {
    Name = "example-project"
  }
}