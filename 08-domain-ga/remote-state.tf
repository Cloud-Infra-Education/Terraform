# 07-domain-cf 정보 (기존)
data "terraform_remote_state" "domain_cf" {
  backend = "local"

  config = {
    path = var.domain_cf_state_path
  }
}

# 01-infra 정보 (추가: S3 버킷 이름을 가져오기 위함)
data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = "../01-infra/terraform.tfstate"
  }
}
