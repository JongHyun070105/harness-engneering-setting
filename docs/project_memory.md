# 🧠 프로젝트 장기 기억 (Project Memory)

이 문서는 하네스 엔지니어링 루프를 통해 누적된 프로젝트의 **동적 상태와 맥락**을 기록합니다. 상세한 코딩 컨벤션은 [docs/conventions.md](file:///Users/macintosh/IdeaProjects/HarnessEngineering/docs/conventions.md)를 참조하십시오.

---

## 📈 프로젝트 건강도 추이 (Health Trends)

| 날짜 | 종합 점수 | 주요 상태 | 요약 |
|---|---|---|---|
| 2026-04-22 | FAIL | Fix:0, Slop:13 | 자율 개선 및 테스트 통과 |
| **최초 설정** | - | - | 하네스 지식 축적 시스템 가동 |

---

## 🏗 핵심 기술 결정 (ADR Summary)
- **Architecture**: Clean Architecture / Riverpod 기반.
- **Backend**: Cloudflare Worker (V2 Proxy 적용 중).
- **History**: 과거 Durable Object 마이그레이션 이슈 해결 완료.

---

## 👤 사용자 페르소나 및 특이 성향
- **우선순위**: 토큰 효율을 최우선으로 하며, 장황한 설명보다 **모듈화된 파편 지식**을 선호함.
- **피드백 루프**: 실수는 즉시 [gotchas.md](file:///Users/macintosh/IdeaProjects/HarnessEngineering/.agent/rules/gotchas.md)에 반영하여 시스템을 강화하는 스타일.

---

## 🛠 현재 중점 관리 항목
- **AI Slop**: 파일당 300줄 이하 (현재 위반: 14개)
- **Security Check**: 매일 밤 Vibe Check 77 수행 필수.

---
> "기록은 에이전트의 지능을 진화시킵니다."
