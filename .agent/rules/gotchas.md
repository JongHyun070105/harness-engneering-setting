# Gotchas — 에이전트 실패 기록 (글로벌)

> 에이전트가 실수/삽질할 때마다 여기에 기록한다.
> 이 파일은 매 세션 시작 시 자동으로 읽히며, 같은 실수를 반복하지 않게 한다.
> 프로젝트 공통 gotchas는 여기에, 프로젝트 고유 gotchas는 각 프로젝트의 `docs/gotchas.md`에 기록한다.

## 기록 형식

```
### [카테고리] 요약 한 줄
- ❌ 잘못한 것: ...
- ✅ 올바른 방법: ...
- 💡 왜 이런 일이 생기는지: ...
- 📅 발견일: YYYY-MM-DD
```

---

### [코드 수정] flutter create 후 보일러플레이트 코드 제거 누락
- ❌ 잘못한 것: 파일 일부만 교체하여 기존 보일러플레이트가 남아 중복 클래스 에러 발생
- ✅ 올바른 방법: `flutter create` 생성 파일은 `write_to_file(Overwrite=true)`로 전체 교체
- 💡 왜 이런 일이 생기는지: `replace_file_content`는 매칭된 부분만 교체하므로, 나머지가 남을 수 있음
- 📅 발견일: 2026-03-31

---

### [Android 빌드] sqflite_android BAKLAVA 컴파일 에러
- ❌ 잘못한 것: `sqflite_android 2.4.2+2`가 `Build.VERSION_CODES.BAKLAVA` 상수를 참조하는데, 빌드 툴이 이를 인식 못해 컴파일 에러 발생
- ✅ 올바른 방법: `~/.pub-cache/hosted/pub.dev/sqflite_android-2.4.2+2/android/src/main/java/com/tekartik/sqflite/Utils.java`에서 `Build.VERSION_CODES.BAKLAVA`를 숫자 리터럴 `36`으로 교체
- 💡 왜 이런 일이 생기는지: `BAKLAVA` 상수는 Android SDK 36에 추가됐지만 일부 빌드 툴/JDK 조합에서 심볼을 못 찾음. `sqflite_android 2.4.2+3`이 공식 패치이나 Dart 3.10을 요구해 Flutter 3.24.3과 호환 안 됨. pub-cache 직접 패치가 현재 가장 빠른 해결책
- 📅 발견일: 2026-04-16
