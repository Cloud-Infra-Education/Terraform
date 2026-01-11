data "terraform_remote_state" "infra" {
  backend = "local"
  config = { path = var.infra_state_path }
}

data "terraform_remote_state" "kubernetes" {
  backend = "local"
  config = { path = var.kubernetes_state_path }
}

data "terraform_remote_state" "certificate" {
  backend = "local"
  config = { path = var.certificate_state_path }
}
