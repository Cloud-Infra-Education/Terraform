#!/usr/bin/env python3
"""
01-infra 스택을 먼저 적용하여 Bastion 출력 추가
그 다음 03-database 스택 적용
"""
import subprocess
import sys
import os

def run_command(cmd, cwd=None, check=True):
    """명령어 실행"""
    print(f"실행: {' '.join(cmd)}")
    try:
        result = subprocess.run(
            cmd,
            cwd=cwd,
            check=check,
            capture_output=False,
            text=True
        )
        return result.returncode == 0
    except subprocess.CalledProcessError as e:
        print(f"❌ 오류: {e}")
        return False
    except Exception as e:
        print(f"❌ 예외 발생: {e}")
        return False

def apply_stack(stack_name, terraform_dir):
    """스택 적용"""
    print("=" * 60)
    print(f"{stack_name} 스택 적용")
    print("=" * 60)
    print()
    
    # 1. Terraform 초기화
    print("1. Terraform 초기화...")
    if not run_command(["terraform", "init", "-upgrade"], cwd=terraform_dir, check=False):
        if not run_command(["terraform", "init"], cwd=terraform_dir):
            print("❌ Terraform 초기화 실패")
            return False
    print("   ✅ 완료")
    print()
    
    # 2. Terraform 검증
    print("2. Terraform 설정 검증...")
    if not run_command(["terraform", "validate"], cwd=terraform_dir):
        print("❌ Terraform 검증 실패")
        return False
    print("   ✅ 검증 성공")
    print()
    
    # 3. Plan 실행
    print("3. 변경사항 확인...")
    if not run_command(["terraform", "plan", "-var-file=../terraform.tfvars", "-out=tfplan"], cwd=terraform_dir):
        print("❌ Terraform plan 실패")
        return False
    print()
    
    # 4. Apply 실행
    print("4. Terraform apply 실행...")
    if not run_command(["terraform", "apply", "tfplan"], cwd=terraform_dir):
        print("❌ Terraform apply 실패")
        return False
    
    print()
    print(f"✅ {stack_name} 스택 적용 완료!")
    print()
    return True

def main():
    print("=" * 60)
    print("Terraform Apply - Infra + Database")
    print("Bastion 보안 그룹 규칙 추가")
    print("=" * 60)
    print()
    
    # 1단계: 01-infra 스택 적용
    infra_dir = "/root/Terraform/01-infra"
    if not os.path.exists(os.path.join(infra_dir, "main.tf")):
        print(f"❌ Error: {infra_dir}/main.tf 파일을 찾을 수 없습니다.")
        sys.exit(1)
    
    if not apply_stack("01-infra", infra_dir):
        print("❌ 01-infra 스택 적용 실패")
        sys.exit(1)
    
    # 2단계: 03-database 스택 적용
    database_dir = "/root/Terraform/03-database"
    if not os.path.exists(os.path.join(database_dir, "main.tf")):
        print(f"❌ Error: {database_dir}/main.tf 파일을 찾을 수 없습니다.")
        sys.exit(1)
    
    if not apply_stack("03-database", database_dir):
        print("❌ 03-database 스택 적용 실패")
        sys.exit(1)
    
    print("=" * 60)
    print("✅ 모든 스택 적용 완료!")
    print("=" * 60)
    print()
    print("다음 단계:")
    print("1. Bastion Public IP 확인:")
    print("   cd /root/Terraform/01-infra")
    print("   terraform output -json | jq -r '.kor_bastion_public_ip.value'")
    print()
    print("2. Bastion에 SSH 접속하여 Backend 실행")
    print("   자세한 내용은 VPC_BACKEND_SETUP.md 참고")
    print()

if __name__ == "__main__":
    main()
