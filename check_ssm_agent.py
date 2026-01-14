#!/usr/bin/env python3
"""
SSM Agent 상태 및 EC2 Instance Connect 문제 진단
"""
import subprocess
import json
import time

def run_cmd(cmd):
    """명령어 실행"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return result.stdout.strip(), result.returncode
    except Exception as e:
        return str(e), 1

def main():
    print("=" * 60)
    print("SSM Agent 및 EC2 Instance Connect 문제 진단")
    print("=" * 60)
    print()
    
    instance_id = "i-0088889a043f54312"
    region = "ap-northeast-2"
    
    # 1. 인스턴스 상태 확인
    print("1. 인스턴스 상태 확인")
    print("-" * 60)
    cmd = f"aws ec2 describe-instances --region {region} --instance-ids {instance_id} --query 'Reservations[0].Instances[0].[State.Name,IamInstanceProfile.Arn]' --output json"
    output, code = run_cmd(cmd)
    
    if code == 0 and output:
        try:
            data = json.loads(output)
            state = data[0]
            iam_profile = data[1] if len(data) > 1 else None
            
            print(f"인스턴스 상태: {state}")
            print(f"IAM 프로필: {iam_profile}")
            print()
            
            if state != "running":
                print(f"⚠️  인스턴스가 {state} 상태입니다. running 상태여야 합니다.")
                print()
        except Exception as e:
            print(f"오류: {e}")
    else:
        print(f"인스턴스 정보를 가져올 수 없습니다: {output}")
    print()
    
    # 2. SSM Agent 연결 상태 확인
    print("2. SSM Agent 연결 상태 확인")
    print("-" * 60)
    print("SSM을 통해 인스턴스에 연결 가능한지 확인합니다...")
    print()
    
    cmd = f"aws ssm describe-instance-information --region {region} --filters 'Key=InstanceIds,Values={instance_id}' --query 'InstanceInformationList[0]' --output json"
    output, code = run_cmd(cmd)
    
    if code == 0 and output:
        try:
            if output and output != "null":
                info = json.loads(output)
                ping_status = info.get('PingStatus', 'N/A')
                last_ping = info.get('LastPingDateTime', 'N/A')
                platform = info.get('PlatformType', 'N/A')
                
                print(f"Ping 상태: {ping_status}")
                print(f"마지막 Ping: {last_ping}")
                print(f"플랫폼: {platform}")
                print()
                
                if ping_status == "Online":
                    print("✅ SSM Agent가 정상적으로 연결되어 있습니다.")
                elif ping_status == "Inactive":
                    print("⚠️  SSM Agent가 비활성 상태입니다.")
                    print("   인스턴스를 재시작하거나 SSM Agent를 수동으로 시작해야 합니다.")
                else:
                    print(f"❌ SSM Agent 연결 문제: {ping_status}")
                    print("   가능한 원인:")
                    print("   1. SSM Agent가 설치되지 않음")
                    print("   2. SSM Agent가 실행되지 않음")
                    print("   3. IAM 역할이 제대로 적용되지 않음")
                    print("   4. 네트워크 연결 문제")
            else:
                print("❌ SSM에서 인스턴스를 찾을 수 없습니다.")
                print("   가능한 원인:")
                print("   1. SSM Agent가 설치되지 않음")
                print("   2. 인스턴스가 방금 시작되어 아직 SSM에 등록되지 않음")
                print("   3. IAM 역할이 제대로 적용되지 않음")
        except Exception as e:
            print(f"오류: {e}")
    else:
        print(f"SSM 정보를 가져올 수 없습니다: {output}")
    print()
    
    # 3. 해결 방법
    print("=" * 60)
    print("해결 방법")
    print("=" * 60)
    print()
    
    print("방법 1: 인스턴스 재시작 (권장)")
    print(f"  aws ec2 reboot-instances --instance-ids {instance_id} --region {region}")
    print("  재시작 후 2-3분 정도 기다린 후 다시 시도하세요.")
    print()
    
    print("방법 2: SSM Agent 수동 시작 (인스턴스 내부)")
    print("  EC2 Instance Connect 또는 SSH로 접속 후:")
    print("  sudo systemctl status amazon-ssm-agent")
    print("  sudo systemctl start amazon-ssm-agent")
    print("  sudo systemctl enable amazon-ssm-agent")
    print()
    
    print("방법 3: SSM Session Manager로 직접 접속 시도")
    print(f"  aws ssm start-session --target {instance_id} --region {region}")
    print("  이것이 작동하면 EC2 Instance Connect도 작동할 가능성이 높습니다.")
    print()
    
    print("방법 4: 인스턴스 재생성 (최후의 수단)")
    print("  기존 인스턴스를 종료하고 새로 생성하면 SSM Agent가 자동으로 시작됩니다.")
    print()

if __name__ == "__main__":
    main()
