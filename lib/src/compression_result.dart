abstract class Result {}

/// Compression is completed successfully state.
class OnSuccess implements Result {
  /// OnSuccess state.
  const OnSuccess(this.destinationPath);

  /// The path of the compressed video.
  final String destinationPath;
}

/// Compression failed state.
class OnFailure implements Result {
  /// OnFailure state.
  const OnFailure(this.message);

  /// Failure message.
  final String message;
}

/// Compression was cancelled state.
class OnCancelled implements Result {
  /// OnCancelled state.
  const OnCancelled({required this.isCancelled});

  /// Determines whether the cancellation is done or not.
  final bool isCancelled;
}
