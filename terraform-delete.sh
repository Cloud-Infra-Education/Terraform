#!/bin/bash
set -e

terraform destroy -target=module.eks -auto-approve
terraform destroy -target=module.alb_controller_irsa -auto-approve
terraform destroy -target=module.kor_vpc.aws_nat_gateway.this -auto-approve
terraform destroy -auto-approve




