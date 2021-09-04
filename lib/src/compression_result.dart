/// Compression is completed successfully state.
class OnSuccess {
  /// OnSuccess state.
  const OnSuccess(this.destinationPath);

  /// The path of the compressed video.
  final String destinationPath;
}

/// Compression failed state.
class OnFailure {
  /// OnFailure state.
  const OnFailure(this.message);

  /// Failure message.
  final String message;
}

/// Compression was cancelled state.
class OnCancelled {
  /// OnCancelled state.
  const OnCancelled(this.isCancelled);

  /// Determines whether the cancellation is done or not.
  final bool isCancelled;
}
