import 'dart:math' as math;

/// Un filtre passe-bas simple (Exponential Moving Average) pour lisser les données.
/// Utile pour réduire le tremblement (jitter) des landmarks ML Kit.
class LandmarkSmoother {
  final double alpha;
  double? _lastValue;

  LandmarkSmoother({this.alpha = 0.5});

  double filter(double newValue) {
    if (_lastValue == null) {
      _lastValue = newValue;
      return newValue;
    }
    _lastValue = (alpha * newValue) + ((1 - alpha) * _lastValue!);
    return _lastValue!;
  }

  void reset() {
    _lastValue = null;
  }
}

/// Un point 2D lissé.
class SmoothedPoint {
  final LandmarkSmoother _xFilter;
  final LandmarkSmoother _yFilter;

  SmoothedPoint({double alpha = 0.5})
      : _xFilter = LandmarkSmoother(alpha: alpha),
        _yFilter = LandmarkSmoother(alpha: alpha);

  math.Point<double> filter(double x, double y) {
    return math.Point(_xFilter.filter(x), _yFilter.filter(y));
  }

  void reset() {
    _xFilter.reset();
    _yFilter.reset();
  }
}
