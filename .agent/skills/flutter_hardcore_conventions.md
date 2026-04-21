---
name: Flutter 전문가 컨벤션
---
# Flutter 전문가 컨벤션 (Hardcore)

이 스킬은 업계 최정상급 Flutter 개발 기준을 강제하여 유지보수성과 성능을 극대화한다.

## 🏗 아키텍처 및 위젯 구조

- **Composition Over Inheritance**: 위젯 상속보다는 조합을 우선한다.
- **Private Components**: 한 파일에 존재하는 복잡한 위젯은 반드시 `_PrivateWidget` 클래스나 메서드로 분리한다. (단, 상태가 필요없다면 `const` 클래스 위젯을 선호한다).
- **Line Limit**: 단일 위젯 클래스의 `build` 메서드는 60라인을 초과하지 않는다. 초과 시 반드시 기능을 분리한다.

## 🚀 성능 최적화

- **Const Everywhere**: 모든 불변 위젯과 생성자에는 반드시 `const` 키워드를 붙인다.
- **SizedBox vs Padding**: 단순한 간격은 `SizedBox`를 사용하고, 복잡한 여백은 `Padding`을 사용한다.
- **ListView.builder**: 아이템 개수가 가변적이거나 10개 이상일 경우 반드시 `.builder` 생성자를 사용하여 메모리 누수를 방지한다.

## 🧪 상태 관리 (Riverpod 2.0+)

- **AsyncNotifier**: 비동기 데이터 작업 시 반드시 `AsyncNotifier` 또는 `Family` 패턴을 활용한다.
- **Provider Isolation**: UI 비즈니스 로직은 `Provider` 내부에 둔다. 위젯은 `ref.watch`를 통해 상태만 소비한다.
- **Dependency Re-run**: `ref.watch`는 반드시 전산 비용이 낮은 로직에만 배치한다. 복잡한 계산은 `select`를 사용한다.

---

## 린트 및 스타일 가이드
- 모든 파일에는 후행 쉼표(Trailing Commas)를 필수 적용하여 Git Diff 시 가독성을 높인다.
- `print()`는 절대 사용하지 않으며, 필요 시 `debugPrint()` 또는 전용 로깅 라이브러리를 사용한다.
