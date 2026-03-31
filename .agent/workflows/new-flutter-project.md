---
description: 새 Flutter 프로젝트를 표준 구조로 생성하는 워크플로우
---

# 새 Flutter 프로젝트 생성

## 사전 확인
1. 사용자에게 다음 정보를 확인한다:
   - 프로젝트 이름 (영문 snake_case)
   - 지원 플랫폼 (android, ios)
   - 사용할 상태관리 패턴 (Riverpod, Bloc, Provider 등)
   - 사용할 아키텍처 (Clean Architecture, MVVM, 단순 구조 등)

## 프로젝트 생성
// turbo
2. `flutter create --org com.hannes --project-name <프로젝트명> --platforms <플랫폼> ./<프로젝트명>` 을 실행한다.

## SDK 버전 고정
// turbo
2-1. 프로젝트 루트에 `.fvmrc` 파일을 생성한다:
```json
{
  "flutter": "3.35.1"
}
```
> FVM이 설치되어 있다면 `fvm use 3.35.1 --pin`으로 대체 가능. 버전은 현재 사용 중인 Flutter SDK에 맞춘다.

## analysis_options.yaml 강화
// turbo
2-2. 프로젝트의 `analysis_options.yaml`을 아래 내용으로 교체한다:
```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
  errors:
    missing_return: error
    dead_code: warning
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_declarations
    - avoid_print
    - prefer_single_quotes
    - sort_child_properties_last
    - use_key_in_widget_constructors
    - avoid_unnecessary_containers
    - prefer_final_locals
```

## 로컬 하네스 세팅
// turbo
3. 프로젝트 내에 `.agent/rules/project.md` 파일을 생성한다. 아래 템플릿을 기반으로 사용자 요구사항을 반영한다:
```markdown
## 프로젝트 정보
- 프로젝트명: <프로젝트명>
- 상태관리: <상태관리 패턴>
- 아키텍처: <아키텍처 패턴>

## 폴더 구조
- `lib/` 하위 구조는 <아키텍처>에 맞게 구성한다.

## 주요 패키지
- (사용자 요구사항에 따라 추가)

## 프로젝트 고유 규칙
- (프로젝트 특성에 맞게 추가)
```

## gotchas 세팅
// turbo
4. 프로젝트 내에 `docs/gotchas.md` 파일을 생성한다:
```markdown
# Gotchas — 에이전트 실패 기록

> 에이전트가 실수/삽질할 때마다 여기에 기록한다.
> 이 파일은 매 세션 시작 시 자동으로 참조되며, 같은 실수를 반복하지 않게 한다.

## 기록 형식

### [카테고리] 요약 한 줄
- ❌ 잘못한 것: ...
- ✅ 올바른 방법: ...
- 💡 왜 이런 일이 생기는지: ...
- 📅 발견일: YYYY-MM-DD
```

## 의존성 설치
5. 사용자가 선택한 패턴에 맞는 핵심 패키지를 `flutter pub add`로 추가한다.

## pre-commit hook 설치
// turbo
6. git hook을 설치하여 커밋 시 자동 검증을 강제한다:
```bash
mkdir -p .git/hooks
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
dart analyze && dart format --set-exit-if-changed lib/ && bash ../../scripts/check_architecture.sh .
EOF
chmod +x .git/hooks/pre-commit
```

## 마무리
// turbo
7. `dart analyze`로 프로젝트 상태를 확인한다.
8. 사용자에게 생성된 프로젝트 구조를 요약하여 보고한다.
   - .fvmrc ✅, analysis_options.yaml ✅, pre-commit hook ✅, gotchas.md ✅ 를 확인 보고한다.