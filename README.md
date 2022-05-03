# terraform-aws-codepipline
Terraform module which creates CodePipeline resources

The following resources will be created:

Example 1 Basic build pipline

- requires a buildspec.yml in the branch root that follows the buildspec.yml syntax. 
  https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html

``` hcl
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
```

Example 2 Basic build pipline sourcing build env vars from parameter store

- requires a buildspec.yml in the branch root that follows the buildspec.yml syntax.
  https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html

``` hcl
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
```

Example build spec yml for a static javascript site
``` yaml
version: 0.2
phases:
  install:
    runtime-versions:
      nodejs: latest
  pre_build:
    commands:
      - npm install
  build:
    commands:
      - npm run build
  post_build:
    on-failure: ABORT
    commands:
      - aws s3 sync public/ s3://${AWS_BUCKET}/ --delete --cache-control max-age=31536000,public
artifacts:
  base-directory: public
  files:
    - "**/*"
  discard-paths: yes
```
