/// Video Configurations.
class Video {
  Video({
    required this.videoName,
    this.keepOriginalResolution = false,
    this.videoBitrateInMbps,
    this.videoHeight,
    this.videoWidth,
  });

  /// The name of the output video file. This value is required.
  final String videoName;

  /// To keep the original video height and width when compressing.
  final bool? keepOriginalResolution;

  /// A custom bitrate for the video.
  final int? videoBitrateInMbps;

  /// A custom height for the video.
  final int? videoHeight;

  /// A custom width for the video.
  final int? videoWidth;
}
