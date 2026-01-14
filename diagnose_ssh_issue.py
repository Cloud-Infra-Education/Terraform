#!/usr/bin/env python3
"""
SSH 접속 문제 상세 진단
"""
import subprocess
import os

def run_cmd(cmd):
    """명령어 실행"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return result.stdout.strip(), result.returncode
    except Exception as e:
        return str(e), 1

def main():
    print("=" * 60)
    print("SSH 접속 문제 상세 진단")
    print("=" * 60)
    print()
    
    kor_ip = "35.92.218.177"
    kor_key = "/root/KeyPair-Seoul.pem"
    
    # 1. 키 파일 정보
    print("1. 키 파일 정보")
    print("-" * 60)
    if os.path.exists(kor_key):
        stat = os.stat(kor_key)
        print(f"경로: {kor_key}")
        print(f"권한: {oct(stat.st_mode)[-3:]}")
        print(f"크기: {stat.st_size} bytes")
        
        # 키 파일 첫 줄 확인
        with open(kor_key, 'r') as f:
            first_line = f.readline().strip()
            print(f"첫 줄: {first_line[:50]}...")
    else:
        print(f"❌ 키 파일이 없습니다: {kor_key}")
    print()
    
    # 2. 인스턴스 정보 확인
    print("2. 인스턴스 정보 확인")
    print("-" * 60)
    cmd = f"aws ec2 describe-instances --region ap-northeast-2 --filters 'Name=ip-address,Values={kor_ip}' 'Name=instance-state-name,Values=running' --query 'Reservations[0].Instances[0].[InstanceId,KeyName,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' --output json"
    output, code = run_cmd(cmd)
    if code == 0 and output:
        import json
        try:
            data = json.loads(output)
            instance_id = data[0]
            key_name = data[1]
            public_ip = data[2]
            name = data[3] if len(data) > 3 else "N/A"
            
            print(f"Instance ID: {instance_id}")
            print(f"Public IP: {public_ip}")
            print(f"Name: {name}")
            print(f"연결된 키 페어: {key_name}")
            print()
            
            # 키 이름 비교
            key_file_name = os.path.basename(kor_key).replace('.pem', '')
            print("3. 키 이름 비교")
            print("-" * 60)
            print(f"키 파일 이름: {key_file_name}")
            print(f"인스턴스 키 이름: {key_name}")
            
            if key_file_name.lower() in key_name.lower() or key_name.lower() in key_file_name.lower():
                print("✅ 키 이름이 일치합니다.")
            else:
                print("❌ 키 이름이 일치하지 않습니다!")
                print()
                print("가능한 원인:")
                print("1. 키 파일이 잘못된 키입니다")
                print("2. 인스턴스에 다른 키 페어가 연결되어 있습니다")
                print()
                print("해결 방법:")
                print("1. 올바른 키 파일을 찾아보세요")
                print("2. EC2 Instance Connect 사용 (키 불필요)")
                print("3. SSM Session Manager 설정")
        except Exception as e:
            print(f"오류: {e}")
    else:
        print(f"인스턴스 정보를 가져올 수 없습니다: {output}")
    print()
    
    # 3. AWS 키 페어 목록
    print("4. AWS 키 페어 목록 (Seoul 리전)")
    print("-" * 60)
    cmd = "aws ec2 describe-key-pairs --region ap-northeast-2 --query 'KeyPairs[*].KeyName' --output table"
    output, code = run_cmd(cmd)
    if code == 0:
        print(output)
    else:
        print(f"오류: {output}")
    print()
    
    # 4. SSH 디버그 정보
    print("5. SSH 접속 디버그 (첫 20줄)")
    print("-" * 60)
    cmd = f"ssh -vvv -i {kor_key} ec2-user@{kor_ip} 2>&1 | head -20"
    output, code = run_cmd(cmd)
    print(output)
    print()
    
    # 5. 해결 방법
    print("=" * 60)
    print("권장 해결 방법")
    print("=" * 60)
    print()
    print("방법 1: EC2 Instance Connect (가장 빠름) ⭐")
    print("  1. AWS 콘솔 → EC2 → Instances")
    print(f"  2. IP 주소로 검색: {kor_ip}")
    print("  3. 인스턴스 선택 → Connect → EC2 Instance Connect")
    print("  4. Connect 버튼 클릭")
    print()
    print("방법 2: 올바른 키 파일 찾기")
    print("  - 다른 위치에서 키 파일 찾기")
    print("  - AWS 콘솔에서 키 페어 확인")
    print()
    print("방법 3: SSM Session Manager")
    if 'instance_id' in locals():
        print(f"  aws ssm start-session --target {instance_id} --region ap-northeast-2")
    print()

if __name__ == "__main__":
    main()
