import 'package:sahtek/models/pose_model.dart';
import 'package:sahtek/models/ia_tracking_model.dart';

/// Détecte automatiquement la vue caméra en analysant la géométrie des landmarks.
/// Algorithme :
///   - PROFIL   : largeur épaules très faible (patient de côté)
///   - FACE     : nez visible + largeur épaules normale
///   - DOS      : nez non visible + largeur épaules normale
class DetectViewUseCase {
  CameraView execute(Pose pose) {
    final lS = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rS = pose.landmarks[PoseLandmarkType.rightShoulder];
    final lH = pose.landmarks[PoseLandmarkType.leftHip];
    final rH = pose.landmarks[PoseLandmarkType.rightHip];
    final nose = pose.landmarks[PoseLandmarkType.nose];

    if (lS == null || rS == null) {
      return CameraView.front; // Pas assez de données → défaut
    }

    // ── 1. Détecter Vue de Profil ────────────────────────────────────────────
    // Utilisation combinée de la largeur des épaules et de la différence de profondeur (Z)
    final double shoulderWidth = (lS.x - rS.x).abs();
    final double zDiff = (lS.z - rS.z).abs();
    
    final double leftTrunk = lH != null ? (lS.y - lH.y).abs() : 100;
    final double rightTrunk = rH != null ? (rS.y - rH.y).abs() : 100;
    final double avgTrunk = (leftTrunk + rightTrunk) / 2;
    
    final double profileRatio = shoulderWidth / (avgTrunk > 0 ? avgTrunk : 100);

    // En profil, la largeur apparente des épaules est faible (profileRatio faible).
    // zDiff est très bruité dans ML Kit, on le pondère fortement.
    if (profileRatio < 0.35 || (profileRatio < 0.5 && zDiff > 60)) {
      return CameraView.profile;
    }

    // ── 2. Détecter Face vs Dos ──────────────────────────────────────────────
    // Si le nez est détecté avec bonne confiance → FACE
    if (nose != null && nose.likelihood > 0.4) {
      return CameraView.front;
    }

    // Vérification secondaire : oreilles visibles
    final leftEar = pose.landmarks[PoseLandmarkType.leftEar];
    final rightEar = pose.landmarks[PoseLandmarkType.rightEar];
    if (leftEar != null &&
        rightEar != null &&
        leftEar.likelihood > 0.4 &&
        rightEar.likelihood > 0.4) {
      // Les deux oreilles visibles de face ou dos
      // En DOS : les oreilles sont derrière → généralement confidence faible
      // On vérifie si les oreilles sont ENTRE les épaules
      final earsMidX = (leftEar.x + rightEar.x) / 2;
      final shoulderMidX = (lS.x + rS.x) / 2;
      if ((earsMidX - shoulderMidX).abs() < shoulderWidth * 0.3) {
        return CameraView.front;
      }
    }

    // Nez non visible → DOS
    return CameraView.back;
  }
}
