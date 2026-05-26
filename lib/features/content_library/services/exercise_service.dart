import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sahtek/core/api/endpoint.dart';
import 'package:sahtek/models/content_model.dart';

class ExerciseService {
  /// Récupère les exercices d'une zone depuis le backend distant.
  /// If [categoryKey] is null or empty, fetches all public exercises.
  /// Otherwise calls `users/public-exercises/:categoryKey`.
  static Future<List<ContentModel>> fetchExercicesByZone(
    String? categoryKey,
  ) async {
    try {
      final String path;
      if (categoryKey == null || categoryKey.isEmpty) {
        path = EndPoint.publicExercises;
      } else {
        // backend expects enum keys like NECK, LEFT_SHOULDER etc.
        path =
            '${EndPoint.publicExercises}/${Uri.encodeComponent(categoryKey)}';
      }

      final List<dynamic> data = await EndPoint.client.get(path);

      if (data.isNotEmpty) {
        return data.map((json) => ContentModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint(
        'Erreur lors du chargement API pour la catégorie "${categoryKey}": $e',
      );
    }

    return [];
  }
}
