resource "aws_ecr_repository" "user" {
  provider             = aws.seoul
  name                 = "user-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true 
}
resource "aws_ecr_repository" "order" {
  provider             = aws.seoul
  name                 = "order-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true 
}
resource "aws_ecr_repository" "product" {
  provider             = aws.seoul
  name                 = "product-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true 
}





resource "aws_ecr_repository" "user_oregon" {
  provider             = aws.oregon
  name                 = "user-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true 
}
resource "aws_ecr_repository" "order_oregon" {
  provider             = aws.oregon
  name                 = "order-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true 
}
resource "aws_ecr_repository" "product_oregon" {
  provider             = aws.oregon
  name                 = "product-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true 
}

