import 'dart:typed_data';

import 'native_g711.dart';

/// Created by ipcjs on 2022/1/8.
class DartG711Codec implements G711Codec {
  const DartG711Codec();

  @override
  Uint8List pcm16ToUlaw(Uint8List pcm16) {
    // TODO: implement pcm16ToUlaw
    throw UnimplementedError();
  }

  @override
  Uint8List ulawToPcm16(Uint8List g711) {
    // TODO: implement ulawToPcm16
    throw UnimplementedError();
  }
}
