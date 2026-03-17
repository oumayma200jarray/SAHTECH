import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sahtek/models/ia_tracking_model.dart';

class ClaudeAIService {
  static const String _kClaudeModel = 'claude-sonnet-4-20250514';
  static const String _kClaudeApiUrl = 'https://api.anthropic.com/v1/messages';
  
  // ⚠️ En production : stocker la clé dans flutter_dotenv ou flutter_secure_storage
  final String _apiKey;

  ClaudeAIService({String? apiKey}) : _apiKey = apiKey ?? 'YOUR_API_KEY_HERE';

  Future<String?> getFeedback(IATrackingData data) async {
    try {
      final response = await http
          .post(
            Uri.parse(_kClaudeApiUrl),
            headers: {
              'Content-Type': 'application/json',
              'x-api-key': _apiKey,
              'anthropic-version': '2023-06-01',
            },
            body: jsonEncode({
              'model': _kClaudeModel,
              'max_tokens': 80,
              'system':
                  'Tu es un kinésithérapeute expert qui compare en temps réel le mouvement d\'un patient avec une vidéo de démonstration parfaite. '
                  'Ta mission est de donner des conseils courts, motivants et correctifs. '
                  'Si le patient est proche de l\'objectif, félicite-le par rapport à la vidéo. '
                  'Si le mouvement est incorrect (épaules, bras), compare-le à la posture idéale de l\'instruction. '
                  'Réponds UNIQUEMENT avec une phrase très courte (max 8 mots) pour la synthèse vocale. Langue: français.',
              'messages': [
                {'role': 'user', 'content': _toAIPrompt(data)},
              ],
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final feedback = body['content'][0]['text'] as String;
        return feedback.trim().replaceAll('"', '');
      } else {
        debugPrint('Claude API error ${response.statusCode}: ${response.body}');
        return null;
      }
    } on TimeoutException {
      debugPrint('Claude API timeout');
      return null;
    } catch (e) {
      debugPrint('Erreur API Claude: $e');
      return null;
    }
  }

  String _toAIPrompt(IATrackingData data) {
    return 'Exercice: ${data.title}. '
        'Objectif: ${data.objective}${data.unit}. '
        'Valeur actuelle: ${data.currentValue}${data.unit}. '
        'Précision: ${data.precision}%. '
        'Message actuel: ${data.guidanceText}.';
  }
}
