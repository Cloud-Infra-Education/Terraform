#!/bin/bash
# Lambda 함수 배포 패키지 빌드 스크립트

set -e

LAMBDA_DIR="/root/Backend/lambda/video-processor"
BUILD_DIR="/tmp/lambda-build"
OUTPUT_ZIP="/root/Terraform/modules/lambda/lambda-function.zip"

echo "=== Lambda 함수 배포 패키지 빌드 시작 ==="

# 기존 ZIP 파일 삭제
rm -f $OUTPUT_ZIP

# 빌드 디렉토리 생성 및 정리
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR

# 소스 코드 복사 (ZIP 파일 제외)
echo "1. 소스 코드 복사 중..."
cp -r $LAMBDA_DIR/* $BUILD_DIR/
# ZIP 파일이 복사되었으면 삭제
rm -f $BUILD_DIR/*.zip

# 의존성 설치
echo "2. Python 의존성 설치 중..."
cd $BUILD_DIR
pip install -r requirements.txt -t . --quiet

# 불필요한 파일 제거
echo "3. 불필요한 파일 제거 중..."
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -type f -name "*.pyc" -delete
find . -type d -name "*.dist-info" -exec rm -rf {} + 2>/dev/null || true
find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true

# ZIP 파일 생성 (루트에 모든 파일이 오도록)
echo "4. ZIP 파일 생성 중..."
cd $BUILD_DIR
zip -r $OUTPUT_ZIP . -q

echo "✅ 빌드 완료: $OUTPUT_ZIP"
echo "파일 크기: $(du -h $OUTPUT_ZIP | cut -f1)"
