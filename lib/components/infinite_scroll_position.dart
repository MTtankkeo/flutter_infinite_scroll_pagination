import 'package:flutter/widgets.dart';

class InfiniteScrollPosition extends Listenable {
  double viewHeight = 0.0;
  double extent = 0.0;

  final _pixelsNotifier = ValueNotifier<double>(0.0);
  double get pixels => _pixelsNotifier.value;
  set pixels(double newValue) => _pixelsNotifier.value = newValue;

  final isVisibleNotifier = ValueNotifier<bool>(false);

  /// Returns the value that finally reflected [newPixels].
  double setPixels(double newPixels) {
    if (pixels != newPixels) {
      final oldPixels = pixels;
      final available = (extent - viewHeight).clamp(0.0, double.infinity);

      pixels = newPixels.clamp(0, available);
      return oldPixels - pixels;
    }

    return 0.0;
  }

  /// Returns the value that finally reflected [delta].
  double setPixelsByDelta(double delta) => setPixels(pixels - delta);

  @override
  void addListener(VoidCallback listener) {
    _pixelsNotifier.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _pixelsNotifier.removeListener(listener);
  }
}
