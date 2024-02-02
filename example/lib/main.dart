import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:g711_flutter/g711_flutter.dart';
import 'package:g711_flutter_example/sound_button.dart';

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
  late NativeG711Codec g711 = NativeG711Codec.g711u();

  @override
  void initState() {
    super.initState();
    initPlatformState();
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
            const SoundButton(),
            OutlinedButton(
              onPressed: () {
                final nativeG711u = NativeG711Codec.g711u();
                final nativeG711a = NativeG711Codec.g711a();
                final dartG711u = DartG711Codec.g711u();
                final dartG711a = DartG711Codec.g711a();
                final pcm16 = Uint8List.sublistView(
                    Int16List.fromList([1, -1, 0xffff, 0, 0x7fff, 0x8000]));
                final ulaw1 = nativeG711u.encode(pcm16);
                final ulaw2 = dartG711u.encode(pcm16);
                final pcm1 = nativeG711u.decode(ulaw1);
                final pcm2 = dartG711u.decode(ulaw2);
                final alaw1 = nativeG711a.encode(pcm16);
                final alaw2 = dartG711a.encode(pcm16);
                final pcm11 = nativeG711a.decode(alaw1);
                final pcm12 = dartG711a.decode(alaw2);

                log('''
                  pcm16: $pcm16
                  ulaw1: $ulaw1
                  ulaw2: $ulaw2
                  pcm1: $pcm1
                  pcm2: $pcm2
                  alaw1: $alaw1
                  alaw2: $alaw2
                  pcm11: $pcm11
                  pcm12: $pcm12
                ''');
              },
              child: const Text('check result'),
            ),
            OutlinedButton(
              onPressed: () {
                final w = Stopwatch()..start();

                final g1 = NativeG711Codec.g711u();
                final g2 = DartG711Codec.g711u();
                w.printElapsed('native.preload', () => g1.forcePreloadTable());
                w.printElapsed('dart  .preload', () => g2.forcePreloadTable());
                final random = math.Random();
                final pcm16 = Uint8List.fromList(List.generate(
                    1024 * 1024, (index) => random.nextInt(0xff)));

                final ulaw1 =
                    w.printElapsed('native.encode', () => g1.encode(pcm16));
                final ulaw2 =
                    w.printElapsed('dart  .encode', () => g2.encode(pcm16));
                final pcm1 =
                    w.printElapsed('native.decode', () => g1.decode(ulaw1));
                final pcm2 =
                    w.printElapsed('dart  .decode', () => g2.decode(ulaw2));
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
