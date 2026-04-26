/// Modèle local pour les articulations (Pose) afin de supprimer la dépendance ML Kit.
/// Cela réduit la taille de l'application de ~20Mo.

enum PoseLandmarkType {
  leftShoulder,
  rightShoulder,
  leftElbow,
  rightElbow,
  leftWrist,
  rightWrist,
  leftHip,
  rightHip,
  leftKnee,
  rightKnee,
}

class PoseLandmark {
  final PoseLandmarkType type;
  final double x;
  final double y;
  final double z;
  final double likelihood;

  PoseLandmark({
    required this.type,
    required this.x,
    required this.y,
    this.z = 0.0,
    this.likelihood = 1.0,
  });
}

class Pose {
  final Map<PoseLandmarkType, PoseLandmark> landmarks;

  Pose({required this.landmarks});
}

/// Émulation de l'énumération de rotation pour le PosePainter
enum InputImageRotation {
  rotation0deg,
  rotation90deg,
  rotation180deg,
  rotation270deg,
}
