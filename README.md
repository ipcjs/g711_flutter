# g711_flutter

PCM to G711 Fast Conversions

## Document

- [NaviteG711Codec](lib/src/native_g711.dart): Implemented by calling C code. ([escrichov/G711](https://github.com/escrichov/G711))
- [DartG711Codec](lib/src/dart_g711.dart): Implemented using pure Dart code.

## Performance

The time to process 1MB PCM is as follows.

```
I/flutter (17001): native.preload: 0:00:00.001007 
I/flutter (17001): dart  .preload: 0:00:00.003305 
I/flutter (17001): native.pcm16ToUlaw: 0:00:00.001478 
I/flutter (17001): dart  .pcm16ToUlaw: 0:00:00.017759 
I/flutter (17001): native.ulawToPcm16: 0:00:00.001663 
I/flutter (17001): dart  .ulawToPcm16: 0:00:00.010298 
```

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

