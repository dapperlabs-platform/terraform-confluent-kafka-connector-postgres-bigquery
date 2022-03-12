terraform {
  required_providers {
    confluentcloud = {
      source  = "Mongey/confluentcloud"
      version = ">= 0.0.12"
    }
    kafka = {
      source  = "Mongey/kafka"
      version = ">= 0.2.11"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 3.60"
    }
  }
}

provider "google" {
  alias = "google"
}

provider "google" {
  alias = "bigquery"
}

data "google_sql_database_instance" "source" {
  name = var.database_server_name
}

resource "google_service_account" "sa" {
  account_id   = var.service_account_name
  display_name = var.service_account_name
}

resource "google_service_account_key" "sa_key" {
  service_account_id = google_service_account.sa.account_id
}

module "confluent_kafka_connector_sa" {
  source                 = "github.com/dapperlabs-platform/terraform-confluent-kafka-connector-service-account?ref=v0.9.0"
  name                   = var.connector_name
  description            = var.description
  environment_id         = var.environment_id
  cluster_id             = var.cluster_id
  connector_topic_prefix = data.google_sql_database_instance.source.name
}

resource "random_id" "user-password" {
  keepers = {
    name = data.google_sql_database_instance.source.name
  }
  byte_length = 8
}

resource "google_sql_user" "source_user" {
  name     = var.database_user_name
  instance = data.google_sql_database_instance.source.name
  password = random_id.user-password.hex

  lifecycle {
    ignore_changes = [password]
  }
}

resource "google_bigquery_dataset" "bq_dataset" {
  provider    = google.bigquery
  dataset_id  = var.bigquery_dataset_id
  description = "${var.bigquery_dataset_id} Confluent PostgreSQL to BigQuery Sink"
  location    = var.bigquery_dataset_location
}

resource "google_bigquery_dataset_iam_member" "bq_dataEditor" {
  provider   = google.bigquery
  dataset_id = google_bigquery_dataset.bq_dataset.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.sa.email}"
}

resource "confluentcloud_connector" "source" {
  name           = "${var.connector_name}-source"
  environment_id = module.confluent_kafka_cluster.environment
  cluster_id     = module.confluent_kafka_cluster.id

  config = {
    "name"                                  = "${var.connector_name}-source"
    "connector.class"                       = "io.debezium.connector.postgresql.PostgresConnector",
    "database.hostname"                     = data.google_sql_database_instance.source.connection_name,
    "database.port"                         = var.database_port,
    "database.dbname"                       = var.database_name,
    "database.server.name"                  = data.google_sql_database_instance.source.name,
    "tombstones.on.delete"                  = "false",
    "include.schema.changes"                = "true",
    "inconsistent.schema.handling.mode"     = "warn",
    "database.history.skip.unparseable.ddl" = "true",
    "table.include.list"                    = var.database_table_include_list,
    "time.precision.mode"                   = "connect",
    "decimal.handling.mode"                 = "double",
    "plugin.name"                           = "pgoutput"
  }

  config_sensitive = {
    "database.user"     = google_sql_user.nba_postgres_bq.name,
    "database.password" = google_sql_user.nba_postgres_bq.password,
    "kafka.api.key"     = module.confluent_kafka_connector_sa.service_account_credentials.key
    "kafka.api.secret"  = module.confluent_kafka_connector_sa.service_account_credentials.secret
  }
}

resource "confluentcloud_connector" "sink" {
  name           = "${var.connector_name}-sink"
  environment_id = module.confluent_kafka_cluster.environment
  cluster_id     = module.confluent_kafka_cluster.id

  config = {
    "connector.class"                        = "com.wepay.kafka.connect.bigquery.BigQuerySinkConnector",
    "tasks.max"                              = var.sink_tasks_max,
    "errors.log.enable"                      = true,
    "errors.log.include.messages"            = true,
    "sanitizeTopics"                         = "true",
    "autoCreateTables"                       = "true",
    "autoUpdateSchemas"                      = "true",
    "bufferSize"                             = "1000",
    "maxWriteSize"                           = "100",
    "tableWriteWait"                         = "10",
    "project"                                = google_bigquery_dataset.bq_dataset.project,
    "defaultDataset"                         = google_bigquery_dataset.bq_dataset.dataset_id,
    "threadPoolSize"                         = 10,
    "upsertEnabled"                          = true,
    "bigQueryPartitionDecorator"             = false,
    "kafkaKeyFieldName"                      = "_DDP_kafkakey",
    "transforms"                             = "route,HoistFieldKey,unwrap",
    "transforms.route.type"                  = "org.apache.kafka.connect.transforms.RegexRouter",
    "transforms.route.regex"                 = "([^.]+)\\.([^.]+)\\.([^.]+)",
    "transforms.route.replacement"           = var.sink_transforms_route_replacement,
    "transforms.HoistFieldKey.type"          = "org.apache.kafka.connect.transforms.HoistField$Key",
    "transforms.HoistFieldKey.field"         = "user_id",
    "transforms.unwrap.type"                 = "io.debezium.transforms.ExtractNewRecordState",
    "transforms.unwrap.drop.tombstones"      = false,
    "transforms.unwrap.delete.handling.mode" = "rewrite",
    "transforms.unwrap.add.fields"           = "op,source.ts_ms,ts_ms",
    "transforms.unwrap.add.fields.prefix"    = "_DDP_",
    "transforms.unwrap.add.headers.prefix"   = "_DDP_",
    "allowNewBigQueryFields"                 = "true",
    "allowBigQueryRequiredFieldRelaxation"   = "true",
    "schemaRetriever"                        = "com.wepay.kafka.connect.bigquery.retrieve.IdentitySchemaRetriever",
    "key.converter"                          = "org.apache.kafka.connect.storage.StringConverter",
    "allBQFieldsNullable"                    = true,
    "topics.regex"                           = "${data.google_sql_database_instance.source.name}.${var.database_table_include_list}"
  }

  config_sensitive = {
    "keyfile" = google_service_account_key.nba_postgres_bq.private_key
  }
}
