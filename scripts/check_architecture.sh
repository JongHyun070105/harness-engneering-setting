#!/bin/bash
# 아키텍처 검증 스크립트
# Clean Architecture 의존성 방향을 검증한다.
# 위반 발견 시 exit code 1을 반환한다.
#
# 사용법: ./scripts/check_architecture.sh [프로젝트_경로]
# 예시:   ./scripts/check_architecture.sh ./my_project

set -e

PROJECT_DIR="${1:-.}"
LIB_DIR="$PROJECT_DIR/lib"
VIOLATIONS=0

echo "🔍 아키텍처 검증 시작: $PROJECT_DIR"
echo ""

# 검증 1: domain 레이어에서 data/presentation import 금지
echo "━━━ 검증 1: domain → data/presentation import 금지 ━━━"
if grep -r "import.*data/" "$LIB_DIR"/features/*/domain/ 2>/dev/null; then
    echo "❌ domain에서 data를 import하고 있습니다!"
    VIOLATIONS=$((VIOLATIONS + 1))
else
    echo "✅ 통과"
fi

if grep -r "import.*presentation/" "$LIB_DIR"/features/*/domain/ 2>/dev/null; then
    echo "❌ domain에서 presentation을 import하고 있습니다!"
    VIOLATIONS=$((VIOLATIONS + 1))
else
    echo "✅ 통과"
fi

# 검증 2: presentation에서 data 직접 import 금지 (domain 경유만 허용)
echo ""
echo "━━━ 검증 2: presentation → data 직접 import 금지 ━━━"
if grep -r "import.*data/" "$LIB_DIR"/features/*/presentation/ 2>/dev/null; then
    echo "❌ presentation에서 data를 직접 import하고 있습니다!"
    echo "   → domain 레이어의 repository interface를 경유해야 합니다."
    VIOLATIONS=$((VIOLATIONS + 1))
else
    echo "✅ 통과"
fi

# 검증 3: feature 간 직접 import 금지 (core/ 경유만 허용)
echo ""
echo "━━━ 검증 3: feature 간 직접 import 금지 ━━━"
for feature_dir in "$LIB_DIR"/features/*/; do
    if [ -d "$feature_dir" ]; then
        feature_name=$(basename "$feature_dir")
        # 다른 feature를 직접 import하는지 확인
        other_features=$(grep -r "import.*features/" "$feature_dir" 2>/dev/null | grep -v "features/$feature_name/" || true)
        if [ -n "$other_features" ]; then
            echo "❌ $feature_name 이 다른 feature를 직접 import합니다:"
            echo "$other_features"
            echo "   → core/를 통해 공유해야 합니다."
            VIOLATIONS=$((VIOLATIONS + 1))
        fi
    fi
done
if [ $VIOLATIONS -eq 0 ]; then
    echo "✅ 통과 (또는 features 디렉토리 없음)"
fi

# 검증 4: print() 사용 금지
echo ""
echo "━━━ 검증 4: print() 사용 금지 (debugPrint 사용) ━━━"
PRINT_COUNT=$(grep -rn "^\s*print(" "$LIB_DIR" 2>/dev/null | grep -v "debugPrint" | grep -v "// ignore:" || true)
if [ -n "$PRINT_COUNT" ]; then
    echo "❌ print() 사용 발견:"
    echo "$PRINT_COUNT"
    echo "   → debugPrint() 또는 logger 패키지를 사용하세요."
    VIOLATIONS=$((VIOLATIONS + 1))
else
    echo "✅ 통과"
fi

# 검증 5: 하드코딩된 시크릿 패턴 검사
echo ""
echo "━━━ 검증 5: 하드코딩된 시크릿 검사 ━━━"
SECRET_PATTERNS="(api[_-]?key|secret|password|token)\s*[:=]\s*['\"][^'\"]+"
SECRETS=$(grep -rniE "$SECRET_PATTERNS" "$LIB_DIR" 2>/dev/null || true)
if [ -n "$SECRETS" ]; then
    echo "⚠️ 하드코딩된 시크릿 의심:"
    echo "$SECRETS"
    echo "   → --dart-define 또는 환경변수를 사용하세요."
    VIOLATIONS=$((VIOLATIONS + 1))
else
    echo "✅ 통과"
fi

# 검증 6: AI Slop (파일 길이 제한)
echo ""
echo "━━━ 검증 6: AI Slop 탐지 (단일 파일 300줄 이하) ━━━"
LONG_FILES=$(find "$LIB_DIR" -name "*.dart" -not -path "*/generated/*" -exec wc -l {} + | awk '$1 > 300 && $2 != "total" {print $2 " (" $1 " lines)"}')
if [ -n "$LONG_FILES" ]; then
    echo "❌ 파일이 너무 깁니다 (분리 필요):"
    echo "$LONG_FILES"
    VIOLATIONS=$((VIOLATIONS + 1))
else
    echo "✅ 통과"
fi

# 검증 7: 이름 없는 TODO (책임 소재 불명확)
echo ""
echo "━━━ 검증 7: 이름 없는 TODO 탐지 ━━━"
ANONYMOUS_TODOS=$(grep -rn "// TODO:" "$LIB_DIR" | grep -v "// TODO(" || true)
if [ -n "$ANONYMOUS_TODOS" ]; then
    echo "❌ 이름 없는 TODO 발견 (// TODO(이름): 형식 준수):"
    echo "$ANONYMOUS_TODOS"
    VIOLATIONS=$((VIOLATIONS + 1))
else
    echo "✅ 통과"
fi

# 결과 요약
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $VIOLATIONS -gt 0 ]; then
    echo "❌ 아키텍처 위반 ${VIOLATIONS}건 발견!"
    exit 1
else
    echo "✅ 모든 아키텍처 검증 통과!"
    exit 0
fi
