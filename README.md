** 스택이 분리됐기 때문에 각 스택 디렉터리가 tfvars 파일을 갖고 있어야 해요 **

## 자동으로 리소스를 생성 ##

- scripts/terraform-apply.sh


## 자동으로 리소스를 삭제 ##

- scripts/terraform-destroy.sh


## 자동으로 tfvars 파일 배포 ##

- scripts/copy-tfvars-to-stacks.sh


## 디렉토리

- `01-infra` : VPC/Network, S3, Database
- `02-kubernetes` : EKS, ECR
- `03-database` : DB, RDS Proxy
- `04-addons` : Addons(ALB Controller 등)
- `05-argocd` : ArgoCD(+옵션: Application)
- `06-certificate` : ACM, WAF
- `07-domain-cf` : Route53, ACM Validation, CloudFront, Ingress(ALB)
- `08-domain-ga` : Global Accelerator + api A레코드

##순서대로 실행하는 것을 권장합니다##

