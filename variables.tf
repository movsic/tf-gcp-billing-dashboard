variable "bq-billing-export-table-name" {
  type        = string
  description = "Standard billing export bigquery table name."
}

variable "bq-dashboard-dataset-name" {
  type        = string
  description = "Bigquery dataset where the dashboard view will be created. Should already exist. Must be in the format <project-id>.<bq-dataset-name>"
  validation {
    condition = can(regex("^[0-9a-zA-Z-]*\\.[0-9a-zA-Z_]*$", var.bq-dashboard-dataset-name))
    error_message = "Bq dataset id must be in the format <project-id>.<bq-dataset-name>"
  }
}

variable "bq-dashboard-view-name" {
  type        = string
  default     = "billing-export-view"
  description = "Bigquery view name. This view will be created."
}

variable "billing-data-interval" {
  type        = number
  default     = 13
  description = "Time interval to be showed in view."
}

variable "looker-studio-service-account-name" {
  type        = string
  default     = "looker-studio-sa"
  description = "GCP service account name to be used with the looker studio dashboard."
}

variable "looker-studio-service-agent-name" {
  type        = string
  default     = null
  description = "Looker studio service agent name to be used with the looker studio dashboard. Can be copied from https://lookerstudio.google.com/c/serviceAgentHelp. If empty no gcp service account will be created and looker dashboard will be used with the executor's personal gcp account only."
}

variable "looker-template-report-id" {
  type        = string
  default     = "64387229-05e0-4951-aa3f-e7349bbafc07"
  description = "Google template looker report id. Do not change."
}

variable "looker-report-name" {
  type        = string
  default     = "Billing-report"
  description = "Copied report name."
}