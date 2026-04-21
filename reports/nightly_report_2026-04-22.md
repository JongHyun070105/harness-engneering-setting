---
name: 야간 자율 수행 보고서 템플릿
---
# 🌙 야간 자율 수행 보고서 (Nightly Autonomous Report)

============================================
  Harness Engineering Nightly Loop
  날짜: 2026-04-22
  수행자: Antigravity Harness
============================================

## 1. 🛠 자동 교정 내역 (Auto-Fix)

- **Flutter Fix**: 총 {{FIX_COUNT}}개의 린트/경고가 자동으로 수정되었습니다.
- **Formatting**: {{FORMAT_FILE_COUNT}}개의 파일에 대해 `dart format`이 적용되었습니다.
- **Security Check**: {{SECURITY_STATUS}}

## 2. 🔍 아키텍처 및 AI Slop 진단

- **비대한 파일 (Slop Cut-list)**:
  - ./lib/config/theme.dart (324 l) -> 권장: {{REFACTOR_STRATEGY_1}}
  - ./lib/presentation/screens/review_selection_screen.dart (588 l) -> 권장: {{REFACTOR_STRATEGY_2}}

- **아키텍처 위반**: {{ARCH_VIOLATION_SUMMARY}}

## 3. 📅 오늘 아침 기상 후 권장 작업 (Morning TODOs)

- [ ] `harness/nightly-cleanup` 브랜치 변경 사항 검토 및 머지
- [ ] 나머지 {{REMAINING_LINT_COUNT}}개의 정적 분석 에러 수동 해결
- [ ] 상기 Slop Cut-list 중 1순위 파일 리팩토링 승인

---
> "밤 사이 하네스가 프로젝트의 기초를 다져두었습니다. 이제 더 고도화된 기능 개발에 집중하세요!"
