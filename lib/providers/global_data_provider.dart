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
  final List<IATrackingData> _trackingHistory = [];
  List<IATrackingData> get trackingHistory => _trackingHistory;

  // Résultat du dernier suivi IA en direct
  IATrackingData? lastTrackingResult;

  // Liste des rendez-vous
  List<AppointmentModel> _appointments = [];
  List<AppointmentModel> get appointments => _appointments;

  bool _isAppointmentsInitialized = false;

  // Initialiser les rendez-vous si nécessaire
  Future<void> initializeAppointments() async {
    if (!_isAppointmentsInitialized) {
      final initialApps = await AppointmentService.fetchAppointments();
      // Fusionner avec les rendez-vous ajoutés dynamiquement pendant l'initialisation
      _appointments = [..._appointments, ...initialApps];
      _isAppointmentsInitialized = true;
      notifyListeners();
    }
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
    }
    notifyListeners();
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
        decodedData.map((e) => IATrackingData.fromJson(e)).toList(),
      );
    } else {
      // Données mockées initiales si aucune donnée sauvegardée
      _trackingHistory.addAll([
        IATrackingData(
          title: 'FLEXION D\'ÉPAULE',
          currentValue: 95,
          unit: '°',
          objective: 180,
          precision: 95.0,
          guidanceText: '',
          angleHistory: [40, 60, 80, 95],
          painHistory: [8, 7, 7, 8],
          painLevel: 8.0,
          date: DateTime.now().subtract(const Duration(days: 28)),
        ),
        IATrackingData(
          title: 'FLEXION D\'ÉPAULE',
          currentValue: 110,
          unit: '°',
          objective: 180,
          precision: 96.0,
          guidanceText: '',
          angleHistory: [50, 80, 100, 110],
          painHistory: [7, 6, 6, 6.5],
          painLevel: 6.5,
          date: DateTime.now().subtract(const Duration(days: 21)),
        ),
        IATrackingData(
          title: 'FLEXION D\'ÉPAULE',
          currentValue: 125,
          unit: '°',
          objective: 180,
          precision: 97.5,
          guidanceText: '',
          angleHistory: [60, 90, 110, 125],
          painHistory: [6, 5, 5, 5],
          painLevel: 5.0,
          date: DateTime.now().subtract(const Duration(days: 14)),
        ),
        IATrackingData(
          title: 'FLEXION D\'ÉPAULE',
          currentValue: 135,
          unit: '°',
          objective: 180,
          precision: 98.0,
          guidanceText: '',
          angleHistory: [70, 100, 120, 135],
          painHistory: [5, 4, 3, 3.5],
          painLevel: 3.5,
          date: DateTime.now().subtract(const Duration(days: 7)),
          sessionFrames: [], 
        ),
      ]);
      _saveTrackingHistory(); // Sauvegarder les mock pour la première fois
    }
    notifyListeners();
  }

  // Permet d'enregistrer le résultat final de la séance IA
  void saveIATrackingResult(IATrackingData result) {
    // Récupérer les 4 dernières valeurs d'angles et de douleur pour le graphique
    final List<double> historicalAngles = _trackingHistory.length >= 4 
      ? _trackingHistory.sublist(_trackingHistory.length - 4).map((e) => e.currentValue).toList()
      : _trackingHistory.map((e) => e.currentValue).toList();
    
    final List<double> historicalPain = _trackingHistory.length >= 4 
      ? _trackingHistory.sublist(_trackingHistory.length - 4).map((e) => e.painLevel ?? 0.0).toList()
      : _trackingHistory.map((e) => e.painLevel ?? 0.0).toList();

    // Ajouter la valeur actuelle à la fin
    historicalAngles.add(result.currentValue);
    historicalPain.add(result.painLevel ?? 0.0);

    // Créer un nouvel objet avec l'historique complet
    final enrichedResult = IATrackingData(
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
    );

    lastTrackingResult = enrichedResult;
    _trackingHistory.add(enrichedResult);
    _saveTrackingHistory();
    notifyListeners();
  }

  // Mettre à jour le niveau de douleur du dernier résultat
  void updateLastResultPain(double painLevel) {
    if (lastTrackingResult != null) {
      lastTrackingResult = IATrackingData(
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
      );

      // Mettre à jour aussi dans l'historique (le dernier élément)
      if (_trackingHistory.isNotEmpty) {
        _trackingHistory[_trackingHistory.length - 1] = lastTrackingResult!;
      }

      _saveTrackingHistory();
      notifyListeners();
    }
  }
}
