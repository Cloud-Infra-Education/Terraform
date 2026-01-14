#!/usr/bin/env python3
"""
SSM을 통해 Backend 코드를 직접 전송 (S3 권한 불필요)
파일을 읽어서 SSM 명령어로 직접 생성
"""
import subprocess
import os
import json
import time
import base64

INSTANCE_ID = "i-0088889a043f54312"
REGION = "ap-northeast-2"
BACKEND_DIR = "/root/Backend"

def get_important_files():
    """전송할 중요 파일 목록"""
    important_patterns = [
        'requirements.txt',
        'main.py',
        'alembic.ini',
        'app/',
    ]
    
    files = []
    excludes = {'__pycache__', '.git', 'test.db', '.env', '.pyc'}
    
    for root, dirs, filenames in os.walk(BACKEND_DIR):
        dirs[:] = [d for d in dirs if d not in excludes]
        
        for filename in filenames:
            if filename.endswith('.pyc') or filename in excludes:
                continue
            
            filepath = os.path.join(root, filename)
            relpath = os.path.relpath(filepath, BACKEND_DIR)
            
            # 중요 파일만 선택
            if any(pattern in relpath for pattern in important_patterns):
                files.append((filepath, relpath))
    
    return files

def create_file_command(filepath, relpath):
    """파일을 생성하는 명령어 생성"""
    try:
        with open(filepath, 'rb') as f:
            content = f.read()
        
        # 텍스트 파일인 경우
        try:
            text_content = content.decode('utf-8')
            # 특수 문자 이스케이프
            text_content = text_content.replace('$', '\\$').replace('`', '\\`')
            # heredoc 사용
            return f"mkdir -p $(dirname {relpath}) && cat > {relpath} <<'ENDOFFILE'\n{text_content}\nENDOFFILE"
        except:
            # 바이너리 파일은 base64
            encoded = base64.b64encode(content).decode('utf-8')
            return f"mkdir -p $(dirname {relpath}) && echo '{encoded}' | base64 -d > {relpath}"
    except Exception as e:
        print(f"⚠️  파일 읽기 실패: {relpath} - {e}")
        return None

def run_ssm_command(commands, description):
    """SSM을 통해 명령어 실행"""
    print(f"\n{description}...")
    
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
        print("명령어 실행 중... (90초 대기)")
        time.sleep(90)
        
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
        if output and len(output) < 2000:
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
    print("SSM을 통해 Backend 코드 직접 전송 (S3 권한 불필요)")
    print("=" * 60)
    print()
    
    # 중요 파일만 전송
    print("중요 파일 목록 확인 중...")
    files = get_important_files()
    print(f"✅ {len(files)}개 파일 발견")
    
    # 파일별로 명령어 생성
    commands = ["cd ~/Backend"]
    
    for filepath, relpath in files:
        cmd = create_file_command(filepath, relpath)
        if cmd:
            commands.append(cmd)
    
    commands.append("chmod +x *.sh 2>/dev/null || true")
    commands.append("ls -la")
    
    print(f"\n총 {len(commands)}개 명령어 생성")
    
    # 명령어가 너무 많으면 분할
    max_commands = 30
    if len(commands) > max_commands:
        print(f"⚠️  명령어가 많습니다. 분할하여 실행합니다...")
        
        for i in range(0, len(commands), max_commands):
            chunk = commands[i:i+max_commands]
            chunk_desc = f"파일 전송 (부분 {i//max_commands + 1})"
            if not run_ssm_command(chunk, chunk_desc):
                print(f"⚠️  일부 파일 전송 실패 (계속 진행)")
    else:
        if run_ssm_command(commands, "Backend 코드 전송"):
            print("\n" + "=" * 60)
            print("✅ Backend 코드 전송 완료!")
            print("=" * 60)
        else:
            print("\n❌ 코드 전송 실패")
    
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
