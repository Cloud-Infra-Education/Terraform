# State migration helpers (Terraform >= 1.1).
# If you already applied the previous flat layout, keep this file so resources are moved (not recreated).

moved {
  from = module.kor_vpc
  to   = module.network.module.kor_vpc
}

moved {
  from = module.usa_vpc
  to   = module.network.module.usa_vpc
}

moved {
  from = module.eks_seoul
  to   = module.eks.module.eks_seoul
}

moved {
  from = module.eks_oregon
  to   = module.eks.module.eks_oregon
}

moved {
  from = module.alb_controller_irsa
  to   = module.addons.module.alb_controller_irsa
}

moved {
  from = module.alb_controller_irsa_oregon
  to   = module.addons.module.alb_controller_irsa_oregon
}

moved {
  from = aws_iam_policy.alb_controller
  to   = module.addons.aws_iam_policy.alb_controller
}

moved {
  from = kubernetes_service_account_v1.alb_controller_oregon
  to   = module.addons.kubernetes_service_account_v1.alb_controller_oregon
}

moved {
  from = helm_release.aws_load_balancer_controller_oregon
  to   = module.addons.helm_release.aws_load_balancer_controller_oregon
}

moved {
  from = kubernetes_service_account_v1.alb_controller
  to   = module.addons.kubernetes_service_account_v1.alb_controller
}

moved {
  from = helm_release.aws_load_balancer_controller
  to   = module.addons.helm_release.aws_load_balancer_controller
}

moved {
  from = helm_release.argocd_seoul
  to   = module.argocd.helm_release.argocd_seoul
}

moved {
  from = helm_release.argocd_oregon
  to   = module.argocd.helm_release.argocd_oregon
}

moved {
  from = aws_ecr_replication_configuration.seoul_to_oregon
  to   = module.ecr.aws_ecr_replication_configuration.seoul_to_oregon
}

moved {
  from = aws_ecr_repository.user
  to   = module.ecr.aws_ecr_repository.user
}

moved {
  from = aws_ecr_repository.order
  to   = module.ecr.aws_ecr_repository.order
}

moved {
  from = aws_ecr_repository.product
  to   = module.ecr.aws_ecr_repository.product
}

moved {
  from = aws_ecr_repository.user_oregon
  to   = module.ecr.aws_ecr_repository.user_oregon
}

moved {
  from = aws_ecr_repository.order_oregon
  to   = module.ecr.aws_ecr_repository.order_oregon
}

moved {
  from = aws_ecr_repository.product_oregon
  to   = module.ecr.aws_ecr_repository.product_oregon
}

moved {
  from = aws_eks_access_entry.terraform_admin
  to   = module.eks.aws_eks_access_entry.terraform_admin
}

moved {
  from = aws_eks_access_policy_association.terraform_admin_cluster
  to   = module.eks.aws_eks_access_policy_association.terraform_admin_cluster
}

moved {
  from = aws_eks_access_entry.terraform_admin_oregon
  to   = module.eks.aws_eks_access_entry.terraform_admin_oregon
}

moved {
  from = aws_eks_access_policy_association.terraform_admin_cluster_oregon
  to   = module.eks.aws_eks_access_policy_association.terraform_admin_cluster_oregon
}

moved {
  from = aws_ec2_transit_gateway_peering_attachment.kor_to_usa
  to   = module.network.aws_ec2_transit_gateway_peering_attachment.kor_to_usa
}

moved {
  from = aws_ec2_transit_gateway_peering_attachment_accepter.usa_accept
  to   = module.network.aws_ec2_transit_gateway_peering_attachment_accepter.usa_accept
}

moved {
  from = aws_ec2_transit_gateway_route_table.kor
  to   = module.network.aws_ec2_transit_gateway_route_table.kor
}

moved {
  from = aws_ec2_transit_gateway_route_table.usa
  to   = module.network.aws_ec2_transit_gateway_route_table.usa
}

moved {
  from = aws_ec2_transit_gateway_route.kor_to_usa_default
  to   = module.network.aws_ec2_transit_gateway_route.kor_to_usa_default
}

moved {
  from = aws_ec2_transit_gateway_route.usa_to_kor_default
  to   = module.network.aws_ec2_transit_gateway_route.usa_to_kor_default
}

moved {
  from = aws_ec2_transit_gateway.kor
  to   = module.network.aws_ec2_transit_gateway.kor
}

moved {
  from = aws_ec2_transit_gateway.usa
  to   = module.network.aws_ec2_transit_gateway.usa
}

moved {
  from = time_sleep.wait_for_tgw
  to   = module.network.time_sleep.wait_for_tgw
}
