/// Android specific configurations.
class AndroidConfig {
  AndroidConfig({
    this.isSharedStorage = true,
    this.saveAt = SaveAt.Movies,
  });

  /// https://developer.android.com/training/data-storage
  /// Whether to save the output video in shared or app specific storage.
  final bool isSharedStorage;

  /// The location where the video should be saved externally. This value will
  /// be ignored if [isSharedStorage] is `false`.
  final SaveAt saveAt;
}

enum SaveAt { Pictures, Movies, Downloads }
