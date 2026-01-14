# Bastion SSH 키는 formation-lap/db/dev/credentials Secret에 포함되어 있음
# 별도의 bastion/ssh-key Secret은 사용하지 않음
# 
# # Bastion SSH 키를 Secrets Manager에 저장
# resource "aws_secretsmanager_secret" "bastion_ssh_key" {
#   provider = aws.seoul
#   
#   name        = "${var.our_team}/bastion/ssh-key"
#   description = "SSH private key for Bastion host access"
#   
#   tags = {
#     Name = "${var.our_team}-bastion-ssh-key"
#   }
# }
#
# SSH 키는 formation-lap/db/dev/credentials Secret의 ssh_key 필드에 저장됨
# AWS CLI로 설정:
# aws secretsmanager put-secret-value \
#   --secret-id formation-lap/db/dev/credentials \
#   --secret-string '{"username":"admin","password":"...","ssh_key":"..."}' \
#   --region ap-northeast-2
