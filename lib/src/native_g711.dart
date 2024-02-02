import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';

import 'g711_codec.dart';

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

final _pcm16_alaw_tableinit = _g711
    .lookupFunction<Void Function(), void Function()>('pcm16_alaw_tableinit');

final _alaw_pcm16_tableinit = _g711
    .lookupFunction<Void Function(), void Function()>('alaw_pcm16_tableinit');

final _ulaw_to_pcm16 = _g711.lookupFunction<
    Void Function(Int32, Pointer<Uint8>, Pointer<Uint8>),
    void Function(int, Pointer<Uint8>, Pointer<Uint8>)>('ulaw_to_pcm16');
final _pcm16_to_ulaw = _g711.lookupFunction<
    Void Function(Int32, Pointer<Uint8>, Pointer<Uint8>),
    void Function(int, Pointer<Uint8>, Pointer<Uint8>)>('pcm16_to_ulaw');

final _alaw_to_pcm16 = _g711.lookupFunction<
    Void Function(Int32, Pointer<Uint8>, Pointer<Uint8>),
    void Function(int, Pointer<Uint8>, Pointer<Uint8>)>('alaw_to_pcm16');
final _pcm16_to_alaw = _g711.lookupFunction<
    Void Function(Int32, Pointer<Uint8>, Pointer<Uint8>),
    void Function(int, Pointer<Uint8>, Pointer<Uint8>)>('pcm16_to_alaw');

class NativeG711Codec extends G711Codec {
  @Deprecated('Use NativeG711Codec.g711u instead')
  factory NativeG711Codec() = NativeG711Codec.g711u;

  NativeG711Codec.g711u()
      : this._(_pcm16_to_ulaw, _ulaw_to_pcm16, () {
          _pcm16_ulaw_tableinit();
          _ulaw_pcm16_tableinit();
        });

  NativeG711Codec.g711a()
      : this._(_pcm16_to_alaw, _alaw_to_pcm16, () {
          _pcm16_alaw_tableinit();
          _alaw_pcm16_tableinit();
        });

  NativeG711Codec._(this.pcm_to_law, this.law_to_pcm, this._initTable) {
    if (!_initiated) {
      _initiated = true;
      _initTable();
    }
  }

  var _initiated = false;
  final void Function() _initTable;
  final void Function(int, Pointer<Uint8>, Pointer<Uint8>) pcm_to_law;
  final void Function(int, Pointer<Uint8>, Pointer<Uint8>) law_to_pcm;

  void forcePreloadTable() {
    _initTable();
  }

  @override
  Uint8List encode(Uint8List pcm) {
    final inSize = pcm.length;
    final outSize = inSize ~/ 2;
    final inArray = calloc<Uint8>(inSize);
    final outArray = calloc<Uint8>(outSize);
    inArray.asTypedList(pcm.length).setAll(0, pcm);

    pcm_to_law(inSize, inArray, outArray);

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

    law_to_pcm(inSize, inArray, outArray);

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
