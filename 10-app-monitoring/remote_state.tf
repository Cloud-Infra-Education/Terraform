data "terraform_remote_state" "kubernetes" {
  backend = "local"
  config = {
    path = var.kubernetes_state_path
  }
}
