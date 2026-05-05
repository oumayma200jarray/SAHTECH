import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart' as mlkit;
import 'package:sahtek/models/pose_model.dart';

class PoseDetectionService {
  final mlkit.PoseDetector _poseDetector = mlkit.PoseDetector(
    options: mlkit.PoseDetectorOptions(
      mode: mlkit.PoseDetectionMode.single,
      model: mlkit.PoseDetectionModel.accurate, // Senior AI: Plus de précision pour les angles
    ),
  );

  Future<List<Pose>> processImage(mlkit.InputImage inputImage) async {
    try {
      final mlkitPoses = await _poseDetector.processImage(inputImage);
      if (mlkitPoses.isNotEmpty) {
        // debugPrint('MLKit Service: Found ${mlkitPoses.length} poses');
      }
      return mlkitPoses.map((p) => _mapToCustomPose(p)).toList();
    } catch (e) {
      debugPrint('MLKit Service Error: $e');
      return [];
    }
  }

  Pose _mapToCustomPose(mlkit.Pose mlkitPose) {
    final Map<PoseLandmarkType, PoseLandmark> customLandmarks = {};
    
    // Mapping manuel des landmarks critiques
    mlkitPose.landmarks.forEach((type, landmark) {
      PoseLandmarkType? customType;
      switch (type) {
        case mlkit.PoseLandmarkType.leftShoulder: customType = PoseLandmarkType.leftShoulder; break;
        case mlkit.PoseLandmarkType.rightShoulder: customType = PoseLandmarkType.rightShoulder; break;
        case mlkit.PoseLandmarkType.leftElbow: customType = PoseLandmarkType.leftElbow; break;
        case mlkit.PoseLandmarkType.rightElbow: customType = PoseLandmarkType.rightElbow; break;
        case mlkit.PoseLandmarkType.leftWrist: customType = PoseLandmarkType.leftWrist; break;
        case mlkit.PoseLandmarkType.rightWrist: customType = PoseLandmarkType.rightWrist; break;
        case mlkit.PoseLandmarkType.leftHip: customType = PoseLandmarkType.leftHip; break;
        case mlkit.PoseLandmarkType.rightHip: customType = PoseLandmarkType.rightHip; break;
        case mlkit.PoseLandmarkType.leftKnee: customType = PoseLandmarkType.leftKnee; break;
        case mlkit.PoseLandmarkType.rightKnee: customType = PoseLandmarkType.rightKnee; break;
        default: break; // On ignore les autres points (visage, pieds, etc.) pour optimiser
      }

      if (customType != null) {
        customLandmarks[customType] = PoseLandmark(
          type: customType,
          x: landmark.x,
          y: landmark.y,
          z: landmark.z,
          likelihood: landmark.likelihood,
        );
      }
    });

    return Pose(landmarks: customLandmarks);
  }

  void dispose() {
    _poseDetector.close();
  }
}
