#!/usr/bin/env python3
"""
Bastion 보안 그룹 및 EC2 Instance Connect 설정 확인
"""
import subprocess
import json

def run_cmd(cmd):
    """명령어 실행"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return result.stdout.strip(), result.returncode
    except Exception as e:
        return str(e), 1

def main():
    print("=" * 60)
    print("Bastion 보안 그룹 및 EC2 Instance Connect 설정 확인")
    print("=" * 60)
    print()
    
    kor_ip = "35.92.218.177"
    instance_id = "i-0088889a043f54312"  # 이미지에서 확인된 인스턴스 ID
    
    # 1. 인스턴스 정보 확인
    print("1. 인스턴스 정보 확인")
    print("-" * 60)
    cmd = f"aws ec2 describe-instances --region ap-northeast-2 --instance-ids {instance_id} --query 'Reservations[0].Instances[0]' --output json"
    output, code = run_cmd(cmd)
    
    if code == 0 and output:
        try:
            instance = json.loads(output)
            sg_ids = [sg['GroupId'] for sg in instance.get('SecurityGroups', [])]
            iam_role = instance.get('IamInstanceProfile', {}).get('Arn', 'N/A')
            public_ip = instance.get('PublicIpAddress', 'N/A')
            state = instance.get('State', {}).get('Name', 'N/A')
            
            print(f"Instance ID: {instance_id}")
            print(f"Public IP: {public_ip}")
            print(f"State: {state}")
            print(f"보안 그룹: {', '.join(sg_ids)}")
            print(f"IAM 역할: {iam_role}")
            print()
            
            # 2. 보안 그룹 규칙 확인
            print("2. 보안 그룹 규칙 확인")
            print("-" * 60)
            for sg_id in sg_ids:
                print(f"\n보안 그룹: {sg_id}")
                cmd = f"aws ec2 describe-security-groups --group-ids {sg_id} --region ap-northeast-2 --query 'SecurityGroups[0]' --output json"
                sg_output, sg_code = run_cmd(cmd)
                
                if sg_code == 0 and sg_output:
                    sg = json.loads(sg_output)
                    print(f"  이름: {sg.get('GroupName', 'N/A')}")
                    print(f"  설명: {sg.get('Description', 'N/A')}")
                    
                    # 인바운드 규칙
                    print("\n  인바운드 규칙:")
                    for rule in sg.get('IpPermissions', []):
                        from_port = rule.get('FromPort', 'N/A')
                        to_port = rule.get('ToPort', 'N/A')
                        protocol = rule.get('IpProtocol', 'N/A')
                        cidr_blocks = [ip.get('CidrIp', '') for ip in rule.get('IpRanges', [])]
                        sg_blocks = [sg.get('GroupId', '') for sg in rule.get('UserIdGroupPairs', [])]
                        
                        print(f"    - 포트: {from_port}-{to_port}, 프로토콜: {protocol}")
                        if cidr_blocks:
                            print(f"      CIDR: {', '.join(cidr_blocks)}")
                        if sg_blocks:
                            print(f"      보안 그룹: {', '.join(sg_blocks)}")
                    
                    # 아웃바운드 규칙
                    print("\n  아웃바운드 규칙:")
                    for rule in sg.get('IpPermissionsEgress', []):
                        from_port = rule.get('FromPort', 'N/A')
                        to_port = rule.get('ToPort', 'N/A')
                        protocol = rule.get('IpProtocol', 'N/A')
                        cidr_blocks = [ip.get('CidrIp', '') for ip in rule.get('IpRanges', [])]
                        
                        print(f"    - 포트: {from_port}-{to_port}, 프로토콜: {protocol}")
                        if cidr_blocks:
                            print(f"      CIDR: {', '.join(cidr_blocks)}")
        except Exception as e:
            print(f"오류: {e}")
    else:
        print(f"인스턴스 정보를 가져올 수 없습니다: {output}")
    print()
    
    # 3. EC2 Instance Connect 요구사항 확인
    print("=" * 60)
    print("EC2 Instance Connect 요구사항 확인")
    print("=" * 60)
    print()
    print("EC2 Instance Connect가 작동하려면:")
    print()
    print("1. SSM Agent 설치:")
    print("   - Amazon Linux 2023에는 기본적으로 설치되어 있습니다")
    print("   - 확인: sudo systemctl status amazon-ssm-agent")
    print()
    print("2. IAM 역할:")
    if 'iam_role' in locals() and iam_role != 'N/A':
        print(f"   ✅ IAM 역할이 연결되어 있습니다: {iam_role}")
        print("   - SSM 접근 권한이 있는지 확인 필요")
    else:
        print("   ❌ IAM 역할이 연결되어 있지 않습니다!")
        print("   - EC2 Instance Connect를 사용하려면 IAM 역할이 필요합니다")
    print()
    print("3. 보안 그룹:")
    print("   - EC2 Instance Connect는 SSM을 통해 작동하므로")
    print("   - 보안 그룹에서 SSH 포트(22)가 직접 필요하지 않을 수 있습니다")
    print("   - 하지만 관리자 IP에서 SSH 접근이 허용되어야 할 수도 있습니다")
    print()
    
    # 4. 현재 IP 확인
    print("4. 현재 접속 IP 확인")
    print("-" * 60)
    cmd = "curl -s https://checkip.amazonaws.com"
    current_ip, _ = run_cmd(cmd)
    if current_ip:
        print(f"현재 IP: {current_ip}")
        print()
        print("보안 그룹에 이 IP가 허용되어 있는지 확인하세요.")
    print()
    
    # 5. 해결 방법
    print("=" * 60)
    print("해결 방법")
    print("=" * 60)
    print()
    print("방법 1: IAM 역할 추가 (EC2 Instance Connect용)")
    print("  - Bastion 인스턴스에 SSM 접근을 위한 IAM 역할 추가")
    print("  - Terraform으로 IAM 역할 및 인스턴스 프로필 추가 필요")
    print()
    print("방법 2: 보안 그룹에 현재 IP 추가")
    print(f"  - 현재 IP ({current_ip})를 보안 그룹의 SSH 인바운드 규칙에 추가")
    print()
    print("방법 3: SSM Session Manager 사용")
    if 'iam_role' in locals() and iam_role != 'N/A':
        print(f"  aws ssm start-session --target {instance_id} --region ap-northeast-2")
    else:
        print("  - IAM 역할이 필요합니다")
    print()

if __name__ == "__main__":
    main()
