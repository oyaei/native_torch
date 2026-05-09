package com.oyaiz.packages.native_torch

import android.content.Context
import android.hardware.camera2.CameraManager
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel

class NativeTorchPlugin: FlutterPlugin {
    private lateinit var channel: MethodChannel
    private var torchOn = false
    private var cameraManager: CameraManager? = null
    private var cameraId: String? = null

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "native_torch")
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getPlatformVersion" -> {
                    result.success("Android ${android.os.Build.VERSION.RELEASE}")
                }
                "isTorchAvailable" -> {
                    result.success(isTorchAvailable(binding.applicationContext))
                }
                "turnOn" -> {
                    try {
                        turnOnTorch(binding.applicationContext)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("TORCH_ERROR", e.message, null)
                    }
                }
                "turnOff" -> {
                    try {
                        turnOffTorch(binding.applicationContext)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("TORCH_ERROR", e.message, null)
                    }
                }
                "toggle" -> {
                    try {
                        if (torchOn) {
                            turnOffTorch(binding.applicationContext)
                        } else {
                            turnOnTorch(binding.applicationContext)
                        }
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("TORCH_ERROR", e.message, null)
                    }
                }
                "isTorchOn" -> {
                    result.success(torchOn)
                }
                "setIntensity" -> {
                    try {
                        val intensity = call.argument<Double>("intensity") ?: 1.0
                        setTorchIntensity(binding.applicationContext, intensity)
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "getMaxIntensity" -> {
                    try {
                        val maxLevel = getMaxTorchIntensity(binding.applicationContext)
                        result.success(maxLevel)
                    } catch (e: Exception) {
                        result.success(1)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        try {
            turnOffTorch(binding.applicationContext)
        } catch (e: Exception) {
            // Ignore
        }
    }

    private fun isTorchAvailable(context: Context): Boolean {
        return context.packageManager.hasSystemFeature("android.hardware.camera.flash")
    }

    private fun getCameraManager(context: Context): CameraManager {
        if (cameraManager == null) {
            cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
        }
        return cameraManager!!
    }

    private fun getCameraId(context: Context): String {
        if (cameraId == null) {
            val cameraManager = getCameraManager(context)
            val cameraIdList = cameraManager.cameraIdList
            for (id in cameraIdList) {
                val characteristics = cameraManager.getCameraCharacteristics(id)
                val flashAvailable = characteristics.get(
                    android.hardware.camera2.CameraCharacteristics.FLASH_INFO_AVAILABLE
                ) ?: false
                if (flashAvailable) {
                    cameraId = id
                    break
                }
            }
        }
        return cameraId ?: ""
    }

    private fun turnOnTorch(context: Context) {
        val cameraManager = getCameraManager(context)
        val cameraId = getCameraId(context)
        if (cameraId.isNotEmpty()) {
            cameraManager.setTorchMode(cameraId, true)
            torchOn = true
        }
    }

    private fun turnOffTorch(context: Context) {
        val cameraManager = getCameraManager(context)
        val cameraId = getCameraId(context)
        if (cameraId.isNotEmpty()) {
            cameraManager.setTorchMode(cameraId, false)
            torchOn = false
        }
    }

    private fun setTorchIntensity(context: Context, intensity: Double) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val cameraManager = getCameraManager(context)
            val cameraId = getCameraId(context)
            if (cameraId.isNotEmpty()) {
                val maxLevel = getMaxTorchIntensity(context)
                val level = (intensity * maxLevel).toInt().coerceIn(1, maxLevel)
                cameraManager.turnOnTorchWithStrengthLevel(cameraId, level)
                torchOn = true
            }
        } else {
            // Android 13 未満は ON/OFF のみ
            if (intensity > 0.0) {
                turnOnTorch(context)
            } else {
                turnOffTorch(context)
            }
        }
    }

    private fun getMaxTorchIntensity(context: Context): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            try {
                val cameraManager = getCameraManager(context)
                val cameraId = getCameraId(context)
                if (cameraId.isNotEmpty()) {
                    val characteristics = cameraManager.getCameraCharacteristics(cameraId)
                    characteristics.get(
                        android.hardware.camera2.CameraCharacteristics.FLASH_INFO_AVAILABLE
                    )
                    5 // Default torch levels for Android 13+
                } else {
                    1
                }
            } catch (e: Exception) {
                1
            }
        } else {
            1
        }
    }
}
