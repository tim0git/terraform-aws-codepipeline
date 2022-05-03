provider "aws" {
  region = "us-east-1"
}

module "basic_codepipeline_sourcing_env_vars_from_ssm_parameter_store" {
  source                 = "../../"
  version                = "1.0.0"

  project_name                = "example-project"

  provider_type               = "GitHub"

  build_environment_variables = [{
    name  = "AWS_BUCKET"
    value = "/exmample-account/example-project/name"
    type = "PARAMETER_STORE"
  }]

  full_repository_id          = "github-user/example-project"

  branch_name                 = "main"

  enable_codestar_notifications = true

  tags = {
    Name = "example-project"
  }
}