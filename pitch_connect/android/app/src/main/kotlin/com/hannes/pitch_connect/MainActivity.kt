package com.hannes.pitch_connect

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    // MainApplication에서 "audio_service_engine" 키로 미리 웜업한 엔진을 재사용합니다.
    // audio_service 플러그인이 동일 키를 사용하므로 BinaryMessenger 불일치가 발생하지 않습니다.
    override fun getCachedEngineId(): String = "audio_service_engine"
}
