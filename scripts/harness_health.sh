#!/bin/bash
# 하네스 통합 검증 스크립트 (Harness Health Checker)
# 
# 이 스크립트 하나로 프로젝트의 모든 '불변식(Invariants)'을 검증한다.
# 1. Dart 분석 (Static Analysis)
# 2. 포맷팅 확인 (Formatting)
# 3. 아키텍처 규칙 (Architecture Rules)
# 4. AI Slop 탐지 (Extra Lints)
#
# 사용법: ./scripts/harness_health.sh [프로젝트_경로]

set -e

PROJECT_DIR="${1:-.}"
FAILED=0

echo "🚀 Harness Health Check 시작: $PROJECT_DIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. Static Analysis
echo "1️⃣  Dart Analyze 실행 중..."
if ! dart analyze "$PROJECT_DIR" > /dev/null 2>&1; then
    echo "❌ [분석 실패] 'dart analyze' 결과 에러가 있습니다."
    FAILED=$((FAILED + 1))
else
    echo "✅ [분석 통과]"
fi

# 2. Formatting
echo ""
echo "2️⃣  포맷팅 확인 중..."
if ! dart format --output=none --set-exit-if-changed "$PROJECT_DIR" > /dev/null 2>&1; then
    echo "❌ [포맷팅 위반] 'dart format'이 권장하는 포맷이 아닙니다."
    FAILED=$((FAILED + 1))
else
    echo "✅ [포맷 통과]"
fi

# 3. Architecture & Slop
echo ""
echo "3️⃣  아키텍처 및 Slop 검증 중..."
if ! bash "$(dirname "$0")/check_architecture.sh" "$PROJECT_DIR"; then
    echo "❌ [구조 위반] 아키텍처 규칙 또는 AI Slop이 발견되었습니다."
    FAILED=$((FAILED + 1))
else
    # check_architecture.sh 자체가 이미 성공 메시지를 출력함
    :
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $FAILED -gt 0 ]; then
    echo "🚨 Harness Health Check 실패: 총 ${FAILED}개의 영역에서 위반 발견"
    exit 1
else
    echo "✨ Harness Healthy! 모든 불변식이 준수되고 있습니다."
    exit 0
fi
