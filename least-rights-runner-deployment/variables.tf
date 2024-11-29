
variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "volume_size" {
  type        = number
  description = "Size of the root volume in GB"
  default     = 50
}

variable "aws_ecs_instance_key_name" {
  type = string
  description = "Which KMS key to use for logging into the ec2 instance."
  default = "eccs_devops_NFurno"
}

variable "solution_name" {
  type = string
  description = "This value is used to identify the solution and seperate it from other instances."
  default = "enterprisedev"
}

variable "name" {
  type = string
  description = "This value is used to identify the solution stage (dev, test prod)."
  default = "DevOps-Dev-Lowest-Rights-Github-Runner"
}

variable "app_admin" {
  type        = bool
  description = "Whether to use the standard AppAdmin permissions"
  default     = false
}

variable "policy" {
  type        = string
  description = "Policy document to attach to the runner role"
  default     = null
}

variable route53_dns_zone_id {
  type = string
  default = "Z03595011JN71KJ1LA2F8"
}

variable route53_dns_host_name {
  type = string
  default = "roleretrieverrunner"
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