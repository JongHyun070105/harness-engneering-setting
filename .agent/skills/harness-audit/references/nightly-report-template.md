---
name: 종합 야간 자율 수행 보고서 (Full-Stack)
---
# 🌎 종합 야간 자율 수행 보고서 (Nightly Full-Stack Report)

============================================
  Harness Engineering Global Loop
  날짜: {{DATE}}
  진단 범위: Frontend, Backend, Infrastructure
============================================

## 🚦 영역별 건강 상태 (Health Summary)

| 영역 | 상태 | 주요 내용 |
|---|---|---|
| **Frontend (Flutter)** | {{FRONT_STATUS}} | `dart analyze`, `format`, `AI Slop` |
| **Backend (Worker)** | {{BACK_STATUS}} | `security scan`, `config check` |
| **Infrastructure** | {{INFRA_STATUS}} | `.env`, `CI/CD Workflows` |

---

## 1. 🎨 프론트엔드 (Frontend) 상세
- **자동 교정**: {{FIX_COUNT}}개의 린트 이슈 해결
- **전용 슬롭 분석 (Slop Cut-list)**:
{{SLOP_LIST}}

## 2. ⚙️ 백엔드 (Backend) 상세
- **Cloudflare Worker**: 시크릿 노출 여부 및 `wrangler.toml` 구조 검증
- **권장 사항**: {{BACK_ADVICE}}

## 3. 🛡️ 인프라 및 보안 (Infra)
- **설정 정합성**: 프로젝트 루트 필수 파일(`.env`, `.gitignore`) 검증 완료
- **보안 감사**: 77-point Security 프로토콜 기반 스캔 수행

---

## 📅 오늘 아침 권장 작업 (Action Items)

- [ ] `harness/nightly-fullstack-{{DATE}}` 브랜치 변경 사항 검토
- [ ] 상기 기재된 각 영역별 위반 사항 수동 조치
- [ ] 전체 레이어 통합 테스트 실행

---
> "하네스가 프로젝트 전반을 분석하여 더욱 깊은 이해도를 갖추게 되었습니다. 이제 인프라 걱정 없이 코드에만 집중하세요!"
