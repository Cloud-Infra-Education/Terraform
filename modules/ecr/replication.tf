data "aws_caller_identity" "current" {
  provider = aws.seoul
}


resource "aws_ecr_replication_configuration" "seoul_to_oregon" {
  provider = aws.seoul

  replication_configuration {
    rule {
      destination {
        region      = "us-west-2"
        registry_id = data.aws_caller_identity.current.account_id
      }
/*
      dynamic "repository_filter" {
        for_each = toset(var.ecr_replication_repo_prefixes)
        content {
          filter      = repository_filter.value
          filter_type = "PREFIX_MATCH"
        }
      }
*/
    }
  }
}
