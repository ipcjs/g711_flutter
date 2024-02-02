// ignore_for_file: non_constant_identifier_names

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:g711_flutter/g711_flutter.dart';

/// Created by ipcjs on 2022/1/8.
void main() {
  group('g711', () {
    test('Endian', () {
      final pcm16 = Uint8List.sublistView(
          Int16List.fromList([1, -1, 0xffff, 0, 0x7fff, 0x8000]));
      expect(Endian.host, Endian.little);
      expect(pcm16, _pcm_in);
    });
    test('DartG711u', () {
      final g711 = DartG711Codec.g711u();

      final ulaw = g711.encode(_pcm_in);
      final pcm_out = g711.decode(ulaw);

      expect(ulaw, _ulaw);
      expect(pcm_out, _pcm_out_u);
    });
    test('DartG711a', () {
      final g711 = DartG711Codec.g711a();

      final alaw = g711.encode(_pcm_in);
      final pcm_out = g711.decode(alaw);

      expect(alaw, _alaw);
      expect(pcm_out, _pcm_out_a);
    });
  });
}

/// Int16List.fromList([1, -1, 0xffff, 0, 0x7fff, 0x8000])
final _pcm_in =
    Uint8List.fromList([1, 0, 255, 255, 255, 255, 0, 0, 255, 127, 0, 128]);

final _ulaw = Uint8List.fromList([255, 126, 126, 255, 128, 0]);
final _pcm_out_u =
    Uint8List.fromList([0, 0, 248, 255, 248, 255, 0, 0, 124, 125, 132, 130]);

final _alaw = Uint8List.fromList([213, 85, 85, 213, 170, 42]);
final _pcm_out_a =
    Uint8List.fromList([8, 0, 248, 255, 248, 255, 8, 0, 0, 126, 0, 130]);
