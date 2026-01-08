#!/usr/bin/env bash
set -euo pipefail



# 1) 기본 인프라 구성 
terraform apply -auto-approve


# 2) ArgoCD 앱 설치 
sleep 1
terraform apply -var="argocd_app_enabled=true" -auto-approve


# 3) LGTM 구성
sleep 1
terraform apply -var="argocd_app_enabled=true" -var="app_monitoring_enabled=true" -auto-approve


# 4) Domain - CloudFront & ACM ISSUE 작업 & ingress 적용
sleep 1
terraform apply -var="argocd_app_enabled=true" -var="app_monitoring_enabled=true" -var="domain_set_enabled=true" -auto-approve


# 5) GA 구성
sleep 1 
terraform apply -var="argocd_app_enabled=true" -var="app_monitoring_enabled=true" -var="domain_set_enabled=true" -var="ga_set_enabled=true" -auto-approve
