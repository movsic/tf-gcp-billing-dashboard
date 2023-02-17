#TODO output looker sa registration
#TODO output sa instructions
#TODO is looker account a service account?

#Need to know the associated org id to to construct a looker studio service agent name
data "google_project" "current_project" {
  project_id = var.project-id
}

resource "google_bigquery_table" "target_view_name" {
  dataset_id = var.bq-dashboard-dataset-name
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
  account_id   = var.looker-studio-service-account-name
  display_name = "Service Account to be used by looker studio for billing dashboard"
}

resource "google_project_iam_binding" "looker_studio_sa_bq_viewer" {
  project = var.project-id
  role    = "roles/bigquery.dataViewer"

  members = [
    "serviceAccount:${google_service_account.looker_studio.email}"
  ]
}

resource "google_project_iam_binding" "looker_studio_sa_bq_job_user" {
  project = var.project-id
  role    = "roles/bigquery.jobUser"

  members = [
    "serviceAccount:${google_service_account.looker_studio.email}"
  ]
}

resource "google_service_account_iam_binding" "token-creator-iam" {
  service_account_id = google_service_account.looker_studio.id
  role               = "roles/iam.serviceAccountTokenCreator"
  members = [
    "serviceAccount:service-org-${data.google_project.current_project.org_id}@gcp-sa-datastudio.iam.gserviceaccount.com",
  ]
}