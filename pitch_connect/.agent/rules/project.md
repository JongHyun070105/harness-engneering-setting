## 프로젝트 정보
- 프로젝트명: pitch_connect
- 상태관리: Riverpod
- 아키텍처: Clean Architecture

## 폴더 구조
- `lib/` 하위 구조는 Clean Architecture에 맞게 구성한다 (core, features).

## 주요 패키지
- flutter_riverpod
- nearby_connections (P2P 통신)
- flutter_webrtc (Fallback 통신)
- flutter_tts (음성 출력)
- vibration (햅틱 피드백)

## 프로젝트 고유 규칙
- 통신 지연시간(Latency)을 최소화하기 위해 바이너리 직렬화를 지향함. (See protocol.md)
- 포수 UI는 No-Look 조작을 위해 제스처 기반으로 설계함.
