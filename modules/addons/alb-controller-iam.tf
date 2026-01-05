resource "aws_iam_policy" "alb_controller" {
  name = "AWSLoadBalancerControllerIAMPolicy1"

  policy = file("${path.module}/iam_policy.json")
}

