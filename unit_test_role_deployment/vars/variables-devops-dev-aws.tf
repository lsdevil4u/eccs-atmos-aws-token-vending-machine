variable "solution_name" {
  type = string
  description = "This value is used to identify the solution and seperate it from other instances."
  default = "enterprisedev"
}

variable "stage" {
  type = string
  description = "This value is used to identify the solution stage (dev, test prod)."
  default = "dev"
}

variable "namespace" {
  type = string
  description = "This value is used to identify the solution stage (dev, test prod)."
  default = "atmos-platform-devops-roleretriever"
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

variable "permissions_boundary_arn" {
  type = string
  description = "permissions boundry arn for this account"
  default = "arn:aws:iam::230559371484:policy/CE_AppAdminRunnerBoundary"
}
variable "IAM_ENTITYID" {
  type = string
  description = "key to be passed in when requesting this role"
  sensitive = true
}

variable "IAM_WILDCARDENTITYID" {
  type = string
  description = "key to be passed in when requesting this role"
  sensitive = true
}