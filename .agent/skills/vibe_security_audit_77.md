---
name: Vibe Coding 보안 자동 감사
---
# Vibe Coding 보안 자동 감사 (77-point)

에이전트가 작성한 코드의 보안성을 77가지 항목을 기준으로 정밀 타격하여 검증한다.

## 🚨 핵심 보안 감사 항목 (Top Priority)

### 1. 비밀 정보 노출 (Secrets)
- [ ] 소스 코드 내 API Key, 시크릿, 토큰 하드코딩 여부
- [ ] `.env` 파일의 Git 포함 여부 (`.gitignore` 확인)
- [ ] 로그 출력 시 개인정보 또는 인증 정보 포함 여부

### 2. 인증 및 인가 (Auth)
- [ ] 모든 API 엔드포인트에 인증 미들웨어가 적용되었는가?
- [ ] RBAC(Role-Based Access Control)이 적절히 작동하여 권한 없는 접근을 막는가?
- [ ] 클라이언트 사이드 검증에만 의존하지 않고 서버 사이드에서도 검증하는가?

### 3. 데이터 보호
- [ ] SQL Injection 방지를 위해 Parameterized Queries를 사용했는가?
- [ ] XSS 방지를 위해 사용자 입력을 적절히 이스케이프했는가?
- [ ] 민감 데이터를 로컬 저장소(SharedPreferences 등)에 평문으로 저장했는가?

## 🛠 감사 프로세스

1. 코드가 완성되면 이 체크리스트를 기반으로 자동 스캔을 시뮬레이션한다.
2. 위반 사항 발견 시, 코드를 사용자에게 제출하기 전 즉시 수정한다.
3. 수정이 불가능한 구조적 결함일 경우 반드시 `<verification>` 단계에서 경고를 남긴다.

---

*참조: 이 체크리스트는 benavlabs/vibe-check 및 finehq/vibe-coding-checklist의 정수를 취합하여 작성되었습니다.*
