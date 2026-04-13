import 'dart:io';
import 'package:sahtek/core/api/endpoint.dart';
import 'package:sahtek/models/dashboard_models.dart';
import 'package:sahtek/models/content_model.dart';

class AdminService {
  /// Récupère les statistiques globales pour l'administrateur
  static Future<AdminStats> getStats() async {
    try {
      final data = await EndPoint.client.get('/admin/stats');
      return AdminStats.fromJson(data);
    } catch (_) {}
    // Retourne des stats à zéro si le serveur est injoignable
    return AdminStats(
      totalPatients: '0',
      totalSpecialists: '0',
      pendingValidations: '0',
      flaggedContent: '0',
    );
  }

  /// Récupère la liste des spécialistes en attente de validation
  static Future<List<SpecialistValidation>> getPendingValidations() async {
    try {
      final List<dynamic> data = await EndPoint.client.get('/admin/validations');
      return data.map((item) => SpecialistValidation.fromJson(item)).toList();
    } catch (_) {}
    return []; // Liste vide si erreur
  }
}

class ChatService {
  /// Récupère la conversation complète depuis le backend
  static Future<ChatConversation> getConversation() async {
    try {
      final data = await EndPoint.client.get('/messages');
      return ChatConversation.fromJson(data);
    } catch (_) {}
    return getMockConversation(); // Fallback sur les mocks si erreur
  }

  static ChatConversation getMockConversation() {
    return ChatConversation(
      doctorName: 'Médecin',
      specialty: 'Spécialiste',
      doctorImageUrl: 'https://i.pravatar.cc/150?u=doc',
      messages: [],
    );
  }
}

class SpecialistDashboardService {
  /// Récupère les statistiques de performance du spécialiste
  static Future<SpecialistStats> getStats() async {
    try {
      final data = await EndPoint.client.get('/specialist/stats');
      return SpecialistStats.fromJson(data);
    } catch (_) {}
    return SpecialistStats.zero(); // Retourne 0 et "Chargement..." si erreur
  }

  /// Récupère les rendez-vous prévus pour aujourd'hui
  static Future<List<SpecialistAppointment>> getTodaysAppointments() async {
    try {
      final List<dynamic> data = await EndPoint.client.get('/specialist/appointments/today');
      return data.map((item) => SpecialistAppointment.fromJson(item)).toList();
    } catch (_) {}
    return []; // Retourne une liste vide si erreur
  }

  /// Récupère la liste des patients récemment suivis
  static Future<List<PatientFollowUp>> getRecentPatients() async {
    // Dans une version réelle, ceci appellerait l'API
    // Simulation pour le prototype
    return [
      PatientFollowUp(
        name: 'Jean Dupont',
        zone: 'Épaule (Flexion)',
        romProgress: 85,
        growth: 12.5,
        imageUrl: 'https://i.pravatar.cc/150?u=jean',
      ),
      PatientFollowUp(
        name: 'Marie Curie',
        zone: 'Genou',
        romProgress: 65,
        growth: -5.0,
        imageUrl: 'https://i.pravatar.cc/150?u=marie',
      ),
    ];
  }

  // --- NOUVELLES FONCTIONNALITÉS ---
  static final List<ContentModel> _mockedRecentDocuments = [
    ContentModel(
      id: 'doc1',
      title: 'Comprendre l\'arthrose du genou',
      videoUrl: 'https://example.com/video1.mp4',
    ),
    ContentModel(
      id: 'doc2',
      title: 'Exercices d\'épaule (Niveau 1)',
      videoUrl: null, // Article
    ),
  ];

  static Future<List<ContentModel>> getRecentDocuments() async {
    try {
      final List<dynamic> data = await EndPoint.client.get('/specialist/documents/recent');
      return data.map((item) => ContentModel.fromJson(item)).toList();
    } catch (_) {}
    return _mockedRecentDocuments; // Restitution de mock
  }

  static Future<bool> publishDocument({
    required String title,
    required String description,
    required String type,
    required File file,
  }) async {
    // Dans une version réelle, on utiliserait MultipartRequest
    await Future.delayed(const Duration(seconds: 1)); // Simule l'upload

    final newDoc = ContentModel(
      id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      videoUrl: type == 'Video' ? 'https://example.com/new_video.mp4' : null,
    );

    // Ajout local en tant que mock
    _mockedRecentDocuments.insert(0, newDoc);

    return true; // Succès
  }
}
