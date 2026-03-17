import 'package:sahtek/core/api/endpoint.dart';
import 'package:sahtek/models/dashboard_models.dart';

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
}
