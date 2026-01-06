**scripts/terraform-apply.sh 설명**

이 스크립트 파일 단일실행으로 모든 인프라 구성이 가능합니다.

원하는 리소스만큼만 구성하는 것이 가능합니다.

1번 코드는 기본인프라 구성부터 ArgoCD, EKS, DB 설치까지 진행됩니다. 즉 2번, 3번, 4번으로 구축되는 인프라를 제외하고 모두 구축됩니다.

2번 코드는 ArgoCD 앱 설치를 진행합니다. ArgoCD 설치와 ArgoCD 앱은 별개입니다!  

3번 코드는 CloudFront, ACM 'ISSUE' 상태화, Ingress(ALB) 생성 작업이 진행됩니다.

  - Route53으로 등록한 도메인은 공동이기 때문에 이 단계는 다른 팀원과 겹치면 안됩니다.

4번 코드는 GA를 구성합니다.


========================================

**scripts/terraform-destroy.sh 설명**

만약 terraform-apply.sh 에 있는 모든 실행코드를 apply 했다면 이 쉘파일 단일실행만으로 모든 인프라가 지워집니다.

if-1) terraform-apply.sh 의 4번 코드(GA) 실행을 안했다면 #GA 파트는 생략해주세요

if-1) terraform-apply.sh 의 3번 코드(Domain) 실행을 안했다면 #Domain 파트는 생략해주세요

if-2) terraform-apply.sh 의 2번 코드(ArgoCD앱) 실행을 안했다면 #ArgoCD 파트의 1,2번 라인을 생략해주세요
