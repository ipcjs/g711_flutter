import 'dart:developer';
import 'package:async/async.dart'
    show StreamSinkExtensions, StreamSinkTransformer;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';

import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:g711_flutter/g711_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  NativeG711Codec g711 = NativeG711Codec();
  FlutterSoundPlayer? _player;
  FlutterSoundRecorder? _recorder;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _player = FlutterSoundPlayer()..openAudioSession();
    _recorder = FlutterSoundRecorder()..openAudioSession();
  }

  @override
  void dispose() {
    _player?.closeAudioSession();
    _recorder?.closeAudioSession();
    super.dispose();
  }

  void _test() async {
    if (!await Permission.microphone.request().isGranted) {
      return;
    }
    if (_player?.isPlaying == true) {
      await _player?.stopPlayer();
      await _recorder?.stopRecorder();
    } else {
      await _player?.startPlayerFromStream();
      _recorder?.startRecorder(
        codec: Codec.pcm16,
        audioSource: AudioSource.voice_communication,
        toStream:
            _player?.foodSink?.transform(StreamSinkTransformer.fromHandlers(
          handleData: (food, sink) {
            if (food is FoodData && food.data != null) {
              final ulaw = g711.pcm16ToUlaw(food.data!);
              final pcm16 = g711.ulawToPcm16(ulaw);
              // assert(food.data == pcm16);
              log('${food.data}\n$pcm16');
              sink.add(FoodData(pcm16));
            }
          },
        )),
      );
    }
    setState(() {});
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await NativeG711Codec.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Text(
                'Running on: $_platformVersion\n${native_add(1, 2) + native_add_func(3, 4)}'),
            OutlinedButton(
              onPressed: _test,
              child: Text(_player?.isPlaying == true ? 'stop' : 'play'),
            ),
          ],
        ),
      ),
    );
  }
}
