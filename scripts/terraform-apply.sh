#!/bin/bash

# 1) 기본 인프라 구성
terraform apply -auto-approve

# 2) ArgoCD 앱 설치 
sleep 1
terraform apply -var="argocd_app_enabled=true" -auto-approve

# 3) Domain 구성(Route53, GA, CloudFront)
sleep 1 
terraform apply -var="argocd_app_enabled=true" -var="domain_set_enabled=true" -auto-approve
