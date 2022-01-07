// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';

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

class G711Flutter {
  static var _initiated = false;
  G711Flutter() {
    if (!_initiated) {
      _initiated = true;
      _pcm16_ulaw_tableinit();
      _ulaw_pcm16_tableinit();
    }
  }
  Uint8List pcm16ToUlaw(Uint8List pcm16) {
    final inSize = pcm16.length;
    final outSize = inSize ~/ 2;
    final inArray = calloc<Uint8>(inSize);
    final outArray = calloc<Uint8>(outSize);
    inArray.asTypedList(pcm16.length).setAll(0, pcm16);

    _pcm16_to_ulaw(inSize, inArray, outArray);

    final out = Uint8List.fromList(outArray.asTypedList(outSize));
    calloc.free(outArray);
    calloc.free(inArray);
    return out;
  }

  Uint8List ulawToPcm16(Uint8List g711) {
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
