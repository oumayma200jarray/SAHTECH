import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sahtek/features/auth/services/auth_service.dart';
import 'package:sahtek/models/content_model.dart';
import 'package:sahtek/models/appointment_model.dart';
import 'package:sahtek/services/appointment_service.dart';
import 'package:sahtek/models/patient_model.dart';
import 'package:sahtek/models/medical_document_model.dart';
import 'package:sahtek/models/ia_tracking_model.dart';
import 'package:sahtek/models/availability_model.dart';
import 'package:sahtek/services/availability_service.dart';
import 'package:sahtek/features/specialists/services/specialist_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalDataProvider extends ChangeNotifier {
  final AuthService _userService = AuthService();
  // Informations globales du patient
  PatientModel _profile = PatientModel.empty();
  PatientModel get profile => _profile;

  // Exercices assignés par le spécialiste
  List<ContentModel> _assignedExercises = [];
  List<ContentModel> get assignedExercises => _assignedExercises;

  // Membre sélectionné pour les exercices
  String membreSelectionne = ''; // Valeur par défaut

  // Contenu vu (Vidéos, Articles) - Pour les favoris dynamiques
  final List<ContentModel> _viewedContent = [];
  List<ContentModel> get viewedVideos =>
      _viewedContent.where((c) => c.videoUrl != null).toList();
  List<ContentModel> get viewedArticles =>
      _viewedContent.where((c) => c.videoUrl == null).toList();

  // Documents vus
  final Set<String> _viewedDocumentIds = {};
  List<MedicalDocument> get viewedDocuments => _medicalDocuments
      .where((doc) => _viewedDocumentIds.contains(doc.id))
      .toList();

  // Exercice ou Test sélectionné pour l'analyse
  ContentModel? selectedExercise;

  // Historique des suivis IA
  List<IATrackingData> _trackingHistory = [];
  List<IATrackingData> get trackingHistory => _trackingHistory;

  // Résultat du dernier suivi IA en direct
  IATrackingData? lastTrackingResult;

  // Configuration de la session en cours (Avant démarrage)
  IATrackingData? currentSessionData;

  // Liste des tests complétés dans la session actuelle
  final List<String> _completedTestsInSession = [];
  List<String> get completedTestsInSession => _completedTestsInSession;

  bool get isFullSessionComplete =>
      _completedTestsInSession.contains('ia_shoulder_flexion') &&
      _completedTestsInSession.contains('ia_shoulder_abduction') &&
      _completedTestsInSession.contains('ia_shoulder_extension') &&
      _completedTestsInSession.contains('ia_shoulder_adduction') &&
      _completedTestsInSession.contains('ia_rotation_externe') &&
      _completedTestsInSession.contains('ia_rotation_interne');

  // Liste des rendez-vous
  List<AppointmentModel> _appointments = [];
  List<AppointmentModel> get appointments => _appointments;

  bool _isAppointmentsInitialized = false;

  // Initialiser les rendez-vous si nécessaire
  Future<void> initializeAppointments({bool forceRefresh = false}) async {
    if (_isAppointmentsInitialized && !forceRefresh) return;

    final initialApps = await AppointmentService.fetchAppointments();
    _appointments = initialApps;
    _isAppointmentsInitialized = true;
    notifyListeners();
  }

  // Ajouter un rendez-vous
  void addAppointment(AppointmentModel appointment) {
    _appointments.insert(0, appointment); // Ajouter au début pour l'historique
    // Sauvegarder localement pour la persistance
    AppointmentService.saveAppointments(_appointments);
    notifyListeners();
  }

  // --- GESTION DES DISPONIBILITÉS ---
  List<AvailabilitySlot> _availabilitySlots = [];
  bool _isLoadingAvailability = false;

  List<AvailabilitySlot> get availabilitySlots => _availabilitySlots;
  bool get isLoadingAvailability => _isLoadingAvailability;

  Future<void> loadAvailabilities() async {
    _isLoadingAvailability = true;
    notifyListeners();
    _availabilitySlots = await AvailabilityService.getAvailabilities();
    _isLoadingAvailability = false;
    notifyListeners();
  }

  void addAvailabilitySlot(AvailabilitySlot slot) {
    _availabilitySlots.add(slot);
    AvailabilityService.saveAvailabilities(_availabilitySlots);
    notifyListeners();
  }

  void removeAvailabilitySlot(String id) {
    _availabilitySlots.removeWhere((s) => s.id == id);
    AvailabilityService.saveAvailabilities(_availabilitySlots);
    notifyListeners();
  }

  void updateAvailabilitySlot(AvailabilitySlot updatedSlot) {
    final index = _availabilitySlots.indexWhere((s) => s.id == updatedSlot.id);
    if (index != -1) {
      _availabilitySlots[index] = updatedSlot;
      AvailabilityService.saveAvailabilities(_availabilitySlots);
      notifyListeners();
    }
  }

  // Mettre à jour les informations du profil
  void setPatientInfo({
    required String pPrenom,
    required String pNom,
    double? pTaille,
    double? pPoids,
    String? pEmail,
    String? pPhone,
    List<MedicalDocument>? pHistory,
  }) {
    _profile = _profile.copyWith(
      fullName: "$pPrenom $pNom",
      height: pTaille,
      weight: pPoids,
      email: pEmail,
      phone: pPhone,
      medicalDocument: pHistory,
    );
    notifyListeners();
  }

  // Mettre à jour le profil (via Service)
  // Future<void> updateProfile(PatientModel newProfile) async {
  //   _profile = newProfile;
  //   notifyListeners();
  //   // Appel asynchrone au service pour simuler la sauvegarde
  //   await _userService.updateProfile(newProfile);
  // }

  // Liste des documents du dossier médical (Commence à zéro selon audio)
  final List<MedicalDocument> _medicalDocuments = [];
  List<MedicalDocument> get medicalDocuments => _medicalDocuments;

  // Calculer le nombre de documents par catégorie
  int getCountByCategory(String category) {
    return _medicalDocuments.where((doc) => doc.category == category).length;
  }

  // Ajouter un nouveau document
  void addMedicalDocument(MedicalDocument doc) {
    _medicalDocuments.insert(0, doc); // Plus récent en premier
    notifyListeners();
  }

  // Récupérer les exercices assignés par le spécialiste
  Future<void> fetchPatientExercises() async {
    final exercises = await SpecialistService.fetchMyExercises();
    _assignedExercises = exercises;
    notifyListeners();
  }

  // Mettre à jour le membre sélectionné
  void setMembre(String membre) {
    membreSelectionne = membre;
    notifyListeners();
  }

  // Ajouter aux contenus vus (si pas déjà présent)
  void addToViewed(ContentModel content) {
    if (!_viewedContent.any((c) => c.id == content.id)) {
      _viewedContent.insert(0, content); // Plus récent en premier
      notifyListeners();
    }
  }

  // Marquer un document comme vu
  void markDocumentAsViewed(String docId) {
    if (!_viewedDocumentIds.contains(docId)) {
      _viewedDocumentIds.add(docId);
      notifyListeners();
    }
  }

  // Mettre à jour l'exercice sélectionné
  void setExercise(ContentModel? exercise) {
    selectedExercise = exercise;
    if (exercise != null) {
      addToViewed(exercise);
      // Pré-initialiser la session avec l'exercice choisi
      currentSessionData = IATrackingData.fromContent(exercise);
    }
    notifyListeners();
  }

  // Configurer la session (ex: choix de la vue)
  // Vue détectée automatiquement par le CV — aucun paramètre obligatoire
  void configureSession({CameraView view = CameraView.front}) {
    if (currentSessionData != null) {
      currentSessionData!.selectedView = view;
      notifyListeners();
    }
  }

  GlobalDataProvider() {
    _loadTrackingHistory();
    // Initialiser des rendez-vous par défaut si besoin
    initializeAppointments();
    loadAvailabilities();
  }

  // --- PERSISTANCE DE L'HISTORIQUE IA ---

  Future<void> _saveTrackingHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      _trackingHistory.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('ia_tracking_history', encodedData);
  }

  Future<void> _loadTrackingHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('ia_tracking_history');

    if (encodedData != null) {
      final List<dynamic> decodedData = json.decode(encodedData);
      _trackingHistory.clear();
      _trackingHistory.addAll(
        decodedData.map<IATrackingData>((e) => IATrackingData.fromJson(e)).toList(),
      );
    } else {
      // Données mockées initiales avec IDs corrects pour l'analyse
      final now = DateTime.now();
      _trackingHistory.addAll([
        // --- SESSION 1 (Il y a 7 jours) ---
        // Épaule SAINE (Référence)
        IATrackingData(
          exerciseId: 'flexion',
          title: 'FLEXION D\'ÉPAULE',
          currentValue: 180.0,
          unit: '°',
          objective: 180.0,
          precision: 99.0,
          guidanceText: '',
          isHealthy: true,
          side: "Gauche",
          date: now.subtract(const Duration(days: 7)),
        ),
        // Épaule MALADE (Initial)
        IATrackingData(
          exerciseId: 'flexion',
          title: 'FLEXION D\'ÉPAULE',
          currentValue: 150.0,
          unit: '°',
          objective: 180.0,
          precision: 95.0,
          guidanceText: '',
          isHealthy: false,
          side: "Droite",
          painLevel: 6.0,
          date: now.subtract(const Duration(days: 7)),
        ),

        // --- SESSION 2 (AUJOURD'HUI) ---
        // Épaule MALADE (Progrès : 165° soit +15°)
        IATrackingData(
          exerciseId: 'flexion',
          title: 'FLEXION D\'ÉPAULE',
          currentValue: 165.0,
          unit: '°',
          objective: 180.0,
          precision: 98.0,
          guidanceText: 'Excellent progrès',
          isHealthy: false,
          side: "Droite",
          painLevel: 3.5,
          date: now,
        ),
        // Abduction MALADE (Progrès : 152° soit +2°)
        IATrackingData(
          exerciseId: 'abduction',
          title: 'ABDUCTION',
          currentValue: 152.0,
          unit: '°',
          objective: 180.0,
          precision: 94.0,
          guidanceText: '',
          isHealthy: false,
          side: "Droite",
          painLevel: 5.0,
          date: now,
        ),
        // Rotation externe MALADE (+12°)
        IATrackingData(
          exerciseId: 'rotation_externe',
          title: 'ROTATION EXTERNE',
          currentValue: 45.0,
          unit: '°',
          objective: 90.0,
          precision: 92.0,
          isHealthy: false,
          side: "Droite",
          painLevel: 4.0,
          date: now,
        ),
        IATrackingData(
          exerciseId: 'rotation_externe',
          title: 'ROTATION EXTERNE',
          currentValue: 33.0,
          unit: '°',
          objective: 90.0,
          isHealthy: false,
          side: "Droite",
          date: now.subtract(const Duration(days: 7)),
        ),
        // Rotation interne MALADE (+5°)
        IATrackingData(
          exerciseId: 'rotation_interne',
          title: 'ROTATION INTERNE',
          currentValue: 40.0,
          unit: '°',
          objective: 70.0,
          precision: 90.0,
          isHealthy: false,
          side: "Droite",
          date: now,
        ),
        IATrackingData(
          exerciseId: 'rotation_interne',
          title: 'ROTATION INTERNE',
          currentValue: 35.0,
          unit: '°',
          objective: 70.0,
          isHealthy: false,
          side: "Droite",
          date: now.subtract(const Duration(days: 7)),
        ),
        // Données Saines
        IATrackingData(
          exerciseId: 'abduction',
          title: 'ABDUCTION',
          currentValue: 175.0,
          unit: '°',
          objective: 180.0,
          precision: 99.0,
          isHealthy: true,
          side: "Gauche",
          date: now,
          guidanceText: '',
        ),
        IATrackingData(
          exerciseId: 'rotation_externe',
          title: 'ROTATION EXTERNE',
          currentValue: 85.0,
          unit: '°',
          objective: 90.0,
          isHealthy: true,
          side: "Gauche",
          date: now,
          precision: 0.0,
          guidanceText: '',
        ),
      ]);
      _saveTrackingHistory();
    }
    notifyListeners();
  }

  // Permet d'enregistrer le résultat final de la séance IA
  void saveIATrackingResult(IATrackingData result) {
    // Récupérer les 4 dernières valeurs d'angles et de douleur pour le graphique
    final List<double> historicalAngles = _trackingHistory.length >= 4
        ? _trackingHistory
              .sublist(_trackingHistory.length - 4)
              .map<double>((e) => e.currentValue.toDouble())
              .toList()
        : _trackingHistory.map<double>((e) => e.currentValue.toDouble()).toList();

    final List<double> historicalPain = _trackingHistory.length >= 4
        ? _trackingHistory
              .sublist(_trackingHistory.length - 4)
              .map<double>((e) => (e.painLevel ?? 0.0).toDouble())
              .toList()
        : _trackingHistory.map<double>((e) => (e.painLevel ?? 0.0).toDouble()).toList();

    // Ajouter la valeur actuelle à la fin
    historicalAngles.add(result.currentValue);
    historicalPain.add(result.painLevel ?? 0.0);

    // Créer un nouvel objet avec l'historique complet et toutes les métriques
    final enrichedResult = IATrackingData(
      exerciseId: result.exerciseId,
      title: result.title,
      currentValue: result.currentValue,
      unit: result.unit,
      objective: result.objective,
      precision: result.precision,
      guidanceText: result.guidanceText,
      angleHistory: historicalAngles,
      painHistory: historicalPain,
      painLevel: result.painLevel,
      date: result.date,
      sessionFrames: result.sessionFrames,
      trunkLeanAngle: result.trunkLeanAngle,
      elbowFlexion: result.elbowFlexion,
      isPostureCorrect: result.isPostureCorrect,
      shoulderImbalance: result.shoulderImbalance,
      repetitionCount: result.repetitionCount,
      totalRepsPlanned: result.totalRepsPlanned,
      avgTrunkLean: result.avgTrunkLean,
      maxTrunkLean: result.maxTrunkLean,
      minElbowFlexion: result.minElbowFlexion,
      avgShoulderImbalance: result.avgShoulderImbalance,
      aiSummary: result.aiSummary,
      side: result.side,
      isHealthy: result.isHealthy,
      remarks: result.remarks,
    );

    lastTrackingResult = enrichedResult;
    _trackingHistory.add(enrichedResult);

    // Marquer le test comme complété dans la session actuelle
    if (result.exerciseId != null &&
        !_completedTestsInSession.contains(result.exerciseId)) {
      _completedTestsInSession.add(result.exerciseId!);
    }

    _saveTrackingHistory();
    notifyListeners();
  }

  // Réinitialiser la session actuelle
  void resetCurrentSession() {
    _completedTestsInSession.clear();
    notifyListeners();
  }

  // Mettre à jour le niveau de douleur du dernier résultat
  void updateLastResultPain(double painLevel) {
    if (lastTrackingResult != null) {
      lastTrackingResult = IATrackingData(
        exerciseId: lastTrackingResult!.exerciseId,
        title: lastTrackingResult!.title,
        currentValue: lastTrackingResult!.currentValue,
        unit: lastTrackingResult!.unit,
        objective: lastTrackingResult!.objective,
        precision: lastTrackingResult!.precision,
        guidanceText: lastTrackingResult!.guidanceText,
        angleHistory: lastTrackingResult!.angleHistory,
        painHistory: lastTrackingResult!.painHistory,
        painLevel: painLevel,
        date: lastTrackingResult!.date,
        sessionFrames: lastTrackingResult!.sessionFrames,
        side: lastTrackingResult!.side,
        isHealthy: lastTrackingResult!.isHealthy,
        selectedView: lastTrackingResult!.selectedView,
        remarks: lastTrackingResult!.remarks,
      );

      // Mettre à jour aussi dans l'historique (le dernier élément)
      if (_trackingHistory.isNotEmpty) {
        _trackingHistory[_trackingHistory.length - 1] = lastTrackingResult!;
      }

      _saveTrackingHistory();
      notifyListeners();
    }
  }

  // Récupérer la valeur de la session précédente pour le même exercice
  double? getPreviousSessionValue(String? exerciseId) {
    if (exerciseId == null) return null;

    // Filtrer l'historique pour cet exercice
    final exerciseHistory = _trackingHistory
        .where((e) => e.exerciseId == exerciseId)
        .toList();

    // Si on a au moins 2 sessions, la précédente est l'avant-dernière
    if (exerciseHistory.length >= 2) {
      return exerciseHistory[exerciseHistory.length - 2].currentValue;
    }

    return null;
  }

  // Récupérer la dernière valeur enregistrée pour un type d'exercice (flexion, abduction, rotation)
  double? getLatestValueFor(String type) {
    try {
      final results = _trackingHistory
          .where(
            (e) =>
                e.exerciseId?.toLowerCase().contains(type.toLowerCase()) ??
                false,
          )
          .toList();
      if (results.isNotEmpty) {
        return results.last.currentValue;
      }
    } catch (e) {
      debugPrint("Error fetching latest value for $type: $e");
    }
    return null;
  }

  // Récupérer la valeur pour un exercice et un côté spécifique (Sain ou Patho)
  double? getValueForSide(String baseId, {required bool healthy}) {
    try {
      final results = _trackingHistory
          .where(
            (e) =>
                (e.exerciseId?.contains(baseId) ?? false) &&
                e.isHealthy == healthy,
          )
          .toList();
      if (results.isNotEmpty) {
        return results.last.currentValue;
      }
    } catch (e) {
      debugPrint("Error fetching value for $baseId (healthy: $healthy): $e");
    }
    return null;
  }
}
