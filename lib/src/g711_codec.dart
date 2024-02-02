import 'dart:typed_data';

abstract class G711Codec {
  Uint8List encode(Uint8List pcm);

  Uint8List decode(Uint8List g711);

  @Deprecated('Use encode instead')
  Uint8List pcm16ToUlaw(Uint8List pcm16) => encode(pcm16);

  @Deprecated('Use decode instead')
  Uint8List ulawToPcm16(Uint8List g711) => decode(g711);
}
