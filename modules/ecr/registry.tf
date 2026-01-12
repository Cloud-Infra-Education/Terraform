resource "aws_ecr_repository" "user" {
  provider             = aws.seoul
  name                 = "user1-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true 
}
resource "aws_ecr_repository" "order" {
  provider             = aws.seoul
  name                 = "order1-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true 
}
resource "aws_ecr_repository" "product" {
  provider             = aws.seoul
  name                 = "product1-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true 
}





resource "aws_ecr_repository" "user_oregon" {
  provider             = aws.oregon
  name                 = "user1-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true 
}
resource "aws_ecr_repository" "order_oregon" {
  provider             = aws.oregon
  name                 = "order1-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true 
}
resource "aws_ecr_repository" "product_oregon" {
  provider             = aws.oregon
  name                 = "product1-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true 
}

