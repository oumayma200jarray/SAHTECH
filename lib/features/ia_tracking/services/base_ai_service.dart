import 'package:sahtek/models/ia_tracking_model.dart';

/// Interface de base pour les services d'IA (Gemini, Claude, etc.)
/// Suit le principe de "Solid" (Dependency Inversion) pour changer de modèle facilement.
abstract class BaseAIService {
  /// Génère un feedback textuel basé sur les données de mouvement actuelles.
  /// L'image optionnelle permet une analyse visuelle multi-modale (Senior AI).
  Future<String?> getFeedback(IATrackingData data, {List<int>? imageBytes});

  /// Génère un résumé complet de la session pour le rapport final.
  Future<String?> generateSessionSummary(IATrackingData data);
  
  /// Nom du service pour le debugging.
  String get name;
}
