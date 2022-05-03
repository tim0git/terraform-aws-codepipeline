variable "project_name" {
  description = "The name of the project"
  type        = string
  default =  "codepipline"
}

variable "provider_type" {
  description = "The provider type"
  type        = string
  default = "GitHub"
}

variable "full_repository_id" {
  description = "The full repository id"
  type        = string
  default = ""
}

variable "branch_name" {
  description = "The branch name"
  type        = string
  default = "develop"
}

variable "build_environment_variables" {
  description = "The build environment variables"
  type        = any
  default = []
}

variable enable_codestar_notifications {
  description = "Enable codestar notifications and sns topic"
  type        = bool
  default = false
}

variable "enable_container_features" {
  description = "If true, build project will run in privileged mode, and ecr actions required for build and deploy will be added to build project iam role"
  type        = bool
  default     = false
}

variable "tags" {
  description = "The tags to apply to the project"
  type        = map(string)
  default = {
    "CodePipeline" = "true"
  }
}