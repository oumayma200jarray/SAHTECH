import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:sahtek/models/pose_model.dart';

/// Service expérimental "Pure AI" permettant de détecter les articulations
/// sans utiliser ML Kit localement (réduction de la taille de l'APK).
class VisionTrackingService {
  late final GenerativeModel _model;
  final String? apiKey = dotenv.env['GEMINI_API_KEY'];

  VisionTrackingService() {
    if (apiKey != null) {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey!,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.1, // Très déterministe pour les coordonnées
        ),
      );
    }
  }

  Future<List<Pose>> detectPoseFromImage(List<int> imageBytes) async {
    if (apiKey == null) return [];

    try {
      final prompt = """
Détecte les articulations du corps humain dans cette image. 
Retourne uniquement un JSON avec les coordonnées normalisées (0.0 à 1.0) pour :
- left_shoulder, left_elbow, left_wrist, left_hip
- right_shoulder, right_elbow, right_wrist, right_hip

Format JSON :
{
  "landmarks": {
    "left_shoulder": {"x": 0.5, "y": 0.3},
    ...
  }
}
""";

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', Uint8List.fromList(imageBytes)),
        ]),
      ];

      final response = await _model.generateContent(content);
      final jsonResponse = jsonDecode(response.text ?? '{}');

      return _mapJsonToPoses(jsonResponse);
    } catch (e) {
      print('Erreur VisionTrackingService: $e');
      return [];
    }
  }

  List<Pose> _mapJsonToPoses(Map<String, dynamic> json) {
    if (!json.containsKey('landmarks')) return [];

    final Map<PoseLandmarkType, PoseLandmark> landmarks = {};
    final landmarkData = json['landmarks'] as Map<String, dynamic>;

    void addLandmark(String key, PoseLandmarkType type) {
      if (landmarkData.containsKey(key)) {
        final point = landmarkData[key];
        landmarks[type] = PoseLandmark(
          type: type,
          x:
              (point['x'] as num).toDouble() *
              1000, // Denormalize for PosePainter (assumes 1000 base)
          y: (point['y'] as num).toDouble() * 1000,
          z: 0.0,
          likelihood: 1.0,
        );
      }
    }

    addLandmark('left_shoulder', PoseLandmarkType.leftShoulder);
    addLandmark('left_elbow', PoseLandmarkType.leftElbow);
    addLandmark('left_wrist', PoseLandmarkType.leftWrist);
    addLandmark('left_hip', PoseLandmarkType.leftHip);
    addLandmark('right_shoulder', PoseLandmarkType.rightShoulder);
    addLandmark('right_elbow', PoseLandmarkType.rightElbow);
    addLandmark('right_wrist', PoseLandmarkType.rightWrist);
    addLandmark('right_hip', PoseLandmarkType.rightHip);

    return [Pose(landmarks: landmarks)];
  }
}
