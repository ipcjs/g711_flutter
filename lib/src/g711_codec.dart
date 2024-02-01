import 'dart:typed_data';

abstract class IG711Codec {
  Uint8List encode(Uint8List pcm);

  Uint8List decode(Uint8List g711);
}
