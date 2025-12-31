#!/usr/bin/env bash
set -euo pipefail

# 1) ArgoCD
terraform destroy -target=module.argocd.helm_release.argocd_seoul -auto-approve
terraform destroy -target=module.argocd.helm_release.argocd_oregon -auto-approve

# 2) K8s/Helm addons (AWS Load Balancer Controller)
terraform destroy -target=module.addons.helm_release.aws_load_balancer_controller -auto-approve
terraform destroy -target=module.addons.kubernetes_service_account_v1.alb_controller -auto-approve
terraform destroy -target=module.addons.helm_release.aws_load_balancer_controller_oregon -auto-approve
terraform destroy -target=module.addons.kubernetes_service_account_v1.alb_controller_oregon -auto-approve

# 3) IRSA roles
terraform destroy -target=module.addons.module.alb_controller_irsa -auto-approve
terraform destroy -target=module.addons.module.alb_controller_irsa_oregon -auto-approve

# 4) EKS
terraform destroy -target=module.eks.module.eks_seoul -auto-approve
terraform destroy -target=module.eks.module.eks_oregon -auto-approve

# 5) Everything
terraform destroy -auto-approve
