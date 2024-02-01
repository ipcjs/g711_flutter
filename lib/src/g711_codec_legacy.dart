import 'dart:typed_data';

import 'dart_g711.dart';
import 'g711_codec.dart';
import 'native_g711.dart';

/// TODO: Remove the file in next major version.
///
/// Created by ipcjs on 2024/2/1.
mixin LegacyG711uCodecMixin on IG711Codec {
  @Deprecated('Use encode instead')
  Uint8List pcm16ToUlaw(Uint8List pcm16) => encode(pcm16);

  @Deprecated('Use decode instead')
  Uint8List ulawToPcm16(Uint8List g711) => decode(g711);
}

@Deprecated('Use IG711Codec instead')
typedef G711Codec = LegacyG711uCodecMixin;
@Deprecated('Use DartG711uCodec instead')
typedef DartG711Codec = DartG711uCodec;
@Deprecated('Use NativeG711uCodec instead')
typedef NativeG711Codec = NativeG711uCodec;
