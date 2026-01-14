#!/usr/bin/env python3
"""
SSM을 통해 Backend 코드를 직접 전송 (GitHub 불필요)
파일을 읽어서 SSM 명령어로 직접 생성
"""
import subprocess
import os
import json
import time
import base64
import tarfile
import tempfile

INSTANCE_ID = "i-0088889a043f54312"
REGION = "ap-northeast-2"
BACKEND_DIR = "/root/Backend"

def get_file_list():
    """전송할 파일 목록 가져오기"""
    files = []
    excludes = {'__pycache__', '.git', 'test.db', '.env', '.pyc'}
    
    for root, dirs, filenames in os.walk(BACKEND_DIR):
        # 제외할 디렉토리 필터링
        dirs[:] = [d for d in dirs if d not in excludes]
        
        for filename in filenames:
            if filename.endswith('.pyc') or filename in excludes:
                continue
            
            filepath = os.path.join(root, filename)
            relpath = os.path.relpath(filepath, BACKEND_DIR)
            files.append((filepath, relpath))
    
    return files

def create_file_commands(files):
    """파일을 생성하는 SSM 명령어 생성"""
    commands = [
        "cd ~/Backend",
        "mkdir -p app/api/v1/routes app/api/v1 app/core app/models app/schemas app/services alembic/versions",
    ]
    
    # 각 파일을 base64로 인코딩하여 전송
    for filepath, relpath in files:
        try:
            with open(filepath, 'rb') as f:
                content = f.read()
            
            # 작은 파일은 직접 전송, 큰 파일은 base64
            if len(content) < 50000:  # 50KB 미만
                # 텍스트 파일인 경우
                try:
                    text_content = content.decode('utf-8')
                    # 특수 문자 이스케이프
                    text_content = text_content.replace('$', '\\$').replace('`', '\\`').replace('"', '\\"')
                    commands.append(f"cat > {relpath} <<'ENDOFFILE'\n{text_content}\nENDOFFILE")
                except:
                    # 바이너리 파일은 base64
                    encoded = base64.b64encode(content).decode('utf-8')
                    commands.append(f"echo '{encoded}' | base64 -d > {relpath}")
            else:
                # 큰 파일은 base64로 분할
                encoded = base64.b64encode(content).decode('utf-8')
                commands.append(f"echo '{encoded}' | base64 -d > {relpath}")
        except Exception as e:
            print(f"⚠️  파일 읽기 실패: {relpath} - {e}")
            continue
    
    commands.append("chmod +x *.sh 2>/dev/null || true")
    commands.append("ls -la")
    
    return commands

def run_ssm_command(commands, description):
    """SSM을 통해 명령어 실행"""
    print(f"\n{description}...")
    
    # 명령어가 너무 많으면 분할
    max_commands = 50
    if len(commands) > max_commands:
        print(f"⚠️  명령어가 많습니다 ({len(commands)}개). 분할하여 실행합니다...")
        
        for i in range(0, len(commands), max_commands):
            chunk = commands[i:i+max_commands]
            chunk_desc = f"{description} (부분 {i//max_commands + 1})"
            if not run_ssm_command(chunk, chunk_desc):
                return False
        return True
    
    cmd = [
        "aws", "ssm", "send-command",
        "--instance-ids", INSTANCE_ID,
        "--region", REGION,
        "--document-name", "AWS-RunShellScript",
        "--parameters", json.dumps({"commands": commands}),
        "--output", "text",
        "--query", "Command.CommandId"
    ]
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        command_id = result.stdout.strip()
        print(f"Command ID: {command_id}")
        print("명령어 실행 중... (60초 대기)")
        time.sleep(60)
        
        # 결과 확인
        result_cmd = [
            "aws", "ssm", "get-command-invocation",
            "--command-id", command_id,
            "--instance-id", INSTANCE_ID,
            "--region", REGION,
            "--query", "[Status,StandardOutputContent,StandardErrorContent]",
            "--output", "json"
        ]
        
        result = subprocess.run(result_cmd, capture_output=True, text=True, check=True)
        data = json.loads(result.stdout)
        status = data[0]
        output = data[1] if len(data) > 1 else ""
        error = data[2] if len(data) > 2 else ""
        
        print(f"상태: {status}")
        if output and len(output) < 1000:  # 출력이 너무 길면 일부만 표시
            print(f"출력:\n{output}")
        elif output:
            print(f"출력: (처음 500자)\n{output[:500]}...")
        if error:
            print(f"오류:\n{error}")
        
        return status == "Success"
    except Exception as e:
        print(f"오류: {e}")
        return False

def main():
    print("=" * 60)
    print("SSM을 통해 Backend 코드 전송 (GitHub 불필요)")
    print("=" * 60)
    print()
    
    # 파일 목록 가져오기
    print("전송할 파일 목록 확인 중...")
    files = get_file_list()
    print(f"✅ {len(files)}개 파일 발견")
    
    # 주요 파일만 먼저 전송 (requirements.txt, main.py 등)
    important_files = [f for f in files if any(x in f[1] for x in ['requirements.txt', 'main.py', 'app/', 'alembic.ini'])]
    other_files = [f for f in files if f not in important_files]
    
    print(f"\n중요 파일: {len(important_files)}개")
    print(f"기타 파일: {len(other_files)}개")
    
    # 1단계: 중요 파일 전송
    print("\n1단계: 중요 파일 전송 중...")
    important_commands = create_file_commands(important_files)
    if not run_ssm_command(important_commands, "중요 파일 전송"):
        print("❌ 중요 파일 전송 실패")
        return
    
    # 2단계: 기타 파일 전송
    if other_files:
        print("\n2단계: 기타 파일 전송 중...")
        other_commands = create_file_commands(other_files)
        if not run_ssm_command(other_commands, "기타 파일 전송"):
            print("⚠️  일부 파일 전송 실패 (계속 진행)")
    
    print("\n" + "=" * 60)
    print("✅ Backend 코드 전송 완료!")
    print("=" * 60)
    print("\n다음 단계:")
    print("1. SSM Session Manager로 Bastion 접속:")
    print(f"   aws ssm start-session --target {INSTANCE_ID} --region {REGION}")
    print("\n2. 접속 후 다음 명령어 실행:")
    print("   cd ~/Backend")
    print("   ls -la")
    print("   pip3 install --user -r requirements.txt")
    print("   python3 -m uvicorn main:app --host 0.0.0.0 --port 8000")

if __name__ == "__main__":
    main()
