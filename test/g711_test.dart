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
    test('DartG711', () {
      const g711 = DartG711Codec();

      final ulaw = g711.pcm16ToUlaw(_pcm_in);
      final pcm_out = g711.ulawToPcm16(ulaw);

      expect(ulaw, _ulaw);
      expect(pcm_out, _pcm_out);
    });
  });
}

/// Int16List.fromList([1, -1, 0xffff, 0, 0x7fff, 0x8000])
final _pcm_in =
    Uint8List.fromList([1, 0, 255, 255, 255, 255, 0, 0, 255, 127, 0, 128]);
final _ulaw = Uint8List.fromList([255, 126, 126, 255, 128, 0]);
final _pcm_out =
    Uint8List.fromList([0, 0, 248, 255, 248, 255, 0, 0, 124, 125, 132, 130]);
