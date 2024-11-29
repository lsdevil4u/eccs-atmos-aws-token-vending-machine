variable "solution_name" {
  type = string
  description = "This value is used to identify the solution and seperate it from other instances."
  default = "enterpriseproduction"
}

variable "stage" {
  type = string
  description = "This value is used to identify the solution stage (dev, test prod)."
  default = "production"
}

variable "namespace" {
  type = string
  description = "This value is used to identify the solution stage (dev, test prod)."
  default = "eccs-atmos-aws-token-vending-machine"
}

variable "CE_MIO_Code" {
  type = string
  description = "This value is used to identify the solution stage (dev, test prod)."
  default = "AP059750"
}

variable "CE_Application_ID" {
  type = string
  description = "This value is used to identify the solution stage (dev, test prod)."
  default = "059750"
}

variable "CE_SLA" {
  type = string
  description = "This value is used to identify the solution stage (dev, test prod)."
  default = "NOSLA"
}

variable "CE_Business_Entity" {
  type = string
  description = "This value is used to identify the solution stage (dev, test prod)."
  default = "ITS Tech"
}

variable "CE_Instance_Scheduler" {
  type = string
  description = "This value is used to identify the solution stage (dev, test prod)."
  default = "autoscaling"
}

variable "region" {
  type = string
  description = "This value is used to identify the target region in which to deploy this solution."
  default = "eu-west-1"
}

variable "feature_inputlogging" {
  type = string
  description = "This is a feature flag to log input into the console. This can log sensitive values and should be disabled (0) for production deployments and enabled (1) only for diagnostics or debugging."
  default = "1"
}
variable "feature_outputlogging" {
  type = string
  description = "This is a feature flag to log lambda output into the console. This can log sensitive values and should be disabled (0) for production deployments and enabled (1) only for diagnostics or debugging."
  default = "0"
}

variable "feature_enabled" {
  type = string
  description = "feature flag for enabling or disabling the lambda."
  default = "1"
}

variable "ADMINKEY" {
  type = string
  description = "key to be passed in when adding a new role"
  sensitive = "true"
}

variable "python-storage-bucket-name" {
  type = string
  description = "bucket name where we store the lambda python script"
  default = "eccs-devops-prod-devopscloud-terraform-tfstate"
}

variable "permissions_boundary_arn" {
  type = string
  description = "permissions boundry arn for this account"
  default = "arn:aws:iam::095208641432:policy/CE_AppAdminRunnerBoundary"
}

variable "SMTP_PASSWORD" {
  type = string
  description = "key to be passed in when adding a new role"
  sensitive = "true"
}