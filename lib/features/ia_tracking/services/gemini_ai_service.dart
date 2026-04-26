import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:sahtek/features/ia_tracking/services/base_ai_service.dart';
import 'package:sahtek/models/ia_tracking_model.dart';

/// Implémentation du service IA utilisant Google Gemini 1.5 Flash.
/// Choisi pour sa rapidité (Low Latency) et sa précision biomécanique.
class GeminiAIService implements BaseAIService {
  late final GenerativeModel _model;
  final String? apiKey = dotenv.env['GEMINI_API_KEY'];

  GeminiAIService() {
    if (apiKey == null || apiKey!.isEmpty || apiKey!.contains('YOUR_')) {
      // Fallback ou erreur silencieuse si la clé manque
      _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: '');
    } else {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey!,
        generationConfig: GenerationConfig(
          temperature: 0.4, // Un peu de créativité mais reste précis
          topP: 0.8,
          maxOutputTokens: 60, // Réponses courtes pour le TTS (voix)
        ),
      );
    }
  }

  @override
  String get name => "Gemini 1.5 Flash";

  @override
  Future<String?> getFeedback(IATrackingData data, {List<int>? imageBytes}) async {
    if (apiKey == null || apiKey!.isEmpty || apiKey!.contains('YOUR_')) {
      return null;
    }

    try {
      final prompt = _buildSystemPrompt(data, hasImage: imageBytes != null);
      
      final content = [
        Content.multi([
          TextPart(prompt),
          if (imageBytes != null) 
            DataPart('image/jpeg', Uint8List.fromList(imageBytes)),
        ])
      ];

      final response = await _model.generateContent(content);
      return response.text?.trim();
    } catch (e) {
      print('Erreur GeminiAIService: $e');
      return null;
    }
  }

  @override
  Future<String?> generateSessionSummary(IATrackingData data) async {
    if (apiKey == null || apiKey!.isEmpty || apiKey!.contains('YOUR_')) {
      return null;
    }

    try {
      final prompt = """
Tu es un kinésithérapeute rédigeant un compte-rendu médical professionnel et détaillé.
Analyse les résultats de cette session de rééducation pour le rapport final :
- Exercice : ${data.title}
- Performance Max : ${data.currentValue.toStringAsFixed(1)}${data.unit} (Objectif : ${data.objective}${data.unit})
- Qualité Posturale Globale : ${(data.precision).toInt()}%
- Inclinaison moyenne du tronc : ${data.avgTrunkLean.toStringAsFixed(1)}°
- Déséquilibre moyen des épaules : ${data.avgShoulderImbalance.toStringAsFixed(1)}%
- Répétitions effectuées : ${data.repetitionCount}

Rédige une conclusion structurée en 3-4 phrases. 
PRIORITÉ ABSOLUE : Commente d'abord l'équilibre du dos (tronc). Dis s'il était parfaitement droit ou s'il y avait une inclinaison latérale. 
Ensuite, mentionne la stabilité des épaules. 
Termine par un conseil pour la prochaine séance.
""";
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text?.trim();
    } catch (e) {
      return "Session terminée avec succès. Objectif : ${data.objective}${data.unit}.";
    }
  }

  String _buildSystemPrompt(IATrackingData data, {bool hasImage = false}) {
    String visualContext = hasImage 
      ? "Tu as accès à l'image du patient en temps réel. Regarde attentivement sa posture physique, pas seulement les chiffres." 
      : "Base-toi sur les données biomécaniques suivantes :";

    return """
Tu es un kinésithérapeute expert assistant un patient en temps réel.
$visualContext

Donne un conseil très court (max 12 mots) basé sur ces données :
- Exercice : ${data.title}
- Valeur actuelle : ${data.currentValue}${data.unit} (Objectif : ${data.objective}${data.unit})
- Inclinaison du tronc : ${data.signedTrunkLean.toStringAsFixed(1)}°
- Déséquilibre des épaules : ${data.shoulderImbalance.toStringAsFixed(1)}%
- Flexion du coude : ${data.elbowFlexion.toStringAsFixed(1)}°

Priorités :
1. Si le tronc penche ou épaules inégales : "Redressez-vous et gardez les épaules à plat."
2. Si le bras est plié : "Tendez bien votre bras."
3. Sinon : "Continuez, montez encore."

Réponds UNIQUEMENT par le conseil court.
""";
  }
}
