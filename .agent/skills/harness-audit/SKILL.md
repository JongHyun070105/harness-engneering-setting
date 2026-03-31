---
name: Harness Audit (하네스 진단)
description: 12원칙 기반으로 프로젝트의 에이전트 친화도를 정량 평가하고 개선 로드맵을 제시하는 진단 스킬
---

# Harness Audit — 에이전트 친화도 진단

이 스킬은 프로젝트가 "에이전트가 독립적으로 기여할 수 있는 환경인가?"를 **정량적으로** 측정한다.
OpenAI의 Harness Engineering 원칙을 기반으로 12원칙 × 0~10점 = 최대 100점으로 평가한다.

> **Read-Only**: 이 스킬은 진단/제안만 수행한다. 코드를 수정하지 않는다.

---

## 핵심 원칙

1. **Read-only**: 분석만 하고 절대 수정하지 않는다
2. **Evidence-first**: 모든 판단에 파일 경로 근거를 포함한다
3. **Principle-driven**: 12원칙 + 성숙도 프레임워크 기반 채점
4. **Self-referential**: 이 스킬 자체도 동일 기준으로 진단 가능

---

## 12개 하네스 원칙 (요약)

상세 정의와 점수 기준은 `references/principles.md`를 참조한다.

| # | 원칙 | 핵심 질문 |
|---|---|---|
| P1 | Agent Entry Point | 명확한 진입점이 있는가? |
| P2 | Map, Not Manual | 문서가 탐색 가능한 지도인가? |
| P3 | Invariant Enforcement | 도구가 실수를 자동으로 잡는가? |
| P4 | Convention Over Configuration | 명시적 컨벤션이 있는가? |
| P5 | Progressive Disclosure | 필요한 정보를 적시에 접근하는가? |
| P6 | Layered Architecture | 의존성 방향이 강제되는가? |
| P7 | Garbage Collection | 낡은 코드/문서가 정리되는가? |
| P8 | Observability | 에이전트가 결과를 자체 검증하는가? |
| P9 | Knowledge in Repo | 지식이 레포에 있는가? |
| P10 | Reproducibility | 같은 입력 → 같은 결과인가? |
| P11 | Modularity | 변경 영향 범위가 예측 가능한가? |
| P12 | Self-Documentation | 코드 자체가 의도를 설명하는가? |

---

## 성숙도 등급

| 등급 | 점수 | 의미 |
|---|---|---|
| L1 | 0-19 | None — 에이전트 협업 미고려 |
| L2 | 20-39 | Basic — 최소 문서만 존재 |
| L3 | 40-59 | Structured — 체계적 구조, 부분 자동화 |
| L4 | 60-79 | Optimized — 높은 자동화, 낮은 drift |
| L5 | 80-100 | Autonomous — 에이전트 독립 기여 가능 |

### 가중치

| 차원 | 포함 원칙 | 가중치 |
|---|---|---|
| A. 문서 & 탐색 | P1, P2, P5, P12 | 30% |
| B. 검증 & 일관성 | P3, P4, P10 | 30% |
| C. 아키텍처 & 지식 | P6, P9, P11 | 20% |
| D. 운영 & 유지보수 | P7, P8 | 20% |

**산출**: `Score = (DimA × 0.3 + DimB × 0.3 + DimC × 0.2 + DimD × 0.2) × 10`

---

## 실행 절차

### 1단계: 대상 확인
- 진단 대상 프로젝트의 루트 디렉토리를 확인한다
- Flutter/Dart 프로젝트인지 확인한다 (`pubspec.yaml` 존재 여부)

### 2단계: 체크리스트 실행
- `references/checklist.md`의 항목을 하나씩 확인한다
- 각 항목에 ✅/❌를 표시하고 근거(파일 경로)를 기록한다

### 3단계: 원칙별 점수 산출
- `references/principles.md`의 점수 기준에 따라 P1~P12에 0~10점을 부여한다
- 4개 차원의 가중 평균으로 종합 점수를 계산한다

### 4단계: 리포트 출력
- `references/report-template.md` 형식으로 결과를 출력한다
- Quick Wins (적은 노력 + 큰 점수 향상) 항목을 3개 이상 제안한다

---

## 참조 문서

| 파일 | 역할 |
|---|---|
| `references/principles.md` | 12원칙 판단 기준 + 점수 기준 |
| `references/checklist.md` | Flutter 맞춤 체크리스트 (~60항목) |
| `references/report-template.md` | 리포트 출력 형식 |

---

## Antigravity 환경 맞춤 사항

Antigravity(Gemini)에서는 Agent Entry Point가 다르다:

| 원본 (Codex/Claude) | Antigravity 대응 |
|---|---|
| `AGENTS.md` / `CLAUDE.md` | `.agent/rules/global.md` |
| 하위 `AGENTS.md` | `.agent/rules/project.md` |
| `.codex/skills/` | `.agent/skills/` |
| `CLAUDE.md` gotchas 섹션 | `.agent/rules/gotchas.md` |

> **원칙**: 도구가 달라도 원칙은 같다. 진입점 이름만 다를 뿐, "에이전트가 즉시 작업 시작 가능한가?"를 평가한다.
