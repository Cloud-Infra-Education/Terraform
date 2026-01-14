#!/usr/bin/env python3
"""
Bastion 인스턴스 정보 조회 (Instance ID, Public IP)
"""
import subprocess
import json

def run_command(cmd):
    """명령어 실행"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, check=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        return None

def get_terraform_output(stack_dir, output_name):
    """Terraform output 조회"""
    cmd = f"cd {stack_dir} && terraform output -json {output_name} 2>/dev/null"
    output = run_command(cmd)
    if output:
        try:
            data = json.loads(output)
            return data.get('value', 'N/A')
        except:
            return output
    return None

def get_aws_instance_info(region, public_ip):
    """AWS CLI로 인스턴스 정보 조회"""
    cmd = f"aws ec2 describe-instances --region {region} --filters 'Name=ip-address,Values={public_ip}' 'Name=instance-state-name,Values=running' --query 'Reservations[0].Instances[0].[InstanceId,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' --output json 2>/dev/null"
    output = run_command(cmd)
    if output:
        try:
            data = json.loads(output)
            if data and len(data) >= 2:
                return {
                    'instance_id': data[0],
                    'public_ip': data[1],
                    'name': data[2] if len(data) > 2 else 'N/A'
                }
        except:
            pass
    return None

def main():
    print("=" * 60)
    print("Bastion 인스턴스 정보")
    print("=" * 60)
    print()
    
    # Terraform output에서 정보 가져오기
    infra_dir = "/root/Terraform/01-infra"
    
    print("1. Terraform Output에서 정보 조회")
    print("-" * 60)
    
    kor_ip = get_terraform_output(infra_dir, "kor_bastion_public_ip")
    usa_ip = get_terraform_output(infra_dir, "usa_bastion_public_ip")
    kor_id = get_terraform_output(infra_dir, "kor_bastion_instance_id")
    usa_id = get_terraform_output(infra_dir, "usa_bastion_instance_id")
    
    print(f"KOR (Seoul) Bastion:")
    print(f"  Public IP: {kor_ip}")
    print(f"  Instance ID: {kor_id}")
    print()
    print(f"USA (Oregon) Bastion:")
    print(f"  Public IP: {usa_ip}")
    print(f"  Instance ID: {usa_id}")
    print()
    
    # AWS CLI로 추가 정보 조회
    print("2. AWS CLI로 추가 정보 조회")
    print("-" * 60)
    
    if kor_ip:
        kor_info = get_aws_instance_info("ap-northeast-2", kor_ip)
        if kor_info:
            print(f"KOR (Seoul) Bastion:")
            print(f"  Instance ID: {kor_info['instance_id']}")
            print(f"  Public IP: {kor_info['public_ip']}")
            print(f"  Name: {kor_info['name']}")
            print()
    
    if usa_ip:
        usa_info = get_aws_instance_info("us-west-2", usa_ip)
        if usa_info:
            print(f"USA (Oregon) Bastion:")
            print(f"  Instance ID: {usa_info['instance_id']}")
            print(f"  Public IP: {usa_info['public_ip']}")
            print(f"  Name: {usa_info['name']}")
            print()
    
    # SSM 접속 명령어
    print("=" * 60)
    print("SSM Session Manager 접속 명령어")
    print("=" * 60)
    print()
    
    if kor_id and kor_id != 'N/A':
        print(f"# KOR Bastion 접속:")
        print(f"aws ssm start-session --target {kor_id} --region ap-northeast-2")
    elif kor_ip:
        print(f"# KOR Bastion Instance ID를 먼저 확인하세요:")
        print(f"aws ec2 describe-instances --region ap-northeast-2 --filters 'Name=ip-address,Values={kor_ip}' --query 'Reservations[0].Instances[0].InstanceId' --output text")
    print()
    
    if usa_id and usa_id != 'N/A':
        print(f"# USA Bastion 접속:")
        print(f"aws ssm start-session --target {usa_id} --region us-west-2")
    elif usa_ip:
        print(f"# USA Bastion Instance ID를 먼저 확인하세요:")
        print(f"aws ec2 describe-instances --region us-west-2 --filters 'Name=ip-address,Values={usa_ip}' --query 'Reservations[0].Instances[0].InstanceId' --output text")
    print()

if __name__ == "__main__":
    main()
