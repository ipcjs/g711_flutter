import 'dart:typed_data';

import 'g711.dart';
import 'int_list.dart';
import 'native_g711.dart';

/// Created by ipcjs on 2022/1/8.
class DartG711Codec implements G711Codec {
  static final _linear_to_ulaw = List<int?>.filled(65536, null);
  static final _ulaw_to_linear = List<int?>.filled(256, null);

  static void forcePreloadTable() {
    for (int i = 0; i < _linear_to_ulaw.length; i++) {
      _linear_to_ulaw[i] = G711.linear2ulaw(i.toSigned(16) /* unsigned short -> short */);
    }
    for (int i = 0; i < _ulaw_to_linear.length; i++) {
      _ulaw_to_linear[i] = G711.ulaw2linear(i);
    }
  }

  const DartG711Codec();

  @override
  Uint8List pcm16ToUlaw(Uint8List pcm16) {
    final inArray = int16LeListValueSublistView(pcm16).list;
    final size = inArray.length;
    final outArray = Uint8List(size);
    for (var i = 0; i < size; i++) {
      final inValue = inArray[i];
      var outValue = _linear_to_ulaw[inValue & 0xffff] /* short -> unsigned short */;
      if (outValue == null) {
        outValue = G711.linear2ulaw(inValue);
        _linear_to_ulaw[inValue & 0xffff] = outValue;
      }
      outArray[i] = outValue;
    }

    return outArray;
  }

  @override
  Uint8List ulawToPcm16(Uint8List g711) {
    final inArray = g711;
    final size = inArray.length;
    final outArrayValue = int16LeListValue(size);
    final outArray = outArrayValue.list;
    for (var i = 0; i < size; i++) {
      final inValue = inArray[i];
      var outValue = _ulaw_to_linear[inValue];
      if (outValue == null) {
        outValue = G711.ulaw2linear(inValue);
        _ulaw_to_linear[inValue] = outValue;
      }
      outArray[i] = outValue;
    }

    return outArrayValue.asUint8List();
  }
}
