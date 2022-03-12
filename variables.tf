variable "bigquery_dataset_id" {
  description = "Identifier for the Big Query dataset sink"
  type        = string
}

variable "bigquery_dataset_location" {
  description = "Location for the Big Query dataset sink"
  type        = string
  default     = "US"
}

variable "cluster_id" {
  description = "Cluster identifier for assigning the api key"
  type        = string
}

variable "connector_name" {
  description = "Name for the connector"
  type        = string
}

variable "database_name" {
  description = "Source PostgreSQL database name"
  type        = string
  default     = "postgres"
}

variable "database_port" {
  description = "Source PostgreSQL database port"
  type        = string
  default     = "5432"
}

variable "database_server_name" {
  description = "Source PostgreSQL database server name"
  type        = string
}

variable "database_table_include_list" {
  description = "Source PostgreSQL database name"
  type        = string
  default     = "public.*"
}

variable "database_user_name" {
  description = "Source PostgreSQL data user name"
  type        = string
  default     = "postgres_confluent_bq"
}

variable "description" {
  description = "Description for the service account and its purpose"
  type        = string
}

variable "enable_connect_lcc" {
  description = "Connector consumer group connect topic access"
  type        = bool
  default     = true
}

variable "enable_success_error_lcc" {
  description = "Connector success and error topic access"
  type        = bool
  default     = true
}

variable "environment_id" {
  description = "Application environment identifier that uses the cluster"
  type        = string
}

variable "service_account_name" {
  description = "Name for the service account"
  type        = string
}

variable "sink_tasks_max" {
  description = "Maximum tasks allocated to the BigQuery sink"
  type        = string
  default     = "1"
}

variable "sink_transforms_route_replacement" {
  description = "I don't know, but looks important..."
  type        = string
  default     = "dev_stg_2_$3"
}
