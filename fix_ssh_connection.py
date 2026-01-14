#!/usr/bin/env python3
"""
SSH 접속 문제 해결 - 인스턴스 키 페어 확인 및 올바른 키 찾기
"""
import subprocess
import json
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
    print("SSH 접속 문제 해결")
    print("=" * 60)
    print()
    
    kor_ip = "35.92.218.177"
    kor_key = "/root/KeyPair-Seoul.pem"
    
    # 1. 인스턴스 정보 확인
    print("1. 인스턴스에 연결된 키 페어 확인")
    print("-" * 60)
    cmd = f"aws ec2 describe-instances --region ap-northeast-2 --filters 'Name=ip-address,Values={kor_ip}' 'Name=instance-state-name,Values=running' --query 'Reservations[0].Instances[0]' --output json"
    output, code = run_cmd(cmd)
    
    instance_key = None
    instance_id = None
    
    if code == 0 and output:
        try:
            instance = json.loads(output)
            instance_id = instance.get('InstanceId')
            instance_key = instance.get('KeyName')
            tags = {tag['Key']: tag['Value'] for tag in instance.get('Tags', [])}
            name = tags.get('Name', 'N/A')
            
            print(f"Instance ID: {instance_id}")
            print(f"Name: {name}")
            print(f"연결된 키 페어: {instance_key}")
            print()
            
            # 키 이름 비교
            key_file_name = os.path.basename(kor_key).replace('.pem', '')
            print("2. 키 이름 비교")
            print("-" * 60)
            print(f"키 파일 이름: {key_file_name}")
            print(f"인스턴스 키 이름: {instance_key}")
            print()
            
            if instance_key:
                if key_file_name.lower() == instance_key.lower() or \
                   key_file_name.lower() in instance_key.lower() or \
                   instance_key.lower() in key_file_name.lower():
                    print("✅ 키 이름이 일치합니다.")
                    print()
                    print("하지만 SSH가 키를 인식하지 못하고 있습니다.")
                    print("가능한 원인:")
                    print("1. 키 파일이 손상되었거나 잘못된 키입니다")
                    print("2. 키 파일 형식 문제 (RSA 키를 OpenSSH가 인식하지 못함)")
                    print()
                    print("해결 방법:")
                    print("1. EC2 Instance Connect 사용 (권장)")
                    print("2. 다른 키 파일 시도")
                    print("3. 키 파일을 OpenSSH 형식으로 변환")
                else:
                    print("❌ 키 이름이 일치하지 않습니다!")
                    print()
                    print(f"인스턴스에는 '{instance_key}' 키가 연결되어 있습니다.")
                    print(f"현재 키 파일은 '{key_file_name}'입니다.")
                    print()
                    print("해결 방법:")
                    print(f"1. '{instance_key}' 키 파일을 찾아보세요")
                    print("2. EC2 Instance Connect 사용 (키 불필요)")
        except Exception as e:
            print(f"오류: {e}")
    else:
        print(f"인스턴스 정보를 가져올 수 없습니다.")
        print(f"오류: {output}")
    print()
    
    # 3. 키 파일 형식 확인 및 변환 제안
    print("3. 키 파일 형식 확인")
    print("-" * 60)
    if os.path.exists(kor_key):
        with open(kor_key, 'r') as f:
            content = f.read()
            if 'BEGIN RSA PRIVATE KEY' in content:
                print("키 형식: RSA PRIVATE KEY (구형 PEM 형식)")
                print()
                print("OpenSSH가 이 형식을 인식하지 못할 수 있습니다.")
                print()
                print("해결 방법: OpenSSH 형식으로 변환")
                print("ssh-keygen -p -m PEM -f /root/KeyPair-Seoul.pem")
                print()
                print("또는 새 형식으로 변환:")
                print("ssh-keygen -p -m RFC4716 -f /root/KeyPair-Seoul.pem")
            elif 'BEGIN PRIVATE KEY' in content:
                print("키 형식: PRIVATE KEY (PKCS#8 형식)")
                print("✅ 일반적으로 호환되는 형식입니다.")
            elif 'BEGIN OPENSSH PRIVATE KEY' in content:
                print("키 형식: OPENSSH PRIVATE KEY")
                print("✅ 최신 OpenSSH 형식입니다.")
    print()
    
    # 4. 다른 키 파일 찾기
    print("4. 다른 키 파일 검색")
    print("-" * 60)
    if instance_key:
        print(f"'{instance_key}' 키 파일 찾기:")
        cmd = f"find /root -name '*{instance_key}*' -o -name '*{instance_key.replace('y2om-', '')}*' 2>/dev/null | head -10"
        output, _ = run_cmd(cmd)
        if output:
            print(output)
        else:
            print("키 파일을 찾을 수 없습니다.")
    print()
    
    # 5. 최종 권장 사항
    print("=" * 60)
    print("최종 권장 해결 방법")
    print("=" * 60)
    print()
    print("방법 1: EC2 Instance Connect (가장 빠르고 확실) ⭐⭐⭐")
    print("  1. AWS 콘솔 → EC2 → Instances")
    print(f"  2. IP 주소로 검색: {kor_ip}")
    print("  3. 인스턴스 선택 → Connect → EC2 Instance Connect")
    print("  4. Connect 버튼 클릭")
    print("  → SSH 키 없이 브라우저에서 바로 접속 가능!")
    print()
    
    if instance_key and instance_key != os.path.basename(kor_key).replace('.pem', ''):
        print(f"방법 2: 올바른 키 파일 찾기")
        print(f"  인스턴스에는 '{instance_key}' 키가 연결되어 있습니다.")
        print(f"  이 키 파일을 찾아서 사용하세요.")
        print()
    
    print("방법 3: 키 파일 형식 변환 시도")
    print("  ssh-keygen -p -m PEM -f /root/KeyPair-Seoul.pem")
    print("  (비밀번호 없이 Enter만 누르면 됩니다)")
    print()
    
    if instance_id:
        print("방법 4: SSM Session Manager")
        print(f"  aws ssm start-session --target {instance_id} --region ap-northeast-2")
        print("  (IAM 역할 설정 필요)")
    print()

if __name__ == "__main__":
    main()
