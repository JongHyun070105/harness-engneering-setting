# HarnessEngineering

AI 에이전트(Antigravity)를 위한 **하네스 엔지니어링**이 적용된 Flutter 프로젝트 워크스페이스입니다.

## 하네스 구조

```
.agent/
├── rules/
│   ├── global.md              ← 🌐 전역 규칙 (SDD + 복잡도 분류 + 프로토콜)
│   └── gotchas.md             ← 📝 실패 기록 (매 세션 자동 주입)
├── workflows/
│   ├── new-flutter-project.md ← 🔄 프로젝트 생성 (하네스 자동 세팅)
│   ├── pre-commit.md          ← 🔄 커밋 전 품질 + 아키텍처 검증
│   └── harness-audit.md       ← 🔄 12원칙 에이전트 친화도 진단
└── skills/
    ├── flutter-project-setup/ ← 🧩 초기화 + Spec-Plan 템플릿
    └── harness-audit/         ← 🧩 12원칙 진단 (60항목 체크리스트)

docs/
└── conventions.md             ← 📖 상세 코딩 컨벤션

scripts/
└── check_architecture.sh     ← ⚙️ 아키텍처 린터 (기계적 강제)
```

## 핵심 원칙

| 원칙 | 설명 |
|---|---|
| **SDD (명세 기반 개발)** | 코드보다 명세가 먼저. 합격 기준 정의 → 테스트 도출 → 구현 |
| **Progressive Disclosure** | 규칙은 간결하게, 세부사항은 docs/에 분리 |
| **기계적 강제** | check_architecture.sh가 위반을 빌드 타임에 차단 |
| **gotchas 성장 엔진** | 실패가 쌓여 에이전트가 점점 똑똑해짐 (자동 주입) |
| **12원칙 정량 측정** | Harness Audit로 에이전트 친화도를 점수로 평가 |

## 사용법

- **새 프로젝트**: `/new-flutter-project`
- **커밋 전 검증**: `/pre-commit`
- **에이전트 친화도 진단**: `/harness-audit`

## 현재 성숙도: **L4 (67/100)** 🟢
