resource "aws_instance" "test" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.test.id]
  key_name               = var.key_name

  tags = {
    Name = "${var.name}-test-ec2"
  }
}
