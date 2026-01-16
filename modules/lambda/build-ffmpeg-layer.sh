#!/bin/bash
# FFmpeg Lambda Layer 빌드 스크립트
# 참고: https://github.com/serverlesspub/ffmpeg-aws-lambda-layer

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAYER_NAME="ffmpeg-layer"
LAYER_DIR="/tmp/ffmpeg-layer-build"
OUTPUT_ZIP="${SCRIPT_DIR}/ffmpeg-layer.zip"

echo "=== FFmpeg Lambda Layer 빌드 시작 ==="

# 빌드 디렉토리 생성
rm -rf $LAYER_DIR
mkdir -p $LAYER_DIR/bin

# FFmpeg 및 FFprobe 다운로드 (정적 빌드)
echo "1. FFmpeg 다운로드 중..."
cd /tmp

# Lambda용 FFmpeg 정적 빌드 다운로드
# 참고: https://johnvansickle.com/ffmpeg/
wget -q https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz
tar -xf ffmpeg-release-amd64-static.tar.xz
rm -f ffmpeg-release-amd64-static.tar.xz

# 압축 해제된 디렉토리 찾기
FFMPEG_DIR=$(find /tmp -maxdepth 1 -type d -name "ffmpeg-*-amd64-static" | head -1)

# Lambda Layer 구조에 맞게 복사
if [ -n "$FFMPEG_DIR" ]; then
    cp $FFMPEG_DIR/ffmpeg $LAYER_DIR/bin/
    cp $FFMPEG_DIR/ffprobe $LAYER_DIR/bin/
    rm -rf $FFMPEG_DIR
else
    echo "❌ FFmpeg 디렉토리를 찾을 수 없습니다."
    exit 1
fi

# ZIP 파일 생성
echo "2. ZIP 파일 생성 중..."
cd $LAYER_DIR
zip -r $OUTPUT_ZIP . -q

echo "✅ 빌드 완료: $OUTPUT_ZIP"
echo "파일 크기: $(du -h $OUTPUT_ZIP | cut -f1)"
