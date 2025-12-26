# aws 로드밸런서 컨트롤러 권한정책은 이미 aws에 만들어져 있으니 그걸 테라폼이 참조하도록
terraform import \
aws_iam_policy.alb_controller \
arn:aws:iam::404457776061:policy/AWSLoadBalancerControllerIAMPolicy

