variable "namespace" {
  description = "Namespace, which could be your organization name, e.g. `cp` or `cloudposse`"
}

variable "stage" {
  description = "Stage, e.g. `prod`, `staging`, `dev`, or `test`"
}

variable "name" {
  description = "Solution name, e.g. `app`"
}

variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  default     = "true"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `namespace`, `name`, `stage` and `attributes`"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes, e.g. `1`"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map(`BusinessUnit`,`XYZ`)"
}

variable "convert_case" {
  description = "Convert fields to lower case"
  default     = "true"
}

# variables used for standard tagging
variable "CE_MIO_Code" {
  type        = string
  description = "Master IO Code"
}

variable "CE_SLA" {
  type        = string
  description = "Service Level Of Operation"
}

variable "CE_Business_Entity" {
  type        = string
  description = "Used to identify a specific client that a particular group of resources serves. If available, can be pre-populated based on Cost Center."
}

variable "CE_Application_ID" {
  type        = string
  description = "Used to identify differing resources that are related to a specific application"
}

variable "CE_Instance_Scheduler" {
  type        = string
  description = "Used by the Instance Schedule to power instances off and back on using a schedule. Contact the Cloud Foundation team for usage."
#  validation {
#    condition     = (can(regex("^$", var.CE_Instance_Scheduler)) || (contains(["fulltime", "fulltime_weekdays", "uk-office-hours_7am-7pm", "us-office-hours_7am-7pm", "eu-office-hours_7am-7pm", "jpn-office-hours_7am-7pm", "ind-office-hours_7am-7pm", "aus-office-hours_7am-7pm", "ch-office-hours_7am-7pm"], var.CE_Instance_Scheduler)))
#    error_message = "The CE_Instance_Scheduler value must be a valid Instance Schedule value of \"fulltime_weekdays\", \"uk-office-hours_7am-7pm\", \"us-office-hours_7am-7pm\", \"eu-office-hours_7am-7pm\", \"jpn-office-hours_7am-7pm\", \"ind-office-hours_7am-7pm\", \"aus-office-hours_7am-7pm\", \"ch-office-hours_7am-7pm\" or can be a blank value."
#  }
}
