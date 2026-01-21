terraform init
terraform apply -auto-approve -var="argocd_app_enabled=false"
terraform apply -auto-approve -var="argocd_app_enabled=true"
