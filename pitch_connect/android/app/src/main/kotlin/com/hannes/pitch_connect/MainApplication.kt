package com.hannes.pitch_connect

import android.app.Application
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

class MainApplication : Application() {

    override fun onCreate() {
        super.onCreate()

        // audio_service가 내부적으로 사용하는 엔진 ID와 동일한 키로 엔진을 미리 웜업.
        // 이렇게 하면 audio_service가 확인하는 BinaryMessenger와 
        // MainActivity가 사용하는 엔진이 동일 인스턴스가 되어 WrongEngineDetected 오류를 방지합니다.
        val engineId = "audio_service_engine"
        if (FlutterEngineCache.getInstance().get(engineId) == null) {
            val engine = FlutterEngine(this)
            engine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )
            FlutterEngineCache.getInstance().put(engineId, engine)
        }
    }
}
