# g711_flutter

PCM to G711 Fast Conversions

## Document

- [NativeG711Codec](lib/src/native_g711.dart): Implemented by calling C code. ([escrichov/G711](https://github.com/escrichov/G711))
- [DartG711Codec](lib/src/dart_g711.dart): Implemented using pure Dart code.

### Performance

The time to process 1MB PCM is as follows.

```
I/flutter (17001): native.preload: 0:00:00.001007 
I/flutter (17001): dart  .preload: 0:00:00.003305 
I/flutter (17001): native.pcm16ToUlaw: 0:00:00.001478 
I/flutter (17001): dart  .pcm16ToUlaw: 0:00:00.017759 
I/flutter (17001): native.ulawToPcm16: 0:00:00.001663 
I/flutter (17001): dart  .ulawToPcm16: 0:00:00.010298 
```
