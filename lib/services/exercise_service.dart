import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sahtek/models/content_model.dart';
import 'package:sahtek/services/api_request.dart';

class ExerciseService {
  /// Récupère les exercices d'une zone depuis le backend distant.
  static Future<List<ContentModel>> fetchExercicesByZone(String zone) async {
    try {
      // On encode la zone pour gérer les accents ou espaces (ex: "Épaule")
      final queryZone = Uri.encodeComponent(zone.toLowerCase());
      final List<dynamic> data = await ApiRequest.instance.get('/exercises?zone=$queryZone');
      
      if (data.isNotEmpty) {
        return data.map((json) => ContentModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement API pour la zone "$zone": $e');
    }

    return [];
  }
}
