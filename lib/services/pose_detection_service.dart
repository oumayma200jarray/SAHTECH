import 'dart:math' as math;
import 'package:google_ml_kit/google_ml_kit.dart';

class PoseDetectionService {
  late PoseDetector _poseDetector;

  PoseDetectionService() {
    _poseDetector = PoseDetector(options: PoseDetectorOptions());
  }

  /// Traite une image provenant du flux caméra
  Future<List<Pose>> processImage(InputImage inputImage) async {
    try {
      final List<Pose> poses = await _poseDetector.processImage(inputImage);
      return poses;
    } catch (e) {
      print('Erreur PoseDetectionService: $e');
      return [];
    }
  }

  /// Calcule l'angle entre trois points (en degrés)
  double calculateAngle(
    PoseLandmark first,
    PoseLandmark second,
    PoseLandmark third,
  ) {
    double angle =
        (math.atan2(third.y - second.y, third.x - second.x) -
                math.atan2(first.y - second.y, first.x - second.x))
            .abs();

    // Conversion en degrés
    double degrees = angle * 180.0 / math.pi;

    // S'assurer que l'angle est entre 0 et 180
    if (degrees > 180.0) {
      degrees = 360.0 - degrees;
    }

    return degrees;
  }

  /// Libère les ressources
  void dispose() {
    _poseDetector.close();
  }
}
