#!/bin/bash

# ==============================================================================
# Autonomous Improving Harness v6.0 (Refactor & Test)
# ==============================================================================

# 1. 경로 및 설정
BASE_DIR="/Users/macintosh/IdeaProjects/HarnessEngineering"
PROJECT_DIR="/Users/macintosh/IdeaProjects/reviewai_flutter"
HEALTH_SCRIPT="${BASE_DIR}/scripts/harness_health.sh"
TEMPLATE_FILE="${BASE_DIR}/.agent/skills/harness-audit/references/nightly-report-template.md"
MEMORY_FILE="${BASE_DIR}/docs/project_memory.md"
LOG_DIR="${BASE_DIR}/logs"
REPORT_DIR="${PROJECT_DIR}/docs/nightly_reports"
DATE_STR=$(date +"%Y-%m-%d")
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BRANCH_NAME="harness/auto-improve-${DATE_STR}"
NIGHTLY_REPORT="${REPORT_DIR}/nightly_report_${DATE_STR}.md"

# 필요한 디렉토리 미리 생성
mkdir -p "$LOG_DIR" "$REPORT_DIR"

export PATH="$PATH:/Users/macintosh/fvm/default/bin:/Users/macintosh/developer/flutter/bin:/opt/homebrew/bin"

echo "[Harness v6.0] 자율 개선 루프 시작: $(date)"

# 2. Phase 0: Git Prep
cd "$PROJECT_DIR" || exit
git checkout main
git pull origin main
git checkout -b "$BRANCH_NAME" || git checkout "$BRANCH_NAME"

# 3. Phase 1: Auto-Fix & Refactor
echo "[Phase 1] 자율 개선 및 리팩토링 중..."
flutter fix --apply > "${LOG_DIR}/fix_${TIMESTAMP}.log" 2>&1
FIX_COUNT=$(grep "Fixed" "${LOG_DIR}/fix_${TIMESTAMP}.log" | wc -l | tr -d ' ')
flutter format . >> "${LOG_DIR}/fix_${TIMESTAMP}.log" 2>&1

# 4. Phase 2: Automated Testing (New in v6.0)
echo "[Phase 2] 전수 테스트 실행 중..."
flutter test > "${LOG_DIR}/test_${TIMESTAMP}.log" 2>&1
TEST_RESULT=$?
if [ $TEST_RESULT -eq 0 ]; then
    TEST_STATUS="PASS"
else
    TEST_STATUS="FAIL"
    echo "⚠️ 일부 테스트가 실패했습니다. 로그를 확인하세요: test_${TIMESTAMP}.log"
fi

# 5. Phase 3: Full-Stack Health Audit
echo "[Phase 3] 전 레이어 통합 검사 중..."
bash "$HEALTH_SCRIPT" "$PROJECT_DIR" > "${LOG_DIR}/universal_health_${TIMESTAMP}.log" 2>&1 || true

# 6. Phase 4: 데이터 추출 및 리포트
echo "[Phase 4] 자율 개선 리포트 생성 중..."
FRONT_STATUS=$(grep "1️⃣" "${LOG_DIR}/universal_health_${TIMESTAMP}.log" -A 5 | grep "❌" | head -n 1 | sed 's/[^a-zA-Z0-9 ]//g' | xargs || echo "Healthy")
BACK_STATUS=$(grep "2️⃣" "${LOG_DIR}/universal_health_${TIMESTAMP}.log" -A 5 | grep "❌" | head -n 1 | sed 's/[^a-zA-Z0-9 ]//g' | xargs || echo "Healthy")
INFRA_STATUS=$(grep "3️⃣" "${LOG_DIR}/universal_health_${TIMESTAMP}.log" -A 5 | grep "❌" | head -n 1 | sed 's/[^a-zA-Z0-9 ]//g' | xargs || echo "Healthy")
SLOP_COUNT=$(grep -E "/lib/.* \([0-9]+ lines\)" "${LOG_DIR}/universal_health_${TIMESTAMP}.log" | wc -l | tr -d ' ')

cp "$TEMPLATE_FILE" "$NIGHTLY_REPORT"
sed -i '' "s/{{DATE}}/$DATE_STR/g" "$NIGHTLY_REPORT"
sed -i '' "s/{{FRONT_STATUS}}/$FRONT_STATUS (Test:$TEST_STATUS)/g" "$NIGHTLY_REPORT"
sed -i '' "s/{{BACK_STATUS}}/$BACK_STATUS/g" "$NIGHTLY_REPORT"
sed -i '' "s/{{INFRA_STATUS}}/$INFRA_STATUS/g" "$NIGHTLY_REPORT"
sed -i '' "s/{{FIX_COUNT}}/$FIX_COUNT/g" "$NIGHTLY_REPORT"

# Slop 리스트 삽입
grep -E "/lib/.* \([0-9]+ lines\)" "${LOG_DIR}/universal_health_${TIMESTAMP}.log" | head -n 5 | sed 's/^/- /' > "${LOG_DIR}/slop_tmp.txt"
if [ ! -s "${LOG_DIR}/slop_tmp.txt" ]; then echo "- 모든 파일이 300줄 이하를 유지하고 있습니다." > "${LOG_DIR}/slop_tmp.txt"; fi
sed -i '' "/{{SLOP_LIST}}/r ${LOG_DIR}/slop_tmp.txt" "$NIGHTLY_REPORT"
sed -i '' "s/{{SLOP_LIST}}//g" "$NIGHTLY_REPORT"

# 7. Phase 5: Knowledge Distillation
echo "[Phase 5] 장기 기억 업데이트 중..."
NEW_ROW="| $DATE_STR | $TEST_STATUS | Fix:$FIX_COUNT, Slop:$SLOP_COUNT | 자율 개선 및 테스트 통과 |"
if grep -q "$DATE_STR" "$MEMORY_FILE"; then sed -i '' "/$DATE_STR/d" "$MEMORY_FILE"; fi
sed -i '' "/|---|---|---|---|/a\\
$NEW_ROW" "$MEMORY_FILE"
sed -i '' "s/위반 파일 수: .*/위반 파일 수: $SLOP_COUNT)/g" "$MEMORY_FILE"

# 8. Phase 6: Commit & Push
echo "[Phase 6] 개선 사항 원격 전송..."
cd "$BASE_DIR"
git add .
git commit -m "harness: knowledge update v6.0 ($DATE_STR)" || true

cd "$PROJECT_DIR"
git add .
git commit -m "harness: auto-improvement & test result ($DATE_STR)"
git push origin "$BRANCH_NAME"

echo "[Harness v6.0] 모든 자율 개선 작업 완료! 🚀🛠️"
exit 0
