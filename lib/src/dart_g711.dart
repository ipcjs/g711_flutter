import 'dart:typed_data';

import 'g711.dart';
import 'g711_codec.dart';
import 'int_list.dart';

/// Created by ipcjs on 2022/1/8.
class DartG711Codec extends G711Codec {
  @Deprecated('Use DartG711Codec.g711u instead')
  factory DartG711Codec() = DartG711Codec.g711u;

  DartG711Codec.g711u() : this._(G711.linear2ulaw, G711.ulaw2linear);

  DartG711Codec.g711a() : this._(G711.linear2alaw, G711.alaw2linear);

  DartG711Codec._(this.linear2law, this.law2linear);

  final int Function(int pcm) linear2law;
  final int Function(int law) law2linear;

  final _linear_to_law = List<int?>.filled(65536, null);
  final _law_to_linear = List<int?>.filled(256, null);

  void forcePreloadTable() {
    for (int i = 0; i < _linear_to_law.length; i++) {
      _linear_to_law[i] =
          linear2law(i.toSigned(16) /* unsigned short -> short */);
    }
    for (int i = 0; i < _law_to_linear.length; i++) {
      _law_to_linear[i] = law2linear(i);
    }
  }

  @override
  Uint8List encode(Uint8List pcm) {
    final inArray = int16LeListValueSublistView(pcm).list;
    final size = inArray.length;
    final outArray = Uint8List(size);
    for (var i = 0; i < size; i++) {
      final inValue = inArray[i];
      var outValue =
          _linear_to_law[inValue & 0xffff] /* short -> unsigned short */;
      if (outValue == null) {
        outValue = linear2law(inValue);
        _linear_to_law[inValue & 0xffff] = outValue;
      }
      outArray[i] = outValue;
    }

    return outArray;
  }

  @override
  Uint8List decode(Uint8List g711) {
    final inArray = g711;
    final size = inArray.length;
    final outArrayValue = int16LeListValue(size);
    final outArray = outArrayValue.list;
    for (var i = 0; i < size; i++) {
      final inValue = inArray[i];
      var outValue = _law_to_linear[inValue];
      if (outValue == null) {
        outValue = law2linear(inValue);
        _law_to_linear[inValue] = outValue;
      }
      outArray[i] = outValue;
    }

    return outArrayValue.asUint8List();
  }
}
