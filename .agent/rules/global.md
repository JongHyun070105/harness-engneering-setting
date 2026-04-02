## 워크스페이스 개요

- **용도**: Flutter 앱 개발을 위한 하네스 엔지니어링 워크스페이스
- **기술 스택**: Flutter/Dart, Riverpod (권장), Clean Architecture
- **참조**: 상세 컨벤션 → `docs/conventions.md` | 실패 기록 → `rules/gotchas.md`

### 빌드/테스트/린트 명령어
```bash
flutter pub get           # 의존성 설치
dart analyze              # 정적 분석
dart format .             # 포맷팅
flutter test              # 테스트 실행
bash scripts/check_architecture.sh .  # 아키텍처 검증
```

---

## 🔒 에이전트 워크플로우 프로토콜

모든 기능 구현 / 리팩토링 / 버그 수정 요청 시 아래 절차를 따른다.

### Step 0: 복잡도 판단
요청을 아래 기준으로 분류하고, 분류에 맞는 프로세스를 따른다.

| 분류 | 기준 | 프로세스 |
|---|---|---|
| **SIMPLE** | 단일 파일 수정, 명확한 스코프 | 즉시 실행. 계획 불필요 |
| **MEDIUM** | 여러 파일, 모호한 스코프 | 명세(합격 기준) 작성 → 승인 → 실행 |
| **COMPLEX** | 다중 모듈, 아키텍처 변경, 새 기능 | 명세 → 테스트 도출 → 구현 계획 → 승인 → 단계별 실행 |

### Step 1: 분석 (자동)
- 사용자의 의도를 파악한다.
- 관련 코드, 문서, `docs/gotchas.md`를 탐색한다.
- 영향받는 파일과 범위를 파악한다.

### Step 2: 명세 → 설계 (MEDIUM/COMPLEX만) — SDD
코드보다 명세가 먼저다. 아래 **의도 명세(Intent Specification)** 형식을 갖춰 승인을 받는다:

**[의도 명세 템플릿]**
1. **목표(Goal)**: 이 작업이 완료되었을 때의 사용자 가치
2. **합격 기준(Acceptance Criteria)**: 검증 가능한 최소 단위 (Checklist)
3. **제약 사항(Constraints)**: 절대 하지 말아야 할 것 (예: 새 패키지 추가 금지)
4. **테스트 계획**: 엣지 케이스를 포함한 검증 시나리오

- ⚠️ **의도 명세 승인 없이 구현(How)을 시작하지 않는다.**
- 명세는 구현 중 발견된 사실에 따라 지속적으로 업데이트한다.

### Step 3: 구현 (단계별 체크포인트)
- 매 논리 단위 완료 시 체크포인트 실행:
  - `dart analyze` → `dart format` → 관련 테스트
  - Clean Architecture 프로젝트는 `scripts/check_architecture.sh`도 실행
- 체크포인트 실패 시 수정 후 재시도한다.

### Step 4: 검증 보고 — 명세 대조
- **원본 명세와 결과물을 대조**: 합격 기준을 하나씩 체크한다
- 전체 테스트 통과 확인
- 명세 자체에 부족한 점이 발견되면 **명세를 업데이트**한다 (피드백 루프)
- 새 발견 사항은 `docs/gotchas.md`에 기록

---

## 응답 규칙 및 하네스 문서화 규칙
- 모든 응답은 **한국어**로 작성한다.
- 답변은 간결하고 핵심 위주로 작성한다.
- **마크다운 규정**: 글머리 기호(List) 작성 시 반드시 **단일 하이픈과 공백(`- `)**을 사용한다 (`*` 금지).
- **하네스 문서(Skills/Workflows) 규정**: 새로운 템플릿/문서(.md) 생성 시 파일 최상단에 반드시 YAML 프론트매터(`--- \n name: ...`)를 포함해야 한다.

## 코딩 표준 (요약)
- [Effective Dart](https://dart.dev/effective-dart) 준수
- 상세 컨벤션은 `docs/conventions.md`를 참조한다.

```
# ✅ Good
const EdgeInsets.all(16)
final userRepository = ref.read(userRepositoryProvider);

# ❌ Bad
EdgeInsets.all(16)          // const 누락
print('debug message');     // print() 사용 금지 → debugPrint()
```

## 보안 규칙
- API 키, 시크릿을 **절대 하드코딩하지 않는다** → `--dart-define` 또는 환경변수 사용
- 외부 API 호출이 포함된 명령은 **반드시 사용자 확인**
- 서드파티 패키지 추가 시 pub.dev 점수, 유지보수 상태 확인

## Git 컨벤션
- **Conventional Commits**: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`
- 커밋 전 `dart analyze` + `dart format` 통과 필수
- 한 커밋에 하나의 논리적 변경만 포함

## 실패 대응 규칙
- 에이전트가 실수하면 **"어떤 규칙이 빠져있지?"**를 묻는다.
- 아키텍처 위반, 빌드 실패, 반복 실수 → `docs/gotchas.md`에 기록
- gotchas 형식: 잘못한 것(❌) + 올바른 방법(✅) + 왜 이런 일이 생기는지(💡)

## 프로젝트 구조 가이드라인
- 하위 프로젝트는 자체 `.agent/rules/project.md`와 `docs/gotchas.md`를 가진다.
- 프로젝트별 규칙이 이 전역 규칙보다 우선한다.
