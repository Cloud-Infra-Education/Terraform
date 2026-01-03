**scripts/terraform-apply.sh 설명**

1번 코드는 기본인프라 구성부터 ArgoCD EKS 설치까지 진행됩니다. 즉 2번, 3번으로 구축되는 인프라를 제외하고 모두 구축됩니다.

2번 코드는 ArgoCD 앱 설치를 진행합니다. ArgoCD 설치와 ArgoCD 앱은 별개입니다!  

3번 코드는 도메인 관련 인프라 설치를 진행합니다. 

본인이 필요한 리소스만 apply 할 수 있어요. 

최종목표는 terraform-apply.sh 단일실행으로 모든 인프라를 구성하는 것이지만 지금은 번거로워도 하나씩 하는게 안정적이에요

========================================

**scripts/terraform-destroy.sh 설명**

만약 terraform-apply.sh 에 있는 모든 실행코드를 apply 했다면 이 쉘파일 단일실행만으로 모든 인프라가 지워집니다.

if-1) terraform-apply.sh 의 3번 코드(도메인 구성) 실행을 안했다면 #GA 파트는 생략해주세요

if-2) terraform-apply.sh 의 2번 코드(ArgoCD앱) 실행을 안했다면 #ArgoCD 파트의 1,2번 라인을 생략해주세요
