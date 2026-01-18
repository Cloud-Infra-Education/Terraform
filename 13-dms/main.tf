module "dms" {
  source = "../modules/dms"

  providers = {
    aws = aws.seoul
  }

  name_prefix = "onprem-to-kor-aurora"

  vpc_id     = data.terraform_remote_state.infra.outputs.kor_vpc_id
  subnet_ids = data.terraform_remote_state.infra.outputs.kor_private_db_subnet_ids

  target_db_security_group_id = data.terraform_remote_state.database.outputs.kor_db_security_group_id

  source_engine_name   = var.dms_source_engine_name
  source_server_name   = var.dms_source_server_name
  source_port          = var.dms_source_port
  source_database_name = var.dms_source_database_name
  source_username      = var.dms_source_username
  source_password      = var.dms_source_password
  source_ssl_mode      = var.dms_source_ssl_mode

  target_engine_name   = "aurora"
  target_server_name   = data.terraform_remote_state.database.outputs.kor_cluster_endpoint
  target_port          = 3306
  target_database_name = var.dms_target_database_name
  target_username      = var.db_username
  target_password      = var.db_password
  target_ssl_mode      = var.dms_target_ssl_mode

  migration_type            = var.dms_migration_type
  table_mappings            = var.dms_table_mappings
  replication_task_settings = var.dms_replication_task_settings

  start_replication_task = "true"

}
