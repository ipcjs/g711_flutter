import 'dart:collection';
import 'dart:typed_data';

/// [Int16List]读写数据的大小端由操作系统决定, 目前绝大多数系统都是小端的, 但为了保证严谨性,
/// 我们还是实现了一个保证是小端的[Int16LeList], 只在大端系统上启用.
///
/// Created by ipcjs on 2022/1/8.

/// only for test
const _forceUseInt16LeList = false;

/// @see: [Int16List.sublistView]
IntListValue int16LeListValueSublistView(TypedData data,
        [int start = 0, int? end]) =>
    Endian.host == Endian.little &&
            !_forceUseInt16LeList &&
            // Int16List requires byte alignment.
            // see: https://github.com/dart-lang/sdk/blob/master/sdk/lib/_internal/vm/lib/typed_data_patch.dart#L1935
            data.offsetInBytes % Int16List.bytesPerElement == 0
        ? _Int16ListValue(Int16List.sublistView(data, start, end))
        : _Int16LeListValue(
            Int16LeList(ByteData.sublistView(data, start, end)));

/// @see: [Int16List]
IntListValue int16LeListValue(int length) {
  return Endian.host == Endian.little && !_forceUseInt16LeList
      ? _Int16ListValue(Int16List(length))
      : _Int16LeListValue(
          Int16LeList(ByteData(Int16LeList.bytesPerElement * length)));
}

class Int16LeList extends ListBase<int> {
  static const int bytesPerElement = 2;

  Int16LeList(this._data) : assert(_data.lengthInBytes % bytesPerElement == 0);

  final ByteData _data;

  @override
  int get length => _data.lengthInBytes ~/ bytesPerElement;

  @override
  set length(int newLength) => throw UnsupportedError('Int16LeList.length');

  @override
  operator [](int index) =>
      _data.getInt16(index * bytesPerElement, Endian.little);

  @override
  void operator []=(int index, int value) =>
      _data.setInt16(index * bytesPerElement, value, Endian.little);

  Uint8List asUint8List() => Uint8List.sublistView(_data);
}

abstract class IntListValue {
  List<int> get list;

  Uint8List asUint8List();
}

class _Int16ListValue implements IntListValue {
  _Int16ListValue(this._list);

  final Int16List _list;

  @override
  List<int> get list => _list;

  @override
  Uint8List asUint8List() => Uint8List.sublistView(_list);
}

class _Int16LeListValue implements IntListValue {
  _Int16LeListValue(this._list);

  final Int16LeList _list;

  @override
  List<int> get list => _list;

  @override
  Uint8List asUint8List() => _list.asUint8List();
}
