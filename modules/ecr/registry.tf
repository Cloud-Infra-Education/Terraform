resource "aws_ecr_repository" "user" {
  provider             = aws.seoul
  name                 = "user-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true
}

resource "aws_ecr_repository" "backend_api" {
  provider             = aws.seoul
  name                 = "backend-api"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true
}
