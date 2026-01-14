#!/usr/bin/env python3
"""
SSH 키 파일 확인 및 AWS 키 페어 확인
"""
import os
import subprocess
import glob

def run_command(cmd):
    """명령어 실행"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return result.stdout.strip(), result.returncode
    except Exception as e:
        return str(e), 1

def main():
    print("=" * 60)
    print("SSH 키 파일 확인")
    print("=" * 60)
    print()
    
    # 1. ~/.ssh 디렉토리 확인
    ssh_dir = os.path.expanduser("~/.ssh")
    print(f"1. SSH 디렉토리 확인: {ssh_dir}")
    if os.path.exists(ssh_dir):
        files = os.listdir(ssh_dir)
        key_files = [f for f in files if f.endswith(('.pem', '.key')) or 'key' in f.lower()]
        if key_files:
            print("   발견된 키 파일:")
            for key_file in key_files:
                key_path = os.path.join(ssh_dir, key_file)
                print(f"   - {key_path}")
                if os.path.exists(key_path):
                    stat = os.stat(key_path)
                    print(f"     권한: {oct(stat.st_mode)[-3:]}")
        else:
            print("   키 파일을 찾을 수 없습니다.")
    else:
        print(f"   디렉토리가 존재하지 않습니다: {ssh_dir}")
    print()
    
    # 2. 전체 시스템에서 .pem 파일 검색
    print("2. 전체 시스템에서 .pem 파일 검색 중...")
    home_dir = os.path.expanduser("~")
    pem_files = []
    for root, dirs, files in os.walk(home_dir):
        # 너무 깊이 들어가지 않도록 제한
        depth = root[len(home_dir):].count(os.sep)
        if depth > 2:
            continue
        for file in files:
            if file.endswith('.pem'):
                pem_files.append(os.path.join(root, file))
    
    if pem_files:
        print("   발견된 .pem 파일:")
        for pem_file in pem_files[:10]:  # 최대 10개만 표시
            print(f"   - {pem_file}")
    else:
        print("   .pem 파일을 찾을 수 없습니다.")
    print()
    
    # 3. AWS 키 페어 확인
    print("3. AWS 키 페어 확인 (Seoul 리전)...")
    stdout, code = run_command("aws ec2 describe-key-pairs --region ap-northeast-2 --query 'KeyPairs[*].KeyName' --output table 2>&1")
    if code == 0:
        print(stdout)
    else:
        print(f"   오류: {stdout}")
    print()
    
    print("4. AWS 키 페어 확인 (Oregon 리전)...")
    stdout, code = run_command("aws ec2 describe-key-pairs --region us-west-2 --query 'KeyPairs[*].KeyName' --output table 2>&1")
    if code == 0:
        print(stdout)
    else:
        print(f"   오류: {stdout}")
    print()
    
    # 4. 해결 방법 제시
    print("=" * 60)
    print("해결 방법")
    print("=" * 60)
    print()
    print("SSH 키 파일이 없는 경우:")
    print()
    print("옵션 1: 기존 키 파일 위치 확인")
    print("  - 다른 컴퓨터나 백업에서 키 파일을 찾아보세요")
    print("  - 일반적인 위치: ~/.ssh/, ~/Downloads/, ~/Desktop/")
    print()
    print("옵션 2: AWS Systems Manager Session Manager 사용 (키 없이 접속)")
    print("  - AWS CLI로 직접 접속:")
    print("    aws ssm start-session --target <instance-id> --region ap-northeast-2")
    print()
    print("옵션 3: 새 키 페어 생성 (기존 인스턴스에는 적용 불가)")
    print("  - 새 키 페어를 생성하면 기존 인스턴스에는 사용할 수 없습니다")
    print("  - 인스턴스를 재생성하거나 키를 교체해야 합니다")
    print()
    print("옵션 4: EC2 Instance Connect 사용")
    print("  - AWS 콘솔에서 EC2 Instance Connect를 통해 브라우저에서 접속")
    print()

if __name__ == "__main__":
    main()
