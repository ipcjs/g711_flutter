import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';

import 'g711_codec.dart';
import 'g711_codec_legacy.dart';

final DynamicLibrary _g711 = Platform.isAndroid
    ? DynamicLibrary.open('libg711.so')
    : DynamicLibrary.process();

final int Function(int x, int y) native_add = _g711
    .lookup<NativeFunction<Int32 Function(Int32, Int32)>>('native_add')
    .asFunction();

final native_add_func = _g711.lookupFunction<Int32 Function(Int32, Int32),
    int Function(int x, int y)>('native_add');

final _pcm16_ulaw_tableinit = _g711
    .lookupFunction<Void Function(), void Function()>('pcm16_ulaw_tableinit');

final _ulaw_pcm16_tableinit = _g711
    .lookupFunction<Void Function(), void Function()>('ulaw_pcm16_tableinit');

final _ulaw_to_pcm16 = _g711.lookupFunction<
    Void Function(Int32, Pointer<Uint8>, Pointer<Uint8>),
    void Function(int, Pointer<Uint8>, Pointer<Uint8>)>('ulaw_to_pcm16');
final _pcm16_to_ulaw = _g711.lookupFunction<
    Void Function(Int32, Pointer<Uint8>, Pointer<Uint8>),
    void Function(int, Pointer<Uint8>, Pointer<Uint8>)>('pcm16_to_ulaw');

class NativeG711uCodec extends IG711Codec with LegacyG711uCodecMixin {
  static var _initiated = false;

  static void forcePreloadTable() {
    _pcm16_ulaw_tableinit();
    _ulaw_pcm16_tableinit();
  }

  NativeG711uCodec() {
    if (!_initiated) {
      _initiated = true;
      forcePreloadTable();
    }
  }

  @override
  Uint8List encode(Uint8List pcm) {
    final inSize = pcm.length;
    final outSize = inSize ~/ 2;
    final inArray = calloc<Uint8>(inSize);
    final outArray = calloc<Uint8>(outSize);
    inArray.asTypedList(pcm.length).setAll(0, pcm);

    _pcm16_to_ulaw(inSize, inArray, outArray);

    final out = Uint8List.fromList(outArray.asTypedList(outSize));
    calloc.free(outArray);
    calloc.free(inArray);
    return out;
  }

  @override
  Uint8List decode(Uint8List g711) {
    final inSize = g711.length;
    final outSize = inSize * 2;
    final inArray = calloc<Uint8>(inSize);
    final outArray = calloc<Uint8>(outSize);
    inArray.asTypedList(g711.length).setAll(0, g711);

    _ulaw_to_pcm16(inSize, inArray, outArray);

    final out = Uint8List.fromList(outArray.asTypedList(outSize));
    calloc.free(outArray);
    calloc.free(inArray);
    return out;
  }

  static const MethodChannel _channel = MethodChannel('g711_flutter');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
