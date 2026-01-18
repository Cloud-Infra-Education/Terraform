resource "aws_iam_policy" "alb_controller" {
#  name = "AWSLoadBalancerControllerIAMPolicy"
  name = "test-AWSLoadBalancerControllerIAMPolicy"

  policy = file("${path.module}/iam_policy.json")
}

