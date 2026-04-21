#!/bin/bash

# ==============================================================================
# Universal Harness Health Checker (v2.0)
# ==============================================================================
# 프로젝트 전 영역(Flutter, Cloudflare Worker, Infrastructure)의 불변식을 검증합니다.
# ==============================================================================

set -e

PROJECT_ROOT="${1:-.}"
FAILED_MODULES=""
FAILED_COUNT=0

echo "🚀 Universal Harness Health Check 시작: $PROJECT_ROOT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# [Module 1] Flutter App 영역
echo "1️⃣  [Frontend] Flutter/Dart 검증 중..."
if [ -f "$PROJECT_ROOT/pubspec.yaml" ]; then
    # Dart Analyze
    if ! dart analyze "$PROJECT_ROOT" > /dev/null 2>&1; then
        echo "   ❌ [분석 실패] Dart 분석기에 경고/에러가 있습니다."
        FAILED_COUNT=$((FAILED_COUNT + 1))
        FAILED_MODULES="$FAILED_MODULES Frontend(Analyze)"
    fi
    # Dart Format
    if ! dart format --output=none --set-exit-if-changed "$PROJECT_ROOT" > /dev/null 2>&1; then
        echo "   ❌ [포맷팅 위반] Dart 포맷 규칙을 준수하지 않았습니다."
        FAILED_COUNT=$((FAILED_COUNT + 1))
        FAILED_MODULES="$FAILED_MODULES Frontend(Format)"
    fi
    # Architecture & Slop (Legacy)
    if ! bash "$(dirname "$0")/check_architecture.sh" "$PROJECT_ROOT"; then
        FAILED_COUNT=$((FAILED_COUNT + 1))
        FAILED_MODULES="$FAILED_MODULES Frontend(Architecture/Slop)"
    fi
else
    echo "   ➖ [Skip] pubspec.yaml이 없습니다."
fi

# [Module 2] Cloudflare Worker (Backend) 영역
echo ""
echo "2️⃣  [Backend] Cloudflare Worker 검증 중..."
WORKER_DIR="$PROJECT_ROOT/cloudflare-worker"
if [ -d "$WORKER_DIR" ]; then
    # WorkerJS 시크릿 검사 (단순 grep)
    if grep -E "api_key|secret|password|token" "$WORKER_DIR/worker.js" | grep -v "//" > /dev/null 2>&1; then
        echo "   ❌ [보안 위반] worker.js 내에 하드코딩된 시크릿 의심 패턴이 발견되었습니다."
        FAILED_COUNT=$((FAILED_COUNT + 1))
        FAILED_MODULES="$FAILED_MODULES Backend(Security)"
    else
        echo "   ✅ [보안 통과] 하드코딩된 시크릿이 발견되지 않았습니다."
    fi
    # wrangler.toml 유효성 (파일 존재 여부 등)
    if [ ! -f "$WORKER_DIR/wrangler.toml" ]; then
        echo "   ❌ [설정 오류] wrangler.toml 파일이 누락되었습니다."
        FAILED_COUNT=$((FAILED_COUNT + 1))
        FAILED_MODULES="$FAILED_MODULES Backend(Config)"
    fi
else
    echo "   ➖ [Skip] cloudflare-worker 디렉토리가 없습니다."
fi

# [Module 3] Infrastructure & Root 영역
echo ""
echo "3️⃣  [Infra] 프로젝트 루트 및 공통 인프라 검증 중..."
# .env.example 존재 여부
if [ ! -f "$PROJECT_ROOT/.env" ] && [ ! -f "$PROJECT_ROOT/.env.example" ]; then
    echo "   ❌ [인프라 누락] .env 설정 또는 가이드가 없습니다."
    FAILED_COUNT=$((FAILED_COUNT + 1))
    FAILED_MODULES="$FAILED_MODULES Infra(Env)"
else
    echo "   ✅ [인프라 통과] 필수 설정 파일이 존재합니다."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $FAILED_COUNT -gt 0 ]; then
    echo "🚨 Health Check 실패: 총 ${FAILED_COUNT}개의 위반 발견 ($FAILED_MODULES)"
    exit 1
else
    echo "✨ All Systems Healthy! 전체 프로젝트가 하네스 원칙을 준수합니다."
    exit 0
fi
