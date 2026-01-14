#!/usr/bin/env python3
"""
각 라우터 import 테스트
"""
import subprocess
import json
import time

INSTANCE_ID = "i-0088889a043f54312"
REGION = "ap-northeast-2"

def run_ssm(commands, desc, wait=30):
    print(f"\n{desc}...")
    cmd = [
        "aws", "ssm", "send-command",
        "--instance-ids", INSTANCE_ID, "--region", REGION,
        "--document-name", "AWS-RunShellScript",
        "--parameters", json.dumps({"commands": commands}),
        "--output", "text", "--query", "Command.CommandId"
    ]
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    cmd_id = result.stdout.strip()
    print(f"Command ID: {cmd_id}, 대기 중... ({wait}초)")
    time.sleep(wait)
    
    result_cmd = [
        "aws", "ssm", "get-command-invocation",
        "--command-id", cmd_id, "--instance-id", INSTANCE_ID,
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
    print("=" * 60)
    if output:
        print("출력:")
        print(output)
    if error:
        print("오류:")
        print(error)
    print("=" * 60)
    return status == "Success", output, error

print("=" * 60)
print("각 라우터 Import 테스트")
print("=" * 60)

# 각 라우터를 하나씩 import 테스트
commands = [
    "cd ~/Backend",
    "export PATH=$PATH:/root/.local/bin",
    "python3 <<'PYEOF'",
    "import sys",
    "sys.path.insert(0, '.')",
    "print('=== health ===')",
    "try:",
    "    from app.api.v1.routes import health",
    "    print('✅ health OK')",
    "except Exception as e:",
    "    print(f'❌ health: {e}')",
    "print('')",
    "print('=== users ===')",
    "try:",
    "    from app.api.v1.routes import users",
    "    print('✅ users OK')",
    "except Exception as e:",
    "    print(f'❌ users: {e}')",
    "print('')",
    "print('=== auth ===')",
    "try:",
    "    from app.api.v1.routes import auth",
    "    print('✅ auth OK')",
    "except Exception as e:",
    "    print(f'❌ auth: {e}')",
    "print('')",
    "print('=== contents ===')",
    "try:",
    "    from app.api.v1.routes import contents",
    "    print('✅ contents OK')",
    "except Exception as e:",
    "    print(f'❌ contents: {e}')",
    "print('')",
    "print('=== content_likes ===')",
    "try:",
    "    from app.api.v1.routes import content_likes",
    "    print('✅ content_likes OK')",
    "except Exception as e:",
    "    print(f'❌ content_likes: {e}')",
    "print('')",
    "print('=== watch_history ===')",
    "try:",
    "    from app.api.v1.routes import watch_history",
    "    print('✅ watch_history OK')",
    "except Exception as e:",
    "    print(f'❌ watch_history: {e}')",
    "print('')",
    "print('=== video_assets ===')",
    "try:",
    "    from app.api.v1.routes import video_assets",
    "    print('✅ video_assets OK')",
    "except Exception as e:",
    "    print(f'❌ video_assets: {e}')",
    "print('')",
    "print('=== search ===')",
    "try:",
    "    from app.api.v1.routes import search",
    "    print('✅ search OK')",
    "except Exception as e:",
    "    print(f'❌ search: {e}')",
    "PYEOF"
]

run_ssm(commands, "라우터 Import 테스트", 40)
