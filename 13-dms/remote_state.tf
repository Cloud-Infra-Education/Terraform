data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = var.infra_state_path
  }
}

data "terraform_remote_state" "database" {
  backend = "local"

  config = {
    path = var.database_state_path
  }
}

