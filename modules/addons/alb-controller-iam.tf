resource "aws_iam_policy" "alb_controller" {
  name = "y2om-AWSLoadBalancerControllerIAMPolicy"

  policy = file("${path.module}/iam_policy.json")
}

