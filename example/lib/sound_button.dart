import 'dart:developer';

import 'package:async/async.dart'
    show StreamSinkExtensions, StreamSinkTransformer;
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:g711_flutter/g711_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

/// Created by ipcjs on 2022/11/21.
class SoundButton extends StatefulWidget {
  const SoundButton({
    Key? key,
  }): super(key: key);

  @override
  State<SoundButton> createState() => _SoundButtonState();
}

class _SoundButtonState extends State<SoundButton> {
  late NativeG711Codec g711 = NativeG711Codec();
  FlutterSoundPlayer? _player;
  FlutterSoundRecorder? _recorder;

  @override
  void initState() {
    super.initState();
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


  @override
  Widget build(BuildContext context) {
   return OutlinedButton(
      onPressed: _test,
      child: Text(_player?.isPlaying == true ? 'stop' : 'play'),
    );
  }
}
