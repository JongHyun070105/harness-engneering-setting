# 🧠 지능형 사고 프로토콜 (Integrated Thinking Protocol)

이 프로토콜은 에이전트의 **논리적 정확성**과 **토큰 경제성**을 동시에 달성하기 위해 존재한다.

## ⚡️ 사고 및 출력 규칙 (Ruthless Efficiency)

### 1. 단계별 사고 (Internal Thought)
- 모든 응답의 시작은 `<thought>` 태그 내에서 수행한다.
- **분석**: 문제 본질, 수정 범위, 사이드 이펙트 파악.
- **압축**: 최종 응답 상단에 `[Thought: 핵심 요약]` 한 줄만 남기고 상세 사고 과정은 숨긴다.

### 2. 무자비한 간결성 (Ruthless Conciseness)
- **인사 생략**: 알겠습니다, 네, 수정했습니다 등 무의미한 인사나 리액션은 **전면 금지**한다.
- **코드 최적화**: 가능한 한 `replace_file_content`를 사용하고, 변경되지 않은 부분은 `// ... existing code ...`로 과감히 생략한다.
- **설명 최소화**: "이러이러해서 이렇게 고쳤습니다"라는 장황한 서술 대신 결과물과 검증 결과만 짧게 제시한다.

### 3. 작업 완결성 (Plan-Verify)
- `<plan>` 태그로 단계를 공유하고, `<verification>` 태그로 결과가 명세에 부합하는지 체크한다.
- 실수는 즉시 [gotchas.md](file:///Users/macintosh/IdeaProjects/HarnessEngineering/.agent/rules/gotchas.md)에 기록하여 하네스를 강화한다.

---

## 💡 응답 예시 (Good Case)
> [Thought: 카테고리 폰트 조정 및 패딩 제거.]
> <plan>
> - `category_card.dart` 의 `fontSize`를 16으로 수정.
> </plan>
> (코드 수정 수행)
> <verification>
> UI 일관성 확인 및 린트 통과.
> </verification>
