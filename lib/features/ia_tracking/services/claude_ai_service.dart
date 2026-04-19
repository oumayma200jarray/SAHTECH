import 'package:sahtek/models/ia_tracking_model.dart';

class ClaudeAIService {
  ClaudeAIService({String? apiKey});

  Future<String?> getFeedback(IATrackingData data) async {
    if (data.trunkLeanAngle > 15.0) {
      return 'Redressez votre dos.';
    }
    if (data.elbowFlexion < 150.0) {
      return 'Gardez le bras tendu.';
    }

    final progress = (data.currentValue / data.objective).clamp(0.0, 1.5);
    if (progress >= 1.0) return 'Objectif atteint, redescendez doucement.';
    if (progress >= 0.85) return 'Encore un petit effort.';
    if (progress >= 0.5) return 'Très bien, continuez.';
    if (progress >= 0.2) return 'Levez le bras progressivement.';
    return 'Mettez-vous en position de départ.';
  }
}
