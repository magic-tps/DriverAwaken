package com.magicdrive.alert

import android.content.Intent
import android.content.IntentFilter
import android.media.MediaPlayer
import android.os.BatteryManager
import android.os.Build
import android.os.Debug
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val deviceChannelName = "com.magicdrive.alert/device"
    private var alarmPlayer: MediaPlayer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            deviceChannelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBatteryThermal" -> result.success(getBatteryThermal())
                "playAlarm" -> {
                    val repeat = call.argument<Int>("repeat")?.coerceIn(1, 4) ?: 1
                    playAlarm(repeat)
                    result.success(null)
                }
                "stopAlarm" -> {
                    stopAlarm()
                    result.success(null)
                }
                "setKeepScreenAwake" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    setKeepScreenAwake(enabled)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        setKeepScreenAwake(false)
        stopAlarm()
        super.onDestroy()
    }

    private fun getBatteryThermal(): Map<String, Any?> {
        val intent = applicationContext.registerReceiver(
            null,
            IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        )
        val level = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val scale = intent?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
        val tempTenths = intent?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, Int.MIN_VALUE)
            ?: Int.MIN_VALUE
        val voltageMv = intent?.getIntExtra(BatteryManager.EXTRA_VOLTAGE, -1) ?: -1
        val status = intent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
        val plugged = intent?.getIntExtra(BatteryManager.EXTRA_PLUGGED, 0) ?: 0

        val batteryPct = if (level >= 0 && scale > 0) {
            (level * 100.0) / scale
        } else {
            null
        }
        val temperatureC = if (tempTenths != Int.MIN_VALUE) {
            tempTenths / 10.0
        } else {
            null
        }

        return mapOf(
            "batteryLevel" to batteryPct,
            "temperatureC" to temperatureC,
            "voltageMv" to if (voltageMv >= 0) voltageMv else null,
            "status" to status,
            "plugged" to plugged,
            "timestampMs" to System.currentTimeMillis(),
            "deviceManufacturer" to Build.MANUFACTURER,
            "deviceModel" to Build.MODEL,
            "androidVersion" to Build.VERSION.RELEASE,
            "memoryBytes" to Debug.getPss().toLong() * 1024L
        )
    }

    private fun playAlarm(repeat: Int) {
        stopAlarm()
        val player = MediaPlayer.create(applicationContext, R.raw.magicdrive_alarm) ?: return
        alarmPlayer = player
        var remaining = repeat
        player.setOnCompletionListener { completed ->
            remaining -= 1
            if (remaining > 0) {
                completed.seekTo(0)
                completed.start()
            } else {
                stopAlarm()
            }
        }
        player.start()
    }

    private fun stopAlarm() {
        val player = alarmPlayer ?: return
        alarmPlayer = null
        try {
            player.setOnCompletionListener(null)
            if (player.isPlaying) {
                player.stop()
            }
        } catch (_: IllegalStateException) {
        } finally {
            player.release()
        }
    }

    private fun setKeepScreenAwake(enabled: Boolean) {
        runOnUiThread {
            if (enabled) {
                window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            } else {
                window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            }
        }
    }
}
