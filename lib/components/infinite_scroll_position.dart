import 'package:flutter/widgets.dart';

/// A class that tracks the scroll position and manages the visibility
/// of the loading indicator for infinite scroll pagination.
class InfiniteScrollPosition extends Listenable {
  /// The height of the visible viewport.
  double viewHeight = 0.0;

  /// The total scrollable extent (e.g., size of loading indicator)
  double extent = 0.0;

  final _pixelsNotifier = ValueNotifier<double>(0.0);

  /// Gets the current scroll offset in pixels.
  double get pixels => _pixelsNotifier.value;

  /// Sets the current scroll offset in pixels.
  set pixels(double newValue) => _pixelsNotifier.value = newValue;

  /// The notifier indicating whether the loading indicator is visible.
  final isVisibleNotifier = ValueNotifier<bool>(false);

  /// Sets the scroll position to [newPixels], clamped within valid bounds
  /// And, returns the difference between the old and new scroll position.
  double setPixels(double newPixels) {
    if (pixels != newPixels) {
      final oldPixels = pixels;
      final available = (extent - viewHeight).clamp(0.0, double.infinity);

      pixels = newPixels.clamp(0, available);
      return oldPixels - pixels;
    }

    return 0.0;
  }

  /// Adjusts the scroll position by [delta], clamped within valid
  /// bounds returns the difference applied after clamping.
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
