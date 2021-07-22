## 1.1.0
**Breaking**: LightCompressor is now following Singleton pattern, call the methods using `LightCompressor()`
**Breaking**: `compressVideo()` returns a `dynamic` response, to check for success, failure, or cancellation; use `is OnSuccess`, `is OnFailure`, and `is onCancelled` respectively. Refer to the sample app for more details.
**Breaking**: Progress change stream has been renamed and could be called now as `LightCompressor().onProgressUpdated`
Bumped Android's LightCompressor library to version 0.9.4.
Several bugs fixes and speed improvements.
Enabled the usage of software encoders if hardware encoders don't exist, such as in certain emulators.

## 1.0.3
Fixed iOS crash when the video has no audio.
Allowed passing `iosSaveInGallery (true/false)` to control saving the compressed video in iOS.

## 1.0.2
Updated Android dependency.
Minor code refactor and cleanup

## 1.0.1
Bugs fixes.

## 1.0.0
Migrated to null safety.

## 0.1.0
Bugs fixes.

## 0.0.7
Fixed a crash at iOS the video has no sound.
Replaced image_picker with file_picker for the sample app due to this open issue https://github.com/flutter/flutter/issues/52419

## 0.0.6
Updated dependencies.
Fixed a crash on iOS.

## 0.0.5

Update LightCompressor library for Android with bugs fixes.
Added `very_low` video quality.
Fixed the project to work in iOS 14.

## 0.0.4

Updated documentation.
Code cleanup.

## 0.0.3

Updated details about the plugin.

## 0.0.2

Updated documentation related to using the plugin for Android.

## 0.0.1

Initial version of the plugin.

- Includes the ability to compress videos and works in both Android and iOS.
