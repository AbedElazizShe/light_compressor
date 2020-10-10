import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  static const MethodChannel _channel = MethodChannel('light_compressor');

  /// A stream to listen to video compression progress
  static const EventChannel progressStream = EventChannel('compression/stream');

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
  static Future<Map<String, dynamic>> compressVideo({
    @required String path,
    @required String destinationPath,
    @required VideoQuality videoQuality,
    bool isMinBitRateEnabled = true,
    bool keepOriginalResolution = false,
  }) async =>
      // ignore: always_specify_types
      jsonDecode(await _channel.invokeMethod('startCompression', {
        'path': path,
        'destinationPath': destinationPath,
        'videoQuality': videoQuality.toString().split('.').last,
        'isMinBitRateEnabled': isMinBitRateEnabled,
        'keepOriginalResolution': keepOriginalResolution,
      }));

  /// Call this function to cancel video compression process.
  static Future<Map<String, dynamic>> cancelCompression() async =>
      jsonDecode(await _channel.invokeMethod('cancelCompression'));
}
