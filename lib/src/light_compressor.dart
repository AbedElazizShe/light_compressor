import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:light_compressor/light_compressor.dart';

/// The allowed video quality to pass for compression
enum VideoQuality {
  /// Very low quality
  very_low,

  /// Low quality
  low,

  /// Medium quality
  medium,

  /// High quality
  high,

  /// Very high quality
  very_high,
}

/// Light compressor that perform video compression and cancel compression
class LightCompressor {
  /// Singleton instance of LightCompressor
  factory LightCompressor() => _instance;

  LightCompressor._internal();

  static final LightCompressor _instance = LightCompressor._internal();

  static const MethodChannel _channel = MethodChannel('light_compressor');

  /// A stream to listen to video compression progress
  static const EventChannel _progressStream =
      EventChannel('compression/stream');

  Stream<double>? _onProgressUpdated;

  /// Fires whenever the uploading progress changes.
  Stream<double> get onProgressUpdated {
    _onProgressUpdated ??= _progressStream
        .receiveBroadcastStream()
        .map<double>((dynamic result) => result != null ? result : 0);
    return _onProgressUpdated!;
  }

  /// This function compresses a given [path] video file and writes the
  /// compressed video file in app-specific storage or external storage in
  /// android and in gallery in ios.
  ///
  /// The required parameters are;
  /// * [path] is path of the provided video file to be compressed.
  /// * [videoQuality] to allow choosing a video quality that can be
  /// [VideoQuality.very_low], [VideoQuality.low], [VideoQuality.medium],
  /// [VideoQuality.high], and [VideoQuality.very_high].
  /// * [android] which contains configurations specific to Android. These
  /// configs are:
  ///   - saveAt: The location where the video should be saved externally.
  ///     This value will be ignored if isExternal is `false`.
  ///   - isSharedStorage: Whether to save the output video in external or internal
  ///     storage.
  /// * [ios] which contains configurations specific to iOS;
  ///   - saveInGallery: To decide saving the video in gallery or not. This
  ///     defaults to `true`.
  /// * [video] contains configurations of the output video:
  ///   - videoName: The name of the output video file. This value is required.
  ///   - keepOriginalResolution: to keep the original video height and width when compressing.
  ///   - videoBitrateInMbps: a custom bitrate for the video
  ///   - videoHeight: a custom height for the video.
  ///   - videoWidth: a custom width for the video.
  /// The optional parameters are;
  /// * [isMinBitrateCheckEnabled] to determine if the checking for a minimum bitrate
  /// threshold before compression is enabled or not. This defaults to `true`.
  /// * [disableAudio] to give the option to generate a video with no audio.
  /// This defaults to `false`
  Future<Result> compressVideo({
    required String path,
    required VideoQuality videoQuality,
    required AndroidConfig android,
    required IOSConfig ios,
    required Video video,
    bool? disableAudio = false,
    bool isMinBitrateCheckEnabled = true,
  }) async {
    final Map<String, dynamic> response = jsonDecode(await _channel
        .invokeMethod<dynamic>('startCompression', <String, dynamic>{
      'path': path,
      'videoQuality': videoQuality.toString().split('.').last,
      'isSharedStorage': android.isSharedStorage,
      'saveAt': android.saveAt.name,
      'disableAudio': disableAudio,
      'keepOriginalResolution': video.keepOriginalResolution,
      'isMinBitrateCheckEnabled': isMinBitrateCheckEnabled,
      'videoBitrateInMbps': video.videoBitrateInMbps,
      'videoHeight': video.videoHeight,
      'videoWidth': video.videoWidth,
      'videoName': video.videoName,
      'saveInGallery': ios.saveInGallery,
    }));

    if (response['onSuccess'] != null) {
      return OnSuccess(response['onSuccess']);
    } else if (response['onFailure'] != null) {
      return OnFailure(response['onFailure']);
    } else if (response['onCancelled'] != null) {
      return OnCancelled(isCancelled: response['onCancelled']);
    } else {
      return const OnFailure('Something went wrong');
    }
  }

  /// Call this function to cancel video compression process.
  Future<Map<String, dynamic>?> cancelCompression() async =>
      jsonDecode(await _channel.invokeMethod<dynamic>('cancelCompression'));
}
