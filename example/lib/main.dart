import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:async/async.dart' show StreamSinkExtensions, StreamSinkTransformer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
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
        toStream: _player?.foodSink?.transform(StreamSinkTransformer.fromHandlers(
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
      platformVersion = await NativeG711Codec.platformVersion ?? 'Unknown platform version';
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
            Text('Running on: $_platformVersion\n${native_add(1, 2) + native_add_func(3, 4)}'),
            OutlinedButton(
              onPressed: _test,
              child: Text(_player?.isPlaying == true ? 'stop' : 'play'),
            ),
            OutlinedButton(
              onPressed: () {
                final g1 = NativeG711Codec();
                final g2 = DartG711Codec();
                final pcm16 = Uint8List.sublistView(Int16List.fromList([1, -1, 0xffff, 0, 0x7fff, 0x8000]));
                final ulaw1 = g1.pcm16ToUlaw(pcm16);
                final ulaw2 = g2.pcm16ToUlaw(pcm16);
                final pcm1 = g1.ulawToPcm16(ulaw1);
                final pcm2 = g2.ulawToPcm16(ulaw2);
                log('''
                  pcm16: $pcm16
                  ulaw1: $ulaw1
                  ulaw2: $ulaw2
                  pcm1: $pcm1
                  pcm2: $pcm2
                ''');
              },
              child: const Text('check result'),
            ),
            OutlinedButton(
              onPressed: () {
                final w = Stopwatch()..start();

                w.printElapsed('native.preload', () => NativeG711Codec.forcePreloadTable());
                w.printElapsed('dart  .preload', () => DartG711Codec.forcePreloadTable());

                final g1 = NativeG711Codec();
                final g2 = DartG711Codec();
                final random = math.Random();
                final pcm16 = Uint8List.fromList(List.generate(1024 * 1024, (index) => random.nextInt(0xff)));

                final ulaw1 = w.printElapsed('native.pcm16ToUlaw', () => g1.pcm16ToUlaw(pcm16));
                final ulaw2 = w.printElapsed('dart  .pcm16ToUlaw', () => g2.pcm16ToUlaw(pcm16));
                final pcm1 = w.printElapsed('native.ulawToPcm16', () => g1.ulawToPcm16(ulaw1));
                final pcm2 = w.printElapsed('dart  .ulawToPcm16', () => g2.ulawToPcm16(ulaw2));
              },
              child: const Text('performance test'),
            ),
          ],
        ),
      ),
    );
  }
}

extension StopwatchExt on Stopwatch {
  R printElapsed<R>(String tag, R Function() block, {printResult = false}) {
    reset();
    final result = block();
    final elapsed = this.elapsed;

    print('$tag: $elapsed ${printResult ? result : ''}');
    return result;
  }
}
