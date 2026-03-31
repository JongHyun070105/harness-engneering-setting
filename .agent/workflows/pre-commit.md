---
description: 커밋 전 코드 품질 검증 워크플로우
---

# 커밋 전 품질 검증

// turbo-all

1. `dart analyze`로 정적 분석을 실행한다.
2. `dart format --set-exit-if-changed .`로 포맷 검사를 실행한다.
   - 포맷 미적용 파일이 있으면 `dart format .`을 실행하여 자동 포맷한다.
3. `../../scripts/check_architecture.sh .`로 아키텍처 검증을 실행한다.
   - 위반 발견 시 사용자에게 보고하고 커밋을 중단한다.
4. `flutter test`로 테스트를 실행한다.
   - 테스트 실패 시 사용자에게 실패 내용을 보고하고 커밋을 중단한다.
5. 모든 검증 통과 시 사용자에게 커밋 준비 완료를 알린다.
