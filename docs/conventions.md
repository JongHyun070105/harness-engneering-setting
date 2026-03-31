# Dart/Flutter 코딩 컨벤션

> 이 문서는 `.agent/rules/global.md`에서 참조되는 상세 코딩 표준이다.
> 에이전트는 필요할 때 이 문서를 참조한다.

---

## 네이밍 규칙

| 대상 | 형식 | 예시 |
|---|---|---|
| 클래스, enum, typedef | UpperCamelCase | `UserRepository`, `AuthState` |
| 변수, 함수, 파라미터 | lowerCamelCase | `getUserById`, `isLoading` |
| 상수 | lowerCamelCase | `defaultPadding`, `maxRetryCount` |
| 파일, 디렉토리 | snake_case | `user_repository.dart` |
| private 멤버 | `_` 프리픽스 | `_internalState` |

## 코드 스타일

### const 적극 활용
```dart
// ✅ Good
const SizedBox(height: 16);
const EdgeInsets.symmetric(horizontal: 24);

// ❌ Bad — 불필요한 런타임 할당
SizedBox(height: 16);
EdgeInsets.symmetric(horizontal: 24);
```

### 디버그 출력
```dart
// ✅ Good
debugPrint('User loaded: $userId');
log('API response: $statusCode', name: 'NetworkService');

// ❌ Bad — 릴리즈 빌드에서도 출력됨
print('User loaded: $userId');
```

### 매직 넘버/문자열 금지
```dart
// ✅ Good
const maxRetryCount = 3;
const apiBaseUrl = 'https://api.example.com';

// ❌ Bad
if (retryCount > 3) { ... }
final url = 'https://api.example.com/users';
```

### import 정리
```dart
// ✅ Good — 순서: dart → package → relative
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

import '../models/user.dart';
import 'user_service.dart';
```

## 주석 규칙
- 복잡한 비즈니스 로직에는 **한국어 주석** 작성
- 명확한 코드는 주석 불필요 ("코드가 주석이다")
- TODO 형식: `// TODO(이름): 설명`

## 에러 처리
```dart
// ✅ Good — 구체적 예외 타입
try {
  await repository.fetchUser(id);
} on SocketException {
  // 네트워크 에러 처리
} on FormatException {
  // 파싱 에러 처리
}

// ❌ Bad — 모든 예외 삼키기
try {
  await repository.fetchUser(id);
} catch (e) {
  // 아무것도 안 함
}
```

## 테스트 규칙
- 테스트 파일명: `*_test.dart`
- 테스트 설명은 한국어로 작성 가능: `test('사용자 로그인 성공 시 홈 화면으로 이동', ...)`
- AAA 패턴 준수: Arrange(준비) → Act(실행) → Assert(검증)

## Null Safety 규칙

### `!` 연산자 (bang operator) 최소화
```dart
// ✅ Good — null 체크 후 안전하게 사용
final user = users.firstWhereOrNull((u) => u.id == id);
if (user == null) return;
print(user.name);

// ❌ Bad — ! 남용은 런타임 크래시 위험
final user = users.firstWhere((u) => u.id == id);
print(user!.name);  // null이면 크래시
```

### `late` 키워드 — 확실한 경우에만
```dart
// ✅ Good — 생명주기가 보장될 때 (initState에서 초기화)
late final AnimationController _controller;

// ❌ Bad — 초기화 타이밍이 불확실한 경우
late String userName;  // 어디서 초기화? → nullable로 선언
```

### null-aware 연산자 활용
```dart
// ✅ Good
final displayName = user?.name ?? '알 수 없음';
final count = prefs?.getInt('count') ?? 0;

// ❌ Bad — 불필요한 if-null 체크
String displayName;
if (user != null && user.name != null) {
  displayName = user.name;
} else {
  displayName = '알 수 없음';
}
```

