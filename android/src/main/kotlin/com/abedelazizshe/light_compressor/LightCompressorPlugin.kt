package com.abedelazizshe.light_compressor

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.abedelazizshe.lightcompressorlibrary.CompressionListener
import com.abedelazizshe.lightcompressorlibrary.VideoCompressor
import com.abedelazizshe.lightcompressorlibrary.VideoQuality
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** LightCompressorPlugin */
class LightCompressorPlugin : FlutterPlugin, MethodCallHandler,
        EventChannel.StreamHandler, ActivityAware {

    companion object {
        const val CHANNEL = "light_compressor"
        const val STREAM = "compression/stream"
    }

    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null
    private val gson = Gson()
    private lateinit var applicationContext: Context
    private lateinit var activity: Activity

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.applicationContext = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, STREAM)
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "startCompression" -> {
                val path: String = call.argument<String>("path")!!
                val destinationPath: String = call.argument<String>("destinationPath")!!
                val isMinBitRateEnabled: Boolean = call.argument<Boolean>("isMinBitRateEnabled")!!
                val keepOriginalResolution: Boolean = call.argument<Boolean>("keepOriginalResolution")!!

                val quality: VideoQuality = when (call.argument<String>("videoQuality")!!) {
                    "very_low" -> VideoQuality.VERY_LOW
                    "low" -> VideoQuality.LOW
                    "medium" -> VideoQuality.MEDIUM
                    "high" -> VideoQuality.HIGH
                    "very_high" -> VideoQuality.VERY_HIGH
                    else -> VideoQuality.MEDIUM
                }

                if (Build.VERSION.SDK_INT >= 23) {
                    val permissions = arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE)
                    if (!hasPermissions(applicationContext, permissions)) {
                        ActivityCompat.requestPermissions(activity, permissions, 1)
                        compressVideo(path, destinationPath, result, quality, isMinBitRateEnabled, keepOriginalResolution)
                    } else {
                        compressVideo(path, destinationPath, result, quality, isMinBitRateEnabled, keepOriginalResolution)
                    }
                } else {
                    compressVideo(path, destinationPath, result, quality, isMinBitRateEnabled, keepOriginalResolution)
                }
            }
            "cancelCompression" -> {
                VideoCompressor.cancel()
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun compressVideo(
            path: String,
            destinationPath: String,
            result: Result,
            quality: VideoQuality,
            isMinBitRateEnabled: Boolean,
            keepOriginalResolution: Boolean,
    ) {
        VideoCompressor.start(
                srcPath = path,
                destPath = destinationPath,
                listener = object : CompressionListener {
                    override fun onProgress(percent: Float) {
                        Handler(Looper.getMainLooper()).post {
                            eventSink?.success(percent)
                        }
                    }

                    override fun onStart() {}

                    override fun onSuccess() {
                        result.success(gson.toJson(buildResponseBody("onSuccess", destinationPath)))
                    }

                    override fun onFailure(failureMessage: String) {
                        result.success(gson.toJson(buildResponseBody("onFailure", failureMessage)))
                    }

                    override fun onCancelled() {
                        Handler(Looper.getMainLooper()).post {
                            result.success(gson.toJson(buildResponseBody("onCancelled", true)))
                        }
                    }
                },
                quality = quality,
                isMinBitRateEnabled = isMinBitRateEnabled,
                keepOriginalResolution = keepOriginalResolution,
        )
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun buildResponseBody(tag: String, response: Any): Map<String, Any> = mapOf(tag to response)

    private fun hasPermissions(context: Context?, permissions: Array<String>): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && context != null) {
            for (permission in permissions) {
                if (ContextCompat.checkSelfPermission(context, permission) != PackageManager.PERMISSION_GRANTED) {
                    return false
                }
            }
        }
        return true
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this.activity = binding.activity
    }

    override fun onDetachedFromActivity() {}
}
