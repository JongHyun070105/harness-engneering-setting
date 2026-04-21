---
name: 하네스 감사 리포트 템플릿
---
# Harness Audit Report Template

```
============================================
  Harness Audit Report
  대상: [프로젝트명]
  날짜: [YYYY-MM-DD]
  도구: harness-audit v1.0
============================================

## 종합 점수

  종합: [점수]/100 → Level [L1-L5] ([등급명])

## 차원별 점수

| 차원 | 포함 원칙 | 점수 | 가중 점수 |
|---|---|---|---|
| A. 문서 & 탐색 | P1, P2, P5, P12 | /10 | × 0.3 = |
| B. 검증 & 일관성 | P3, P4, P10 | /10 | × 0.3 = |
| C. 아키텍처 & 지식 | P6, P9, P11 | /10 | × 0.2 = |
| D. 운영 & 유지보수 | P7, P8 | /10 | × 0.2 = |

## 원칙별 점수

| # | 원칙 | 점수 | 근거 요약 |
|---|---|---|---|
| P1 | Agent Entry Point | /10 | |
| P2 | Map, Not Manual | /10 | |
| P3 | Invariant Enforcement | /10 | |
| P4 | Convention Over Configuration | /10 | |
| P5 | Progressive Disclosure | /10 | |
| P6 | Layered Architecture | /10 | |
| P7 | Garbage Collection | /10 | |
| P8 | Observability | /10 | |
| P9 | Knowledge in Repo | /10 | |
| P10 | Reproducibility | /10 | |
| P11 | Modularity | /10 | |
| P12 | Self-Documentation | /10 | |

## 체크리스트 요약

| 카테고리 | 충족 | 전체 | 비율 |
|---|---|---|---|
| 1. Agent Entry Point | /10 | 10 | % |
| 2. 문서 구조 | /10 | 10 | % |
| 3. Invariant 강제 | /12 | 12 | % |
| 4. 아키텍처 | /8 | 8 | % |
| 5. 관찰성 & 검증 | /8 | 8 | % |
| 6. 운영 & 유지보수 | /6 | 6 | % |
| 7. 코드 가독성 | /6 | 6 | % |

## Quick Wins (우선 개선 항목)

적은 노력으로 큰 점수 향상이 가능한 항목:

1. [항목] — 예상 점수 향상: +[N]점
2. [항목] — 예상 점수 향상: +[N]점
3. [항목] — 예상 점수 향상: +[N]점

## 개선 로드맵

### 즉시 (1주 이내)
- [ ] ...

### 단기 (1개월 이내)
- [ ] ...

### 중기 (3개월 이내)
- [ ] ...
```
