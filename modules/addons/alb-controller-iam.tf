resource "aws_iam_policy" "alb_controller" {
  #name = "AWSLoadBalancerControllerIAMPolicy"
  name = "yuh-AWSLoadBalancerControllerIAMPolicy"

  policy = file("${path.module}/iam_policy.json")
}

