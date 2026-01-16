resource "aws_ecr_repository" "user" {
  provider             = aws.seoul
  name                 = "y2om-user-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true
}
resource "aws_ecr_repository" "order" {
  provider             = aws.seoul
  name                 = "y2om-order-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true
}
resource "aws_ecr_repository" "product" {
  provider             = aws.seoul
  name                 = "y2om-product-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true
}

resource "aws_ecr_repository" "backend_api" {
  provider             = aws.seoul
  name                 = "backend-api"
  image_tag_mutability = "MUTABLE"  # latest 태그 사용을 위해 MUTABLE
  force_delete         = true
}



/*
resource "aws_ecr_repository" "user_oregon" {
  provider             = aws.oregon
  name                 = "y2om-user-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true
}
resource "aws_ecr_repository" "order_oregon" {
  provider             = aws.oregon
  name                 = "y2om-order-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true
}
resource "aws_ecr_repository" "product_oregon" {
  provider             = aws.oregon
  name                 = "y2om-product-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true
}
*/
