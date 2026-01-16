# Security Group for Lambda
resource "aws_security_group" "lambda" {
  name        = "yuh-formation-lap-video-processor-sg"
  description = "Security group for video processor Lambda function"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "yuh-formation-lap-video-processor-sg"
  }
}
