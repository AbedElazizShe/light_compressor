<p align="left">
<a href="https://pub.dev/packages/light_compressor"><img src="https://img.shields.io/pub/v/light_compressor.svg" alt="Pub"></a>
</p>


# light_compressor
A powerful and easy-to-use video compression plugin for Flutter built based on [LightCompressor](https://github.com/AbedElazizShe/LightCompressor/tree/master/lightcompressor) library for Android and [LightCompressor_iOS](https://github.com/AbedElazizShe/LightCompressor_iOS) library for iOS. This plugin generates a compressed MP4 video with a modified width, height, and bitrate.

The general idea of how the library works is that, extreme high bitrate is reduced while maintaining a good video quality resulting in a smaller size.

## How it works
When the video file is called to be compressed, the library checks if the user wants to set a min bitrate to avoid compressing low resolution videos. This becomes handy if you don’t want the video to be compressed every time it is to be processed to avoid having very bad quality after multiple rounds of compression. The minimum bitrate set is 2mbps.

You can pass one of a 5 video qualities; `very_high`, `high`, `medium`, `low` OR `very_low` and the plugin will handle generating the right bitrate value for the output video.

## Demo

![Android-demo](https://github.com/AbedElazizShe/light_compressor/blob/master/pictures/android.gif)

## Installation

First, add `light_compressor` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

### iOS

Add the following to your _Info.plist_ file, located in `<project root>/ios/Runner/Info.plist`:

```
<key>NSPhotoLibraryUsageDescription</key>
<string>${PRODUCT_NAME} library Usage</string>
```

### Android

Add the following permissions in AndroidManifest.xml:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

Include this in your Project-level build.gradle file:
```groovy
allprojects {
    repositories {
        .
        .
        .
        maven { url 'https://jitpack.io' }
    }
}
```

Include this in your Module-level build.gradle file:

```groovy
implementation 'com.github.AbedElazizShe:LightCompressor:0.7.7'
```

And since the library depends on Kotlin version `1.4.10`, please ensure that `1.4.10` is the minimum kotlin version in your project by changing `ext.kotlin_version` in your Project-level build.gradle file.

## Usage

In order to start compression, just call [LightCompressor.compressVideo()] and pass the following parameters;
1) `path`: the path of the provided video file to be compressed - **required**.
2) `destinationPath`: the path where the output compressed video file should be saved - **required**.
3) `videoQuality`: to allow choosing a video quality that can be `VideoQuality.very_low`, `VideoQuality.low`, `VideoQuality.medium`, `VideoQuality.high`, or `VideoQuality.very_high` - **required**.
4) `isMinBitRateEnabled`: to determine if the checking for a minimum bitrate threshold before compression is enabled or not. The default value is `true` - **optional**.
5) `keepOriginalResolution`: to keep the original video height and width when compressing. This default value is `false` - **optional**.

```dart
final Map<String, dynamic> response = await LightCompressor.compressVideo(
  path: _sourcePath,
  destinationPath: _destinationPath,
  videoQuality: VideoQuality.medium,
  isMinBitRateEnabled: false,
  keepOriginalResolution: false);
```

The plugin allows cancelling the compression by calling;

```dart
LightCompressor.cancelCompression();
```

Result response can be one of the following;
- **onSuccess**: if the compression succeeded and it returns the output path if needed.
- **onFailure**: if the compression failed in which a failure message is returned.
- **onCancelled**: if `cancelCompression()` was called.

```dart
   if (response['onSuccess'] != null) {
      final String outputFile = response['onSuccess'];
      // use the file

    } else if (response['onFailure'] != null) {
      // failure message
      print(response['onFailure']);

    } else if (response['onCancelled'] != null) {
      print(response['onCancelled']);
    }
```

In order to get the progress of compression while the video is being compressed the following to receive a broadcast stream;

```dart
LightCompressor.progressStream
```

You can use a stream builder for example as follows;

```dart
StreamBuilder<dynamic>(
    stream: LightCompressor.progressStream.receiveBroadcastStream(),
    builder: (BuildContext context,  AsyncSnapshot<dynamic> snapshot) {
       if (snapshot.data != null && snapshot.data > 0) {
        return Column(
          children: <Widget>[
           LinearProgressIndicator(
            minHeight: 8,
            value: snapshot.data / 100,
           ),
           const SizedBox(height: 8),
           Text(
            '${snapshot.data.toStringAsFixed(0)}%',
             style: const TextStyle(fontSize: 20),
           )
         ],
       );
    }
    return const SizedBox.shrink();
  },
),
```

For more information on how to use the plugin, refer to the [sample app](https://github.com/AbedElazizShe/light_compressor/blob/master/example/lib/main.dart)

## Compatibility
Minimum Android SDK: the plugin requires a minimum API level of 21.

The minimum iOS version supported is 11.

## Dart Versions

- Dart 2: >= 2.7.0
- Flutter: >=1.20.0

## Maintainers

- [AbedElaziz Shehadeh](https://github.com/AbedElazizShe)