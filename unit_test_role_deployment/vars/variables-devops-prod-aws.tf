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

variable "permissions_boundary_arn" {
  type = string
  description = "permissions boundry arn for this account"
  default = "arn:aws:iam::095208641432:policy/CE_AppAdminRunnerBoundary"
}

variable "entityid" {
  type = string
  description = "key to be passed in when requesting this role"
  sensitive = "true"
}