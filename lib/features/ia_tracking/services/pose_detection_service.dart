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
        final pose = mlkitPoses.first;
        // Print pour déboguer les données ML Kit
        debugPrint('--- ML Kit Pose Data ---');
        pose.landmarks.forEach((type, landmark) {
          if (type == mlkit.PoseLandmarkType.nose || type == mlkit.PoseLandmarkType.leftShoulder) {
            debugPrint('Point: ${type.name} | x: ${landmark.x.toStringAsFixed(2)}, y: ${landmark.y.toStringAsFixed(2)}, conf: ${landmark.likelihood.toStringAsFixed(2)}');
          }
        });
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
        case mlkit.PoseLandmarkType.leftAnkle: customType = PoseLandmarkType.leftAnkle; break;
        case mlkit.PoseLandmarkType.rightAnkle: customType = PoseLandmarkType.rightAnkle; break;
        case mlkit.PoseLandmarkType.nose: customType = PoseLandmarkType.nose; break;
        case mlkit.PoseLandmarkType.leftEye: customType = PoseLandmarkType.leftEye; break;
        case mlkit.PoseLandmarkType.rightEye: customType = PoseLandmarkType.rightEye; break;
        case mlkit.PoseLandmarkType.leftEar: customType = PoseLandmarkType.leftEar; break;
        case mlkit.PoseLandmarkType.rightEar: customType = PoseLandmarkType.rightEar; break;
        default: break; 
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
