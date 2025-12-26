resource "aws_ecr_repository" "user" {
  name                 = "user-service"
  image_tag_mutability = "IMMUTABLE"
}

resource "aws_ecr_repository" "order" {
  name                 = "order-service"
  image_tag_mutability = "IMMUTABLE"
}

resource "aws_ecr_repository" "product" {
  name                 = "product-service"
  image_tag_mutability = "IMMUTABLE"
}

