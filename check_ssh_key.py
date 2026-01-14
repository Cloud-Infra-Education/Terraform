#!/usr/bin/env python3
"""
SSH 키 파일 및 AWS 키 페어 확인 및 문제 해결
"""
import os
import subprocess
import stat

def check_key_file(key_path):
    """키 파일 확인"""
    print(f"키 파일 확인: {key_path}")
    
    if not os.path.exists(key_path):
        print(f"  ❌ 파일이 존재하지 않습니다.")
        return False
    
    # 파일 권한 확인
    file_stat = os.stat(key_path)
    permissions = oct(file_stat.st_mode)[-3:]
    print(f"  권한: {permissions}")
    
    if permissions != "400" and permissions != "600":
        print(f"  ⚠️  권한이 올바르지 않습니다. 권장: 400 또는 600")
        print(f"  수정: chmod 400 {key_path}")
    
    # 파일 크기 확인
    size = file_stat.st_size
    print(f"  크기: {size} bytes")
    
    if size == 0:
        print(f"  ❌ 파일이 비어있습니다.")
        return False
    
    # 파일 내용 확인 (처음 몇 줄)
    try:
        with open(key_path, 'r') as f:
            first_line = f.readline().strip()
            if first_line.startswith('-----BEGIN'):
                print(f"  ✅ PEM 형식으로 보입니다.")
            else:
                print(f"  ⚠️  PEM 형식이 아닐 수 있습니다.")
    except Exception as e:
        print(f"  ❌ 파일 읽기 오류: {e}")
        return False
    
    return True

def get_aws_key_pairs(region):
    """AWS 키 페어 목록 조회"""
    print(f"\nAWS 키 페어 확인 ({region}):")
    cmd = f"aws ec2 describe-key-pairs --region {region} --query 'KeyPairs[*].KeyName' --output table 2>&1"
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        if result.returncode == 0:
            print(result.stdout)
            # 키 이름 추출
            lines = result.stdout.strip().split('\n')
            key_names = []
            for line in lines:
                if '|' in line and 'KeyName' not in line and '---' not in line:
                    key_name = line.split('|')[1].strip()
                    if key_name:
                        key_names.append(key_name)
            return key_names
        else:
            print(f"  오류: {result.stderr}")
    except Exception as e:
        print(f"  오류: {e}")
    return []

def get_instance_key_name(region, public_ip):
    """인스턴스에 연결된 키 페어 이름 확인"""
    print(f"\n인스턴스 키 페어 확인 ({region}, IP: {public_ip}):")
    cmd = f"aws ec2 describe-instances --region {region} --filters 'Name=ip-address,Values={public_ip}' 'Name=instance-state-name,Values=running' --query 'Reservations[0].Instances[0].KeyName' --output text 2>&1"
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        if result.returncode == 0 and result.stdout.strip():
            key_name = result.stdout.strip()
            print(f"  연결된 키 페어: {key_name}")
            return key_name
        else:
            print(f"  오류: {result.stderr}")
    except Exception as e:
        print(f"  오류: {e}")
    return None

def main():
    print("=" * 60)
    print("SSH 키 파일 및 AWS 키 페어 확인")
    print("=" * 60)
    print()
    
    kor_key = "/root/KeyPair-Seoul.pem"
    usa_key = "/root/KeyPair-Oregon.pem"
    kor_ip = "35.92.218.177"
    usa_ip = "43.202.0.201"
    
    # 1. 키 파일 확인
    print("1. 키 파일 확인")
    print("-" * 60)
    kor_key_ok = check_key_file(kor_key)
    print()
    usa_key_ok = check_key_file(usa_key) if os.path.exists(usa_key) else False
    if not os.path.exists(usa_key):
        print(f"USA 키 파일이 없습니다: {usa_key}")
    print()
    
    # 2. AWS 키 페어 확인
    print("2. AWS 키 페어 확인")
    print("-" * 60)
    kor_keys = get_aws_key_pairs("ap-northeast-2")
    usa_keys = get_aws_key_pairs("us-west-2")
    print()
    
    # 3. 인스턴스에 연결된 키 확인
    print("3. 인스턴스에 연결된 키 페어 확인")
    print("-" * 60)
    kor_instance_key = get_instance_key_name("ap-northeast-2", kor_ip)
    usa_instance_key = get_instance_key_name("us-west-2", usa_ip)
    print()
    
    # 4. 문제 진단 및 해결 방법
    print("=" * 60)
    print("문제 진단 및 해결 방법")
    print("=" * 60)
    print()
    
    if kor_key_ok:
        if kor_instance_key:
            # 키 이름 매칭 확인
            key_file_name = os.path.basename(kor_key).replace('.pem', '')
            if key_file_name.lower() in kor_instance_key.lower() or kor_instance_key.lower() in key_file_name.lower():
                print("✅ KOR 키 파일 이름이 인스턴스 키와 일치합니다.")
            else:
                print(f"⚠️  KOR 키 파일 이름과 인스턴스 키가 일치하지 않을 수 있습니다.")
                print(f"   파일 이름: {key_file_name}")
                print(f"   인스턴스 키: {kor_instance_key}")
                print()
                print("   해결 방법:")
                print("   1. 올바른 키 파일을 사용하세요")
                print("   2. 또는 EC2 Instance Connect 사용 (키 불필요)")
                print("   3. 또는 SSM Session Manager 설정")
        else:
            print("⚠️  KOR 인스턴스의 키 페어를 확인할 수 없습니다.")
    else:
        print("❌ KOR 키 파일에 문제가 있습니다.")
        print()
        print("해결 방법:")
        print("1. 키 파일 권한 수정:")
        print(f"   chmod 400 {kor_key}")
        print()
        print("2. 올바른 키 파일인지 확인")
        print()
        print("3. EC2 Instance Connect 사용 (키 불필요):")
        print("   - AWS 콘솔 → EC2 → Instances → Connect → EC2 Instance Connect")
        print()
        print("4. SSM Session Manager 설정 후 사용")
    
    print()
    print("=" * 60)
    print("추가 명령어")
    print("=" * 60)
    print()
    print("# 키 파일 권한 수정:")
    print(f"chmod 400 {kor_key}")
    print()
    print("# SSH 접속 테스트 (verbose 모드):")
    print(f"ssh -v -i {kor_key} ec2-user@{kor_ip}")
    print()
    print("# EC2 Instance Connect (브라우저):")
    print("AWS 콘솔 → EC2 → Instances → IP로 검색 → Connect → EC2 Instance Connect")

if __name__ == "__main__":
    main()
