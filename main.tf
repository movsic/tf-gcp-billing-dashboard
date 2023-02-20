#Need to know the associated org id to to construct a looker studio service agent name
data "google_project" "current_project" {
  project_id = local.project-id
}

locals {
  #currently not used as there is no way to automatically create looker studio service agents
  project-id = split(".", var.bq-dashboard-dataset-name)[0]
  dataset-id = split(".", var.bq-dashboard-dataset-name)[1]
  looker-studio-service-agent-name = var.looker-studio-service-agent-name == null ? "serviceAccount:service-org-${data.google_project.current_project.org_id}@gcp-sa-datastudio.iam.gserviceaccount.com" : "serviceAccount:${var.looker-studio-service-agent-name}"
}

resource "google_bigquery_table" "target_view_name" {
  project = local.project-id
  dataset_id = local.dataset-id
  table_id   = var.bq-dashboard-view-name

  #needed to be able to recreate the view when terraform changes are applyed terraform
  deletion_protection = false

  view {
    use_legacy_sql = false
    query          = <<EOF
      SELECT *, 
      COALESCE((SELECT SUM(x.amount) FROM UNNEST(source.credits) x),0) AS credits_sum_amount, 
      COALESCE((SELECT SUM(x.amount) FROM UNNEST(source.credits) x),0) + cost as net_cost, 
      PARSE_DATE('%Y%m', invoice.month) AS Invoice_Month,
      _PARTITIONDATE AS date 
      FROM `${var.bq-billing-export-table-name}` source 
      WHERE _PARTITIONDATE > DATE_SUB(CURRENT_DATE(), INTERVAL ${var.billing-data-interval} MONTH)
EOF
  }
}

#service account to be used with looker studio service agent
resource "google_service_account" "looker_studio" {
  count        = var.looker-studio-service-agent-name != null ? 1 : 0
  project = local.project-id
  account_id   = var.looker-studio-service-account-name
  display_name = "Service Account to be used by looker studio for billing dashboard"
}

resource "google_project_iam_binding" "looker_studio_sa_bq_viewer" {
  count   = var.looker-studio-service-agent-name != null ? 1 : 0
  project = local.project-id
  role    = "roles/bigquery.dataViewer"

  members = [
    "serviceAccount:${google_service_account.looker_studio[0].email}"
  ]
}

resource "google_project_iam_binding" "looker_studio_sa_bq_job_user" {
  count   = var.looker-studio-service-agent-name != null ? 1 : 0
  project = local.project-id
  role    = "roles/bigquery.jobUser"

  members = [
    "serviceAccount:${google_service_account.looker_studio[0].email}"
  ]
}

resource "google_service_account_iam_binding" "token-creator-iam" {
  count              = var.looker-studio-service-agent-name != null ? 1 : 0
  service_account_id = google_service_account.looker_studio[0].id
  role               = "roles/iam.serviceAccountTokenCreator"
  members = [
    "serviceAccount:${var.looker-studio-service-agent-name}",
  ]
}