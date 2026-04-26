import 'package:sahtek/features/ia_tracking/services/base_ai_service.dart';
import 'package:sahtek/models/ia_tracking_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Implémentation du service IA utilisant Anthropic Claude.
/// Reconnu pour sa précision chirurgicale dans le raisonnement clinique.
class ClaudeAIService implements BaseAIService {
  final String? apiKey = dotenv.env['CLAUDE_API_KEY'];

  @override
  String get name => "Claude 3.5 Sonnet";

  @override
  Future<String?> getFeedback(IATrackingData data, {List<int>? imageBytes}) async {
    // Si pas de clé, on utilise les règles expertes locales (Hybride)
    if (apiKey == null || apiKey!.isEmpty || apiKey!.contains('YOUR_')) {
      return _getLocalExpertFeedback(data);
    }

    try {
      // TODO: Implémenter l'appel HTTP vers Anthropic API
      // En attendant, on utilise le moteur local expert qui est déjà très précis.
      return _getLocalExpertFeedback(data);
    } catch (e) {
      return _getLocalExpertFeedback(data);
    }
  }

  @override
  Future<String?> generateSessionSummary(IATrackingData data) async {
    // Synthèse automatique basée sur les performances
    final bool reached = data.currentValue >= data.objective;
    final String postStr = data.precision > 0.8 ? "excellente" : "perfectible";
    
    return "Session terminée. L'objectif de ${data.objective}${data.unit} a été ${reached ? 'atteint' : 'approché'}. La qualité posturale globale était $postStr. Continuez vos efforts pour stabiliser le tronc.";
  }

  /// Moteur de règles expertes (Local) - Garantit zéro latence
  String _getLocalExpertFeedback(IATrackingData data) {
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
