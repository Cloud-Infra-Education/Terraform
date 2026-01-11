data "terraform_remote_state" "domain_cf" {
  backend = "local"

  config = {
    path = var.domain_cf_state_path
  }
}
