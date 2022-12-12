/// Android specific configurations.
class AndroidConfig {
  AndroidConfig({
    this.isExternal = true,
    this.saveAt = SaveAt.Movies,
  });

  /// Whether to save the output video in external or internal storage.
  final bool isExternal;

  /// The location where the video should be saved externally. This value will
  /// be ignored if [isExternal] is `false`.
  final SaveAt saveAt;
}

enum SaveAt { Pictures, Movies, DCIM }
