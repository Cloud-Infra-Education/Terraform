import json
import base64
import gzip
import os
from datetime import datetime
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError
import boto3
from botocore.auth import SigV4Auth
from botocore.awsrequest import AWSRequest

# OpenSearch 설정
OPENSEARCH_ENDPOINT = os.environ['OPENSEARCH_ENDPOINT']
OPENSEARCH_INDEX = os.environ['OPENSEARCH_INDEX']

# OpenSearch URL 구성 (https://endpoint/index_name/_doc)
OPENSEARCH_URL = f"https://{OPENSEARCH_ENDPOINT}/{OPENSEARCH_INDEX}/_doc"

# AWS 자격 증명 가져오기
session = boto3.Session()


def sign_request(url, method='POST', body=None, region=None):
    """AWS SigV4 서명을 사용하여 OpenSearch 요청에 서명"""
    request = AWSRequest(method=method, url=url, data=body)
    
    credentials = session.get_credentials()
    
    # 리전이 제공되지 않으면 OpenSearch 엔드포인트에서 추출
    # 엔드포인트 형식: domain-id.region.es.amazonaws.com 또는 domain-id-region.es.amazonaws.com
    if not region:
        endpoint_parts = OPENSEARCH_ENDPOINT.split('.')
        # .es. 앞부분에서 리전 추출 시도
        for i, part in enumerate(endpoint_parts):
            if part == 'es' and i > 0:
                region = endpoint_parts[i-1]
                break
        # 리전을 찾지 못한 경우 기본값 사용
        if not region or len(region) < 3:
            region = 'ap-northeast-2'  # 기본값 (서울)
    
    SigV4Auth(credentials, 'es', region).add_auth(request)
    
    return dict(request.headers)


def parse_route53_log(log_line):
    """
    Route53 Query Log 형식 파싱
    형식: version account-id zone-id query-name query-type client-ip edns-client-subnet
          protocol response-code timestamp rdata requestor-id resolver-ip-type
    """
    try:
        parts = log_line.strip().split('\t')
        
        if len(parts) < 9:
            return None
        
        # 필요한 필드 추출 (인덱스는 Route53 Query Log 형식에 따라 조정 가능)
        query_name = parts[3] if len(parts) > 3 else ""
        query_type = parts[4] if len(parts) > 4 else ""
        source_ip = parts[5] if len(parts) > 5 else ""
        response_code = parts[8] if len(parts) > 8 else ""
        timestamp = parts[9] if len(parts) > 9 else datetime.utcnow().isoformat()
        
        # 정규화된 JSON 형식으로 변환
        normalized_log = {
            "timestamp": timestamp,
            "domain": query_name,
            "source_ip": source_ip,
            "query_type": query_type,
            "response_code": response_code
        }
        
        return normalized_log
    except Exception as e:
        print(f"로그 파싱 오류: {str(e)}")
        print(f"원본 로그: {log_line}")
        return None


def send_to_opensearch(document):
    """OpenSearch에 문서 전송"""
    try:
        # 문서를 JSON 문자열로 변환
        body = json.dumps(document).encode('utf-8')
        
        # AWS SigV4 서명 추가
        headers = sign_request(OPENSEARCH_URL, method='POST', body=body)
        headers['Content-Type'] = 'application/json'
        
        # OpenSearch에 POST 요청 (urllib 사용)
        request = Request(OPENSEARCH_URL, data=body, headers=headers, method='POST')
        
        try:
            with urlopen(request, timeout=10) as response:
                status_code = response.getcode()
                if status_code not in [200, 201]:
                    response_body = response.read().decode('utf-8')
                    print(f"OpenSearch 오류: {status_code} - {response_body}")
                    return False
                return True
        except HTTPError as e:
            error_body = e.read().decode('utf-8')
            print(f"OpenSearch HTTP 오류: {e.code} - {error_body}")
            return False
        except URLError as e:
            print(f"OpenSearch URL 오류: {str(e)}")
            return False
        
    except Exception as e:
        print(f"OpenSearch 전송 오류: {str(e)}")
        return False


def handler(event, context):
    """
    CloudWatch Logs 이벤트 처리
    이벤트 형식: base64 인코딩된 gzip 압축 데이터
    """
    try:
        # CloudWatch Logs 이벤트에서 데이터 추출
        cw_data = event['awslogs']['data']
        
        # Base64 디코딩
        compressed_data = base64.b64decode(cw_data)
        
        # Gzip 압축 해제
        decompressed_data = gzip.decompress(compressed_data)
        
        # JSON 파싱
        log_data = json.loads(decompressed_data)
        
        # 로그 이벤트 처리
        processed_count = 0
        error_count = 0
        
        for log_event in log_data.get('logEvents', []):
            log_message = log_event.get('message', '')
            
            # Route53 Query Log 파싱
            normalized_log = parse_route53_log(log_message)
            
            if normalized_log:
                # OpenSearch에 전송
                if send_to_opensearch(normalized_log):
                    processed_count += 1
                else:
                    error_count += 1
            else:
                error_count += 1
        
        print(f"처리 완료: {processed_count}건, 오류: {error_count}건")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'processed': processed_count,
                'errors': error_count
            })
        }
    
    except Exception as e:
        print(f"처리 오류: {str(e)}")
        raise