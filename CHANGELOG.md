# 2.2.0

**BREAKING**: cancelCompression() is not static anymore to make it easier to unit test.

macOS 10.15 and iOS 11 support, thanks to [starkdmi](https://github.com/starkdmi) in this [PR](https://github.com/AbedElazizShe/light_compressor/pull/40)

Bumped Android's LightCompressor library to version 1.3.2 which comes with bugs fixes.

# 2.1.0

**BREAKING**: Minimum supported Android API is 24.

Bumped Android's LightCompressor library to version 1.3.0.

# 2.0.1

**BREAKING**: `isExternal` was renamed to `isSharedStorage`

Bumped Android's LightCompressor library to version 1.2.3.

Bugs fixes

# 2.0.0

**BREAKING**: `frameRate` was removed and cannot be passed anymore.

**BREAKING**: `destinationPath` was removed and cannot be passed anymore.

**BREAKING**: It is required to pass Android configuration as `android`. In addition, `videoName` is required.

**BREAKING**: It is required to pass iOS configuration as `ios`. 

**BREAKING**: `iosSaveInGallery` was renamed to `saveInGallery` and should now be passed in `ios` configuration. 

**BREAKING**: It is required to pass video configuration as `video`

**BREAKING**: It is important to add run-time permissions for media access in Android. Refer to the documentation.

`disableAudio` can be passed now to generate a video without audio.

`keepOriginalResolution` was added to force keeping the video's original height and width.

Both `videoHeight` and `videoWidth` can be provided now.

Bumped Android's LightCompressor library to version 1.2.2.

Android Target SDK was increased to 33.

# 1.2.2

Bumped Android's LightCompressor library to version 1.0.0.
Fixed a crash in Android.
Fixed iOS app building issue.

# 1.2.1

Fixed an issue with optional frameRate value

# 1.2.0

**BREAKING**: Renamed isMinBitRateEnabled to isMinBitrateCheckEnabled
Passing frameRate value to the compressor is now allowed
Redefined the bitrate values for each of the Qualities
Compression speed is improved.
Bugs fixes related to codec profile and audio track.

# 1.1.1

Updated documentation.

# 1.1.0

**Breaking**: LightCompressor is now following Singleton pattern, call the methods using `LightCompressor()`

**Breaking**: `compressVideo()` returns a `dynamic` response, to check for success, failure, or cancellation; use `is OnSuccess`, `is OnFailure`, and `is onCancelled` respectively. Refer to the sample app for more details.

**Breaking**: Progress change stream has been renamed and could be called now as `LightCompressor().onProgressUpdated`

Bumped Android's LightCompressor library to version 0.9.4.

Several bugs fixes and speed improvements.

Enabled the usage of software encoders if hardware encoders don't exist, such as in certain emulators.

# 1.0.3

Fixed iOS crash when the video has no audio.
Allowed passing `iosSaveInGallery (true/false)` to control saving the compressed video in iOS.

# 1.0.2

Updated Android dependency.
Minor code refactor and cleanup

# 1.0.1

Bugs fixes.

# 1.0.0

Migrated to null safety.

# 0.1.0

Bugs fixes.

# 0.0.7

Fixed a crash at iOS the video has no sound.
Replaced image_picker with file_picker for the sample app due to this open issue https://github.com/flutter/flutter/issues/52419

# 0.0.6

Updated dependencies.
Fixed a crash on iOS.

# 0.0.5

Update LightCompressor library for Android with bugs fixes.
Added `very_low` video quality.
Fixed the project to work in iOS 14.

# 0.0.4

Updated documentation.
Code cleanup.

# 0.0.3

Updated details about the plugin.

# 0.0.2

Updated documentation related to using the plugin for Android.

# 0.0.1

Initial version of the plugin.

- Includes the ability to compress videos and works in both Android and iOS.
