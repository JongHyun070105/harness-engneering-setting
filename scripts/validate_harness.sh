#!/bin/bash
# 하네스 인프라를 검증하는 린터 스크립트 (validate_harness.sh)
# .agent/skills 및 .agent/workflows 내의 모든 markdown 파일이 
# 최상단에 YAML 프론트매터(---)를 포함하는지 검사합니다.

# 타겟 디렉토리를 환경변수로 덮어쓸 수 있도록 허용 (Self Test 용이성)
LOCAL_SKILLS_DIR="${SKILLS_DIR:-.agent/skills}"
LOCAL_WORKFLOWS_DIR="${WORKFLOWS_DIR:-.agent/workflows}"

FAILED_COUNT=0


function check_frontmatter() {
  local target_dir=$1
  if [ ! -d "$target_dir" ]; then
    echo "Warning: $target_dir does not exist. Skipping."
    return
  fi

  # 해당 디렉토리의 모든 markdown 파일 찾기
  find "$target_dir" -type f -name "*.md" | while read -r file; do
    # 첫째 줄이 '---'인지 검증
    first_line=$(head -n 1 "$file")
    if [ "$first_line" != "---" ]; then
      echo "❌ LINT ERROR: YAML Frontmatter missing in $file"
      FAILED_COUNT=$((FAILED_COUNT + 1))
      # 서브쉘 값 리턴을 위해 환경변수 우회 등으로 에러 캐치는 실제 bash에서 더 복잡하므로 
      # 여기서는 임시 파일에 쓰거나 터미널에 에러만 뱉는 식으로 간소화
      echo "1" > /tmp/validate_harness_failed
    fi
  done
}

echo "Running Harness Linter..."

# 이전 결과 초기화
rm -f /tmp/validate_harness_failed

check_frontmatter "$LOCAL_SKILLS_DIR"
check_frontmatter "$LOCAL_WORKFLOWS_DIR"

if [ -f /tmp/validate_harness_failed ]; then
  echo ""
  echo "💥 Validation Failed! Some harness documents are missing the required frontmatter."
  exit 1
else
  echo "✅ All harness documents conform to the required schema."
  exit 0
fi
