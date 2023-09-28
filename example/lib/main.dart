import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:light_compressor/light_compressor.dart';
import 'package:light_compressor_example/utils/file_utils.dart';
import 'package:light_compressor_example/video_player.dart';

void main() {
  runApp(MyApp());
}

/// A widget that uses LightCompressor library to compress videos
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String _desFile;
  String? _displayedFile;
  late int _duration;
  String? _failureMessage;
  String? _filePath;
  bool _isVideoCompressed = false;

  final LightCompressor _lightCompressor = LightCompressor();

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          primaryColor: const Color(0xFF344772),
          primaryColorDark: const Color(0xFF002046),
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Compressor Sample'),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onPressed: () => _lightCompressor.cancelCompression(),
              )
            ],
          ),
          body: Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (_filePath != null)
                  Text(
                    'Original size: ${_getVideoSize(file: File(_filePath!))}',
                    style: const TextStyle(fontSize: 16),
                  ),
                const SizedBox(height: 8),
                if (_isVideoCompressed)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Size after compression: ${_getVideoSize(file: File(_desFile))}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Duration: $_duration seconds',
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                Visibility(
                  visible: !_isVideoCompressed,
                  child: StreamBuilder<double>(
                    stream: _lightCompressor.onProgressUpdated,
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
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
                ),
                const SizedBox(height: 24),
                if (_displayedFile != null)
                  Builder(
                    builder: (BuildContext context) => Container(
                      alignment: Alignment.center,
                      child: OutlinedButton(
                          onPressed: () => Navigator.push<dynamic>(
                                context,
                                MaterialPageRoute<dynamic>(
                                  builder: (_) => VideoPlayerScreen(_desFile),
                                ),
                              ),
                          child: const Text('Play Video')),
                    ),
                  ),
                Text(
                  _failureMessage ?? '',
                )
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _pickVideo(),
            label: const Text('Pick Video'),
            icon: const Icon(Icons.video_library),
            backgroundColor: const Color(0xFFA52A2A),
          ),
        ),
      );

  // Pick a video form device's storage
  Future<void> _pickVideo() async {
    _isVideoCompressed = false;

    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    final PlatformFile? file = result?.files.first;

    if (file == null) {
      return;
    }

    _filePath = file.path;

    setState(() {
      _failureMessage = null;
    });

    final String videoName =
        'MyVideo-${DateTime.now().millisecondsSinceEpoch}.mp4';

    final Stopwatch stopwatch = Stopwatch()..start();
    final Result response = await _lightCompressor.compressVideo(
      path: _filePath!,
      videoQuality: VideoQuality.medium,
      isMinBitrateCheckEnabled: false,
      video: Video(videoName: videoName),
      android: AndroidConfig(isSharedStorage: true, saveAt: SaveAt.Movies),
      ios: IOSConfig(saveInGallery: false),
    );

    stopwatch.stop();
    final Duration duration =
        Duration(milliseconds: stopwatch.elapsedMilliseconds);
    _duration = duration.inSeconds;

    if (response is OnSuccess) {
      setState(() {
        _desFile = response.destinationPath;
        _displayedFile = _desFile;
        _isVideoCompressed = true;
      });
    } else if (response is OnFailure) {
      setState(() {
        _failureMessage = response.message;
      });
    } else if (response is OnCancelled) {
      print(response.isCancelled);
    }
  }
}

String _getVideoSize({required File file}) => formatBytes(file.lengthSync(), 2);
