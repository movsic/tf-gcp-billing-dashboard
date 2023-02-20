output "looker_report_link" {
  #https://developers.google.com/looker-studio/integrate/linking-api
  description = "Looker Linking API url."
  value       = "https://datastudio.google.com/reporting/create?c.reportId=${var.looker-template-report-id}&r.reportName=${var.looker-report-name}&ds.ds8.refreshFields=false&ds.ds8.connector=bigQuery&ds.ds8.projectId=${var.project-id}&ds.ds8.type=TABLE&ds.ds8.datasetId=${var.bq-dashboard-dataset-name}&ds.ds8.tableId=${var.bq-dashboard-view-name}"
}

output "gcp_service_account_name" {
  #https://developers.google.com/looker-studio/integrate/linking-api
  description = "Gcp service account name to be used with looker dashboard as datasource credentials."
  value       = var.looker-studio-service-agent-name != null ? google_service_account.looker_studio[0].email : null
}