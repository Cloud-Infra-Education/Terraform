resource "aws_iam_policy" "alb_controller" {
  name = "AWSLoadBalancerControllerIAMPolicy"

  policy = file("${path.module}/iam_policy.json")
}

