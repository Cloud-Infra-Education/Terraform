#!/usr/bin/env python3
import subprocess
import json
import time

INSTANCE_ID = "i-0088889a043f54312"
REGION = "ap-northeast-2"

cmd = [
    "aws", "ssm", "send-command",
    "--instance-ids", INSTANCE_ID, "--region", REGION,
    "--document-name", "AWS-RunShellScript",
    "--parameters", json.dumps({
        "commands": [
            "cd ~/Backend",
            "export PATH=$PATH:/root/.local/bin",
            "python3 -c 'import sys; sys.path.insert(0, \".\"); import main' 2>&1"
        ]
    }),
    "--output", "text", "--query", "Command.CommandId"
]

result = subprocess.run(cmd, capture_output=True, text=True, check=True)
cmd_id = result.stdout.strip()
print(f"Command ID: {cmd_id}")
print("대기 중... (30초)")
time.sleep(30)

result_cmd = [
    "aws", "ssm", "get-command-invocation",
    "--command-id", cmd_id, "--instance-id", INSTANCE_ID,
    "--region", REGION,
    "--query", "[Status,StandardOutputContent,StandardErrorContent]",
    "--output", "json"
]

result = subprocess.run(result_cmd, capture_output=True, text=True, check=True)
data = json.loads(result.stdout)
print("\n상태:", data[0])
print("\n출력:")
print(data[1] if len(data) > 1 else "")
print("\n오류:")
print(data[2] if len(data) > 2 else "")
