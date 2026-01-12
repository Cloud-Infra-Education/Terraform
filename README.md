**스택이 분리됐기 때문에 각 스택 디렉터리가 tfvars 파일을 갖고 있어야 해요**

## 스크립트 파일 활용 ##

**`scripts/terraform-apply.sh`** : 리소스 자동생성

**`scripts/terraform-destroy.sh`** : 리소스 자동소멸

**`scripts/copy-tfvars-to-stacks.sh`** : 루트 디렉터리에 있는 tfvars를 모든 스택으로 분배


## 디렉토리

- `01-infra` : VPC/Network, S3, Database
- `02-kubernetes` : EKS, ECR
- `03-database` : DB, RDS Proxy
- `04-addons` : Addons(ALB Controller 등)
- `05-argocd` : ArgoCD(+옵션: Application)
- `06-certificate` : ACM, WAF
- `07-domain-cf` : Route53, ACM Validation, CloudFront, Ingress(ALB)
- `08-domain-ga` : Global Accelerator + api A레코드
- `09-` : 
- `10-app-monitoring` : LGTM + Alloy (지금은 서울만)

**순서대로 실행하는 것을 권장합니다**


**참고**:

`02-kubernetes`를 수동으로 지울 때 아래 명령어를 먼저 실행하고 destroy 해야합니다.
- terraform state rm module.eks.helm_release.cluster_autoscaler_seoul
- terraform state rm module.eks.helm_release.cluster_autoscaler_oregon

`07-domain-cf` `08-domain-ga` 는 공용 도메인을 사용하여 작업하기 때문에 팀원과 겹치면 안됩니다.

`10-app-monitoring`를 수동으로 지울 때 아래 명령어를 먼저 실행하고 destroy 해야 합니다.
- kubectl delete pod -n app-monitoring-seoul loki-write-{0..2} 

S3는 지우기 전에 Bucket이 Empty 상태여야 합니다. 


