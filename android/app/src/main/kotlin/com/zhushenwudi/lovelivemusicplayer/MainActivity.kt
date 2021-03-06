package com.zhushenwudi.lovelivemusicplayer

import androidx.annotation.NonNull
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant.registerWith

class MainActivity : AudioServiceActivity() {
    companion object {
        //通讯名称,回到手机桌面
        const val CHANNEL = "android/back/desktop"
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        registerWith(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { methodCall, result ->
            if (methodCall.method == "backDesktop") {
                result.success(true)
                moveTaskToBack(false)
            }
        }
    }
}
