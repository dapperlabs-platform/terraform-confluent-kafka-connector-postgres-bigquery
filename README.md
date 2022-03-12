# Confluent Kafka Connector Postgres to BigQuery
https://registry.terraform.io/providers/Mongey/confluentcloud/latest/docs

https://registry.terraform.io/providers/Mongey/kafka/latest/docs

## What does this do?
Creates a connector for the Kafka cluster to stream data changes from Postgres to BigQuery.

## How to use this module?
Notable requirement is to pass a `provider.bigquery` provider which connects to the GPC project within which BigQuery 
exists.  Done to support data warehousing existing in a different project than the database.

```
module "confluent_kafka_connector_pg_bq" {
  source = "github.com/dapperlabs-platform/terraform-confluent-kafka-connector-postgres-bigquery?ref=v0.9.0"

  providers = {
    google.bigquery = google.dapperlabs-data
  }

  connector_name       = "$NAME"
  description          = "$DESCRIPTION"
  environment_id       = "$ENVIRONMENT_ID"
  cluster_id           = "$CLUSTER_ID"
  bigquery_dataset_id  = "$DATASET_ID"
  database_server_name = "$DATABASE_SERVER_NAME"
  service_account_name = "$SERVICE_ACCOUNT_NAME"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_confluentcloud"></a> [confluentcloud](#requirement\_confluentcloud) (>= 0.0.12)

- <a name="requirement_google"></a> [google](#requirement\_google) (>= 3.60)

- <a name="requirement_kafka"></a> [kafka](#requirement\_kafka) (>= 0.2.11)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.1.0)

## Providers

The following providers are used by this module:

- <a name="provider_confluentcloud"></a> [confluentcloud](#provider\_confluentcloud) (>= 0.0.12)

- <a name="provider_google"></a> [google](#provider\_google) (>= 3.60)

- <a name="provider_google.bigquery"></a> [google.bigquery](#provider\_google.bigquery) (>= 3.60)

- <a name="provider_random"></a> [random](#provider\_random) (>= 3.1.0)

## Modules

The following Modules are called:

### <a name="module_confluent_kafka_connector_sa"></a> [confluent\_kafka\_connector\_sa](#module\_confluent\_kafka\_connector\_sa)

Source: github.com/dapperlabs-platform/terraform-confluent-kafka-connector-service-account

Version: v0.9.0

## Resources

The following resources are used by this module:

- [confluentcloud_connector.sink](https://registry.terraform.io/providers/Mongey/confluentcloud/latest/docs/resources/connector) (resource)
- [confluentcloud_connector.source](https://registry.terraform.io/providers/Mongey/confluentcloud/latest/docs/resources/connector) (resource)
- [google_bigquery_dataset.bq_dataset](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset) (resource)
- [google_bigquery_dataset_iam_member.bq_dataEditor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset_iam_member) (resource)
- [google_service_account.sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) (resource)
- [google_service_account_key.sa_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) (resource)
- [google_sql_user.source_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user) (resource)
- [random_id.user-password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [google_sql_database_instance.source](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/sql_database_instance) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_bigquery_dataset_id"></a> [bigquery\_dataset\_id](#input\_bigquery\_dataset\_id)

Description: Identifier for the Big Query dataset sink

Type: `string`

### <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id)

Description: Cluster identifier for assigning the api key

Type: `string`

### <a name="input_connector_name"></a> [connector\_name](#input\_connector\_name)

Description: Name for the connector

Type: `string`

### <a name="input_database_server_name"></a> [database\_server\_name](#input\_database\_server\_name)

Description: Source PostgreSQL database server name

Type: `string`

### <a name="input_description"></a> [description](#input\_description)

Description: Description for the service account and its purpose

Type: `string`

### <a name="input_environment_id"></a> [environment\_id](#input\_environment\_id)

Description: Application environment identifier that uses the cluster

Type: `string`

### <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name)

Description: Name for the service account

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_bigquery_dataset_location"></a> [bigquery\_dataset\_location](#input\_bigquery\_dataset\_location)

Description: Location for the Big Query dataset sink

Type: `string`

Default: `"US"`

### <a name="input_database_name"></a> [database\_name](#input\_database\_name)

Description: Source PostgreSQL database name

Type: `string`

Default: `"postgres"`

### <a name="input_database_port"></a> [database\_port](#input\_database\_port)

Description: Source PostgreSQL database port

Type: `string`

Default: `"5432"`

### <a name="input_database_table_include_list"></a> [database\_table\_include\_list](#input\_database\_table\_include\_list)

Description: Source PostgreSQL database name

Type: `string`

Default: `"public.*"`

### <a name="input_database_user_name"></a> [database\_user\_name](#input\_database\_user\_name)

Description: Source PostgreSQL data user name

Type: `string`

Default: `"postgres_confluent_bq"`

### <a name="input_enable_connect_lcc"></a> [enable\_connect\_lcc](#input\_enable\_connect\_lcc)

Description: Connector consumer group connect topic access

Type: `bool`

Default: `true`

### <a name="input_enable_success_error_lcc"></a> [enable\_success\_error\_lcc](#input\_enable\_success\_error\_lcc)

Description: Connector success and error topic access

Type: `bool`

Default: `true`

### <a name="input_sink_tasks_max"></a> [sink\_tasks\_max](#input\_sink\_tasks\_max)

Description: Maximum tasks allocated to the BigQuery sink

Type: `string`

Default: `"1"`

### <a name="input_sink_transforms_route_replacement"></a> [sink\_transforms\_route\_replacement](#input\_sink\_transforms\_route\_replacement)

Description: I don't know, but looks important...

Type: `string`

Default: `"dev_stg_2_$3"`

## Outputs

No outputs.
<!-- END_TF_DOCS -->