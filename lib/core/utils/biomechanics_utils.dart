import 'dart:math' as math;
import 'package:sahtek/models/pose_model.dart';

class BiomechanicsUtils {
  static double degrees(double radians) => radians * 180.0 / math.pi;

  /// Calculates the 3D angle (in degrees) between three points.
  /// p2 is the vertex. Uses X, Y, and Z for clinical precision.
  static double calculateAngle3D(PoseLandmark p1, PoseLandmark p2, PoseLandmark p3) {
    // Vectors relative to vertex p2
    final v1 = [p1.x - p2.x, p1.y - p2.y, p1.z - p2.z];
    final v2 = [p3.x - p2.x, p3.y - p2.y, p3.z - p2.z];

    final dot = v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2];
    final mag1 = math.sqrt(v1[0] * v1[0] + v1[1] * v1[1] + v1[2] * v1[2]);
    final mag2 = math.sqrt(v2[0] * v2[0] + v2[1] * v2[1] + v2[2] * v2[2]);

    if (mag1 < 1e-6 || mag2 < 1e-6) return 0.0;
    
    final cosTheta = (dot / (mag1 * mag2)).clamp(-1.0, 1.0);
    return degrees(math.acos(cosTheta));
  }

  /// Calculates the 2D angle (in degrees) between three points.
  /// p2 is the vertex.
  static double calculateAngle2D(math.Point<double> p1, math.Point<double> p2, math.Point<double> p3) {
    final double angle = (math.atan2(p3.y - p2.y, p3.x - p2.x) -
            math.atan2(p1.y - p2.y, p1.x - p2.x))
        .abs();
    double degrees = angle * 180.0 / math.pi;
    if (degrees > 180.0) degrees = 360.0 - degrees;
    return degrees;
  }

  /// Calculates the anatomical angle between a trunk reference (Shoulder -> Hip)
  /// and a limb (Shoulder -> Distal).
  static double calculateAnatomicalAngle(
    math.Point<double> shoulder,
    math.Point<double> hip,
    math.Point<double> distal,
  ) {
    // Reference vector: from shoulder to hip (trunk axis)
    final double v1x = hip.x - shoulder.x;
    final double v1y = hip.y - shoulder.y;

    // Limb vector: from shoulder to distal (elbow or wrist)
    final double v2x = distal.x - shoulder.x;
    final double v2y = distal.y - shoulder.y;

    final double dot = v1x * v2x + v1y * v2y;
    final double mag1 = math.sqrt(v1x * v1x + v1y * v1y);
    final double mag2 = math.sqrt(v2x * v2x + v2y * v2y);

    if (mag1 < 1e-6 || mag2 < 1e-6) return 0.0;
    
    final double cosTheta = (dot / (mag1 * mag2)).clamp(-1.0, 1.0);
    return math.acos(cosTheta) * 180.0 / math.pi;
  }

  /// Calculates the distance between two points.
  static double distance(math.Point<double> p1, math.Point<double> p2) {
    final double dx = p1.x - p2.x;
    final double dy = p1.y - p2.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Calculates the vertical imbalance ratio between shoulders.
  /// Returns a percentage (0 to 100).
  static double calculateShoulderImbalance(math.Point<double> leftS, math.Point<double> rightS) {
    final double width = distance(leftS, rightS);
    final double heightDiff = (leftS.y - rightS.y).abs();
    if (width < 10) return 0.0;
    return (heightDiff / width) * 100.0;
  }

  /// Calculates trunk lean relative to absolute vertical.
  static double calculateTrunkLean(math.Point<double> midShoulder, math.Point<double> midHip) {
    // atan2(dx, dy) where dy is vertical difference
    return math.atan2(midShoulder.x - midHip.x, midHip.y - midShoulder.y) * 180 / math.pi;
  }
}

/// Exponential Moving Average filter for stabilizing signals.
class EMAFilter {
  final double alpha;
  double? _lastValue;

  EMAFilter({this.alpha = 0.6});

  double filter(double value) {
    if (_lastValue == null) {
      _lastValue = value;
      return value;
    }
    _lastValue = (alpha * value) + ((1 - alpha) * _lastValue!);
    return _lastValue!;
  }
}
