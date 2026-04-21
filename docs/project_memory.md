# 🧠 프로젝트 장기 기억 (Project Memory)

이 문서는 하네스 엔지니어링 루프를 통해 축적된 프로젝트의 성장사와 맥락을 기록합니다. 에이전트는 작업 시작 전 이 문서를 읽고 과거의 결정 사항과 현재의 중점 관리 항목을 파악합니다.

---

## 📈 프로젝트 건강도 추이 (Health Trends)

| 날짜 | 종합 점수 | 주요 상태 | 요약 |
|---|---|---|---|
| 2026-04-22 | Healthy | Fix:0, Slop:14 | 야간 자율 개선 완료 |
| **최초 설정** | - | - | 하네스 v5.0 지식 축적 시스템 가동 |

---

## 🏗 아키텍처 및 기술 결정 패턴 (ADR Context)
- **UI Architecture**: Flutter/Dart, Clean Architecture (Presentation-Domain-Data)
- **State Management**: Riverpod 권장
- **Backend**: Cloudflare Worker (JS/TS)

---

## 👤 사용자 코딩 스타일 및 선호도 (User Persona)
- **주석**: 복잡한 로직에는 명확한 **한국어로 된 'Why' 주석**을 선호함.
- **린트**: `analysis_options.yaml`에 정의된 엄격한 규칙 준수.
- **메모리**: 실패 사례는 `agent/rules/gotchas.md`에 기록하여 재발 방지.

---

## 🛠 중점 관리 항목 (Focus Areas)
- **AI Slop**: 파일당 300줄 이하 유지 (현재 위반 파일 수: 14)
- **Security**: 77-point Vibe Check 기반 보안 강화

---
> "기록은 기억을 지배합니다. 하네스는 매일 밤 당신의 프로젝트를 더 깊이 이해하기 위해 학습합니다."
