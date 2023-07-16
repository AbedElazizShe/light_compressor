package com.abedelazizshe.light_compressor

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.abedelazizshe.lightcompressorlibrary.CompressionListener
import com.abedelazizshe.lightcompressorlibrary.VideoCompressor
import com.abedelazizshe.lightcompressorlibrary.VideoQuality
import com.abedelazizshe.lightcompressorlibrary.config.*
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File

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

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.applicationContext = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)

        eventChannel =
            EventChannel(flutterPluginBinding.binaryMessenger, STREAM)
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "startCompression" -> {
                val path: String = call.argument<String>("path")!!
                val isMinBitrateCheckEnabled: Boolean =
                    call.argument<Boolean>("isMinBitrateCheckEnabled")!!
                val isSharedStorage: Boolean = call.argument<Boolean>("isSharedStorage")!!
                val disableAudio: Boolean = call.argument<Boolean>("disableAudio")!!
                val keepOriginalResolution: Boolean =
                    call.argument<Boolean>("keepOriginalResolution")!!
                val videoBitrateInMbps: Int? = call.argument<Int?>("videoBitrateInMbps")
                val videoHeight: Int? = call.argument<Int?>("videoHeight")
                val videoWidth: Int? = call.argument<Int?>("videoWidth")
                val saveAt: String = call.argument<String>("saveAt")!!
                val videoName: String = call.argument<String>("videoName")!!

                val quality: VideoQuality =
                    when (call.argument<String>("videoQuality")!!) {
                        "very_low" -> VideoQuality.VERY_LOW
                        "low" -> VideoQuality.LOW
                        "medium" -> VideoQuality.MEDIUM
                        "high" -> VideoQuality.HIGH
                        "very_high" -> VideoQuality.VERY_HIGH
                        else -> VideoQuality.MEDIUM
                    }

                if (isSharedStorage) {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        android33AndAboveSharedStorageCompression(
                            path,
                            result,
                            quality,
                            isMinBitrateCheckEnabled,
                            videoBitrateInMbps,
                            disableAudio,
                            keepOriginalResolution,
                            videoHeight,
                            videoWidth,
                            saveAt,
                            videoName
                        )
                    } else {
                        android24AndAboveSharedStorageCompression(
                            path,
                            result,
                            quality,
                            isMinBitrateCheckEnabled,
                            videoBitrateInMbps,
                            disableAudio,
                            keepOriginalResolution,
                            videoHeight,
                            videoWidth,
                            saveAt,
                            videoName
                        )
                    }
                } else {
                    compressVideo(
                        path, result, quality, false, isMinBitrateCheckEnabled,
                        videoBitrateInMbps, disableAudio, keepOriginalResolution, videoHeight,
                        videoWidth, saveAt, videoName
                    )
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
        result: Result,
        quality: VideoQuality,
        isSharedStorage: Boolean,
        isMinBitrateCheckEnabled: Boolean,
        videoBitrateInMbps: Int?,
        disableAudio: Boolean,
        keepOriginalResolution: Boolean,
        videoHeight: Int?,
        videoWidth: Int?,
        saveAt: String,
        videoName: String,
    ) {

        VideoCompressor.start(
            context = applicationContext,
            uris = listOf(Uri.fromFile(File(path))),
            isStreamable = false,
            sharedStorageConfiguration = if (isSharedStorage) SharedStorageConfiguration(
                saveAt = when (saveAt) {
                    "Downloads" -> SaveLocation.downloads
                    "Pictures" -> SaveLocation.pictures
                    "Movies" -> SaveLocation.movies
                    else -> SaveLocation.movies
                }
            ) else null,
            appSpecificStorageConfiguration = if (!isSharedStorage) AppSpecificStorageConfiguration(
            ) else null,
            listener = object : CompressionListener {
                override fun onProgress(index: Int, percent: Float) {
                    Handler(Looper.getMainLooper()).post {
                        eventSink?.success(percent)
                    }
                }

                override fun onStart(index: Int) {}

                override fun onSuccess(index: Int, size: Long, path: String?) {
                    result.success(
                        gson.toJson(
                            buildResponseBody(
                                "onSuccess",
                                path!!
                            )
                        )
                    )
                }

                override fun onFailure(index: Int, failureMessage: String) {
                    result.success(
                        gson.toJson(
                            buildResponseBody(
                                "onFailure",
                                failureMessage
                            )
                        )
                    )
                }

                override fun onCancelled(index: Int) {
                    Handler(Looper.getMainLooper()).post {
                        result.success(
                            gson.toJson(
                                buildResponseBody(
                                    "onCancelled",
                                    true
                                )
                            )
                        )
                    }
                }
            },
            configureWith = Configuration(
                quality = quality,
                isMinBitrateCheckEnabled = isMinBitrateCheckEnabled,
                videoBitrateInMbps = videoBitrateInMbps,
                disableAudio = disableAudio,
                keepOriginalResolution = keepOriginalResolution,
                videoHeight = videoHeight?.toDouble(),
                videoWidth = videoWidth?.toDouble(),
                videoNames = listOf(videoName),
            )

        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun buildResponseBody(
        tag: String,
        response: Any
    ): Map<String, Any> = mapOf(tag to response)

    @RequiresApi(Build.VERSION_CODES.TIRAMISU)
    private fun android33AndAboveSharedStorageCompression(
        path: String,
        result: Result,
        quality: VideoQuality,
        isMinBitrateCheckEnabled: Boolean,
        videoBitrateInMbps: Int?,
        disableAudio: Boolean,
        keepOriginalResolution: Boolean,
        videoHeight: Int?,
        videoWidth: Int?,
        saveAt: String,
        videoName: String
    ) {
        if (ContextCompat.checkSelfPermission(
                activity,
                Manifest.permission.READ_MEDIA_VIDEO,
            ) != PackageManager.PERMISSION_GRANTED
        ) {

            if (!ActivityCompat.shouldShowRequestPermissionRationale(
                    activity,
                    Manifest.permission.READ_MEDIA_VIDEO
                )
            ) {
                ActivityCompat.requestPermissions(
                    activity,
                    arrayOf(Manifest.permission.READ_MEDIA_VIDEO),
                    2
                )

                compressVideo(
                    path,
                    result,
                    quality,
                    true,
                    isMinBitrateCheckEnabled,
                    videoBitrateInMbps,
                    disableAudio,
                    keepOriginalResolution,
                    videoHeight,
                    videoWidth,
                    saveAt,
                    videoName
                )
            }
        }
    }

    private fun android24AndAboveSharedStorageCompression(
        path: String,
        result: Result,
        quality: VideoQuality,
        isMinBitrateCheckEnabled: Boolean,
        videoBitrateInMbps: Int?,
        disableAudio: Boolean,
        keepOriginalResolution: Boolean,
        videoHeight: Int?,
        videoWidth: Int?,
        saveAt: String,
        videoName: String
    ) {
        val permissions = arrayOf(
            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE
        )
        if (!hasPermissions(applicationContext, permissions)) {
            ActivityCompat.requestPermissions(
                activity,
                permissions,
                1
            )
            compressVideo(
                path, result, quality, true, isMinBitrateCheckEnabled,
                videoBitrateInMbps, disableAudio, keepOriginalResolution, videoHeight,
                videoWidth, saveAt, videoName
            )
        }
    }

    private fun hasPermissions(
        context: Context?,
        permissions: Array<String>
    ): Boolean {
        if (context != null) {
            for (permission in permissions) {
                if (ContextCompat.checkSelfPermission(
                        context,
                        permission
                    ) != PackageManager.PERMISSION_GRANTED
                ) {
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
