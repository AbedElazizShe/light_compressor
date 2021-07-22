import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:light_compressor/compression_result.dart';

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
  /// compressed video file at [destinationPath].
  ///
  /// The required parameters are;
  /// * [path] is path of the provided video file to be compressed.
  /// * [destinationPath] the path where the output compressed video file should
  /// be saved.
  /// * [videoQuality] to allow choosing a video quality that can be
  /// [VideoQuality.very_low], [VideoQuality.low], [VideoQuality.medium],
  /// [VideoQuality.high], and [VideoQuality.very_high].
  ///
  /// The optional parameters are;
  /// * [isMinBitRateEnabled] to determine if the checking for a minimum bitrate
  /// threshold before compression is enabled or not. This defaults to `true`.
  /// * [keepOriginalResolution] to keep the original video height and width when
  /// compressing. This defaults to `false`.
  /// * [iosSaveInGallery] to determine if the video should be saved in iOS
  /// Gallery or not.
  Future<dynamic> compressVideo({
    required String path,
    required String destinationPath,
    required VideoQuality videoQuality,
    bool isMinBitRateEnabled = true,
    bool keepOriginalResolution = false,
    bool iosSaveInGallery = true,
  }) async {
    final Map<String, dynamic> response = jsonDecode(await _channel
        .invokeMethod<dynamic>('startCompression', <String, dynamic>{
      'path': path,
      'destinationPath': destinationPath,
      'videoQuality': videoQuality.toString().split('.').last,
      'isMinBitRateEnabled': isMinBitRateEnabled,
      'keepOriginalResolution': keepOriginalResolution,
      'saveInGallery': iosSaveInGallery,
    }));

    if (response['onSuccess'] != null) {
      return OnSuccess(response['onSuccess']);
    } else if (response['onFailure'] != null) {
      return OnFailure(response['onFailure']);
    } else if (response['onCancelled'] != null) {
      return OnCancelled(response['onCancelled']);
    } else {
      return const OnFailure('Something went wrong');
    }
  }

  /// Call this function to cancel video compression process.
  static Future<Map<String, dynamic>?> cancelCompression() async =>
      jsonDecode(await _channel.invokeMethod<dynamic>('cancelCompression'));
}
