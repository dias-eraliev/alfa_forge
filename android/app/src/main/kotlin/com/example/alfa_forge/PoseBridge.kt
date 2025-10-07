package com.example.alfa_forge

import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * PoseBridge: Простая заглушка для компиляции
 * Реальное определение поз происходит через Flutter ML Kit плагины
 */
class PoseBridge(
    private val activity: FlutterActivity,
    private val channel: MethodChannel
) : MethodChannel.MethodCallHandler {

    private var initialized = false

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                initialized = true
                result.success(mapOf(
                    "ok" to true,
                    "native" to "flutter_mlkit",
                    "version" to "1.0.0"
                ))
            }
            "process" -> {
                // Возвращаем пустой результат - обработка идет через ML Kit Flutter
                result.success(mapOf(
                    "points" to emptyList<Map<String, Any>>(),
                    "latencyMs" to 0,
                    "native" to "flutter_mlkit"
                ))
            }
            "dispose" -> {
                initialized = false
                result.success(mapOf("ok" to true))
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        private const val CHANNEL_NAME = "ai/pose"

        fun register(activity: FlutterActivity) {
            try {
                // Используем рефлексию для доступа к protected флutерEngine
                val engineField = FlutterActivity::class.java.getDeclaredField("flutterEngine")
                engineField.isAccessible = true
                val engine = engineField.get(activity) as? io.flutter.embedding.engine.FlutterEngine
                
                if (engine != null) {
                    val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL_NAME)
                    val bridge = PoseBridge(activity, channel)
                    channel.setMethodCallHandler(bridge)
                    Log.i("PoseBridge", "Registered stub MethodChannel: $CHANNEL_NAME")
                } else {
                    Log.w("PoseBridge", "FlutterEngine is null, cannot register channel")
                }
            } catch (e: Exception) {
                Log.e("PoseBridge", "Failed to register PoseBridge", e)
            }
        }
    }
}
