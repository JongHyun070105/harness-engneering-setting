---
name: Flutter 프로젝트 표준 세팅
description: Flutter 프로젝트를 표준 아키텍처와 폴더 구조로 초기화하는 전문 스킬
---

# Flutter 프로젝트 표준 세팅 스킬

이 스킬은 새 Flutter 프로젝트의 초기 구조를 세팅할 때 참조하는 전문 지식 모듈이다.

---

## 1. 표준 폴더 구조

### Clean Architecture 기반

```
lib/
├── core/                  # 앱 공통 유틸리티
│   ├── constants/         # 상수 정의
│   ├── errors/            # 예외/에러 클래스
│   ├── theme/             # 테마, 색상, 타이포그래피
│   └── utils/             # 유틸리티 함수
├── features/              # 기능별 모듈
│   └── <feature_name>/
│       ├── data/          # 데이터 소스, 레포지토리 구현
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/        # 비즈니스 로직, 엔티티
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/  # UI, 상태관리
│           ├── pages/
│           ├── widgets/
│           └── providers/ (또는 blocs/)
└── main.dart
```

### 단순 구조 (소규모 프로젝트)

```
lib/
├── models/        # 데이터 모델
├── screens/       # 화면
├── widgets/       # 재사용 위젯
├── services/      # API, DB 서비스
├── utils/         # 유틸리티
└── main.dart
```

---

## 2. 권장 기본 패키지

| 카테고리 | 패키지 | 용도 |
|---|---|---|
| 상태관리 | `flutter_riverpod` | 선언적 상태관리 (권장) |
| 라우팅 | `go_router` | 선언적 라우팅 |
| 네트워크 | `dio` | HTTP 클라이언트 |
| 로컬 저장소 | `shared_preferences` | 간단한 키-값 저장 |
| 직렬화 | `freezed` + `json_serializable` | 불변 모델 + JSON 변환 |
| 코드 생성 | `build_runner` (dev) | 코드 제너레이터 실행 |
| 린팅 | `flutter_lints` | 정적 분석 규칙 |

> **주의**: 패키지는 프로젝트 요구사항에 따라 선별적으로 추가한다. 불필요한 의존성은 최소화한다.

---

## 3. 아키텍처 패턴 가이드

### Riverpod + Clean Architecture (권장)

```dart
// 1. Entity (domain 레이어)
class User {
  final String id;
  final String name;
  const User({required this.id, required this.name});
}

// 2. Repository Interface (domain 레이어)
abstract class UserRepository {
  Future<User> getUser(String id);
}

// 3. Repository Implementation (data 레이어)
class UserRepositoryImpl implements UserRepository {
  final Dio dio;
  UserRepositoryImpl(this.dio);

  @override
  Future<User> getUser(String id) async {
    final response = await dio.get('/users/$id');
    return UserModel.fromJson(response.data);
  }
}

// 4. Provider (presentation 레이어)
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.read(dioProvider));
});

final userProvider = FutureProvider.family<User, String>((ref, id) {
  return ref.read(userRepositoryProvider).getUser(id);
});
```

---

## 4. 프로젝트 체크리스트

새 프로젝트 생성 시 반드시 확인:

- [ ] `analysis_options.yaml`에 린트 규칙 설정
- [ ] `.gitignore`에 민감 파일 포함 확인 (`.env`, `*.jks`, `*.keystore`)
- [ ] `pubspec.yaml`에 프로젝트 설명(description) 작성
- [ ] `.agent/rules/project.md`에 프로젝트 고유 규칙 정의
- [ ] `docs/gotchas.md`에 빈 템플릿 생성
- [ ] README.md에 프로젝트 개요 작성

---

## 5. Spec-Plan 템플릿 (SDD)

MEDIUM/COMPLEX 작업 시 아래 구조로 작성한다.
**핵심: 코드가 아니라 명세(Spec)가 Source of Truth다.**

```markdown
# [기능명] Spec-Plan

## 1. 명세 (Spec)

### 합격 기준 (이것이 되면 성공)
- [ ] ...
- [ ] ...

### 제약 사항 (이것은 하지 않는다)
- ...
- ...

## 2. 테스트 케이스 (명세에서 도출)
| # | 테스트 | 예상 결과 | 검증 방법 |
|---|---|---|---|
| 1 | ... | ... | unit test / 수동 확인 |
| 2 | ... | ... | ... |

## 3. 영향 분석
| 파일/모듈 | 변경 유형 | 설명 |
|---|---|---|
| ... | 신규/수정/삭제 | ... |

## 4. 아키텍처 결정
- 결정 사항과 그 이유를 명시한다.
- gotchas.md에 관련 항목이 있다면 반드시 참조한다.

## 5. 구현 단계
### 1단계: [이름]
- 작업 내용: ...
- 체크포인트: `dart analyze` ✅ → 테스트 ✅ → 커밋

### 2단계: [이름]
- 작업 내용: ...
- 체크포인트: `dart analyze` ✅ → 테스트 ✅ → 커밋

## 6. 검증 (명세 대조)
- [ ] 합격 기준 항목 전체 통과
- [ ] 제약 사항 위반 없음
- [ ] 전체 테스트 통과
- [ ] 아키텍처 위반 없음
- [ ] 명세 자체에 부족한 점 → 명세 업데이트
```

> **SDD 원칙**: "결과물"을 정의하지 말고 "기준"을 정의한다. 기준이 있으면 AI 결과물을 일관되게 평가하고 교정할 수 있다.

