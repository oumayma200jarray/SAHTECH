import 'package:flutter_tts/flutter_tts.dart';

class VoiceCoachingService {
  final FlutterTts _flutterTts = FlutterTts();
  
  // Anti-repetition memory
  final Map<String, DateTime> _lastSpokenMessages = {};
  DateTime _lastAnyMessageTime = DateTime.fromMillisecondsSinceEpoch(0);
  
  // Cooldown durations
  static const Duration _kSameMessageCooldown = Duration(seconds: 8);
  static const Duration _kGlobalCooldown = Duration(seconds: 4);
  
  VoiceCoachingService() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("fr-FR");
    await _flutterTts.setSpeechRate(0.55);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> speak(String message, {bool force = false}) async {
    if (message.isEmpty) return;
    
    final now = DateTime.now();
    
    // Check global cooldown
    if (!force && now.difference(_lastAnyMessageTime) < _kGlobalCooldown) {
      return;
    }
    
    // Check per-message cooldown
    if (!force && _lastSpokenMessages.containsKey(message)) {
      if (now.difference(_lastSpokenMessages[message]!) < _kSameMessageCooldown) {
        return;
      }
    }

    _lastSpokenMessages[message] = now;
    _lastAnyMessageTime = now;

    if (force) await _flutterTts.stop();
    await _flutterTts.speak(message);
  }

  String getIntroMessage(String exerciseId) {
    String name = "";
    String instruction = "";
    
    if (exerciseId.contains('flexion')) {
      name = "Test de flexion.";
      instruction = "Lever le bras doucement vers l'avant. Maintenir le dos droit.";
    } else if (exerciseId.contains('extension')) {
      name = "Test d'extension.";
      instruction = "Amener le bras vers l'arrière doucement. Garder les épaules stables.";
    } else if (exerciseId.contains('abduction')) {
      name = "Test d'abduction.";
      instruction = "Monter le bras sur le côté progressivement sans hausser l’épaule.";
    } else if (exerciseId.contains('rotation_externe')) {
      name = "Rotation externe.";
      instruction = "Tourner l’avant-bras vers l’extérieur. Garder le coude collé au corps.";
    } else if (exerciseId.contains('rotation_interne')) {
      name = "Rotation interne.";
      instruction = "Tourner l’avant-bras vers l’intérieur. Maintenir le coude au corps.";
    } else {
      name = "Test de mobilité.";
      instruction = "Réalisez le mouvement demandé lentement.";
    }
    
    return "$name $instruction L'IA analyse votre posture.";
  }

  double getObjectiveFor(String exerciseId) {
    final id = exerciseId.toLowerCase();
    if (id.contains('flexion')) return 180.0;
    if (id.contains('abduction')) return 180.0;
    if (id.contains('rotation_externe')) return 70.0;
    if (id.contains('rotation_interne')) return 30.0;
    if (id.contains('extension')) return 50.0;
    if (id.contains('adduction')) return 30.0;
    return 180.0;
  }

  Future<void> speakFeedback({
    required String exerciseId,
    required double angle,
    String? message,
  }) async {
    final objective = getObjectiveFor(exerciseId);
    final int roundedAngle = angle.toInt();
    final int roundedObjective = objective.toInt();

    // 1. Si le patient a atteint ou dépassé l'amplitude cible idéale (ex: >= 95% de l'objectif)
    if (angle >= (objective - 5.0)) {
      final successMsg = "Excellent ! Bravo, vous avez atteint l'amplitude idéale de $roundedObjective degrés ! Vous pouvez relâcher.";
      await speak(successMsg, force: true);
      return;
    }

    // 2. Si un message d'erreur/avertissement de posture est fourni (ex: buste penche)
    if (message != null && message.isNotEmpty) {
      await speak(message);
      return;
    }

    // 3. Encouragement périodique selon la progression
    final progress = angle / objective;
    if (progress >= 0.5 && progress < 0.6) {
      await speak("Continuez, c'est bien. Allez-y doucement.");
    } else if (progress >= 0.75 && progress < 0.85) {
      await speak("Encore un peu, vous y êtes presque.");
    }
  }

  Future<void> speakCompletion(String side) async {
    await speak("Test terminé. Limitation détectée côté $side. Merci.", force: true);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
