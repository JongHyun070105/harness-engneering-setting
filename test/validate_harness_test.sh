#!/bin/bash
# /make-test 워크플로우 규약에 따른 다각적 엣지 케이스 테스트 Suite

echo "======================================"
echo "Starting Harness Linter Test Suite (Good / Bad / Edge Cases)"
echo "======================================"

# 격리 환경 구성
BASE_TEST_DIR="/tmp/harness_test_env"
rm -rf "$BASE_TEST_DIR"
mkdir -p "$BASE_TEST_DIR"
cp scripts/validate_harness.sh "$BASE_TEST_DIR/"
export LINTER="$BASE_TEST_DIR/validate_harness.sh"
chmod +x "$LINTER"

# 워크플로우 디렉토리 방해 배제 (빈 디렉토리 고정)
export WORKFLOWS_DIR="$BASE_TEST_DIR/dummy_workflows"
mkdir -p "$WORKFLOWS_DIR"

FAILED_TESTS=0
TOTAL_TESTS=0

# 테스트 실행기 헬퍼 함수
function run_case() {
  local case_name="$1"
  local expected_exit_code="$2"
  local content="$3"

  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  
  local case_dir="$BASE_TEST_DIR/$case_name"
  mkdir -p "$case_dir"
  export SKILLS_DIR="$case_dir"
  
  # 임시 마크다운 생성
  echo "$content" > "$case_dir/test.md"

  # 린터 실행 및 조용한 에러 처리 (터미널 아웃풋 난잡함 방지)
  "$LINTER" > /dev/null 2>&1
  local actual_exit_code=$?

  if [ "$actual_exit_code" -eq "$expected_exit_code" ]; then
    echo "✅ [PASS] $case_name"
  else
    echo "❌ [FAIL] $case_name (Expected Exit Code: $expected_exit_code, Actual: $actual_exit_code)"
    FAILED_TESTS=$((FAILED_TESTS + 1))
  fi
}

# -----------------
# 1. 긍정 시나리오 (Good)
# -----------------
# 기대값: 0 (통과)
content_case1="---
name: Good Test
---
# Title"
run_case "Case_1_Good_Frontmatter" 0 "$content_case1"

# -----------------
# 2. 부정 시나리오 (Bad)
# -----------------
# 기대값: 1 (실패)

content_case2="# Bad Title
No frontmatter here."
run_case "Case_2_Bad_No_Frontmatter" 1 "$content_case2"

content_case3="\`\`\`yaml
name: foo
\`\`\`"
run_case "Case_3_Bad_CodeBlock_Instead" 1 "$content_case3"

# -----------------
# 3. 애매한 시나리오 (Edge Cases)
# -----------------
# 기대값: 1 (실패해야만 정상적인 린터)

content_case4="
---
name: Edge Initial Empty Line
---"
run_case "Case_4_Edge_Starts_With_EmptyLine" 1 "$content_case4"

content_case5=""
run_case "Case_5_Edge_Empty_File" 1 "$content_case5"

content_case6=" ---
name: Edge Whitespace"
run_case "Case_6_Edge_Whitespace_Before_Delimiter" 1 "$content_case6"


# -----------------
# 결과 리포팅
# -----------------
echo "======================================"
if [ "$FAILED_TESTS" -eq 0 ]; then
  echo "🎉 All $TOTAL_TESTS tests passed successfully! Linter handles all edge cases nicely."
  # 정리
  rm -rf "$BASE_TEST_DIR"
  exit 0
else
  echo "💥 $FAILED_TESTS out of $TOTAL_TESTS tests failed! Check your linter logic."
  exit 1
fi
