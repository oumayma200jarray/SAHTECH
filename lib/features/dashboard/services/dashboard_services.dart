import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sahtek/core/api/endpoint.dart';
import 'package:sahtek/models/dashboard_models.dart';
import 'package:sahtek/models/content_model.dart';
import 'package:sahtek/features/profile/services/profile_service.dart';
import 'package:sahtek/models/doctor_models.dart';

class ChatService {
  /// Récupère la conversation complète depuis le backend
  static Future<ChatConversation> getConversation() async {
    try {
      final data = await EndPoint.client.get('/messages');
      debugPrint('💬 getConversation raw response: $data');
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

/*
  API endpoints used by SpecialistDashboardService and expected response shapes

  - EndPoint.doctorGetForms (GET)
    Purpose: fetch specialist dashboard statistics
    Typical response (Map<String, dynamic>):
    {
      "patientsCount": 42,            // int
      "unreadedcount": 3,            // int (unread messages/alerts)
      "doctorName": "Dr. Alice",   // optional String (may be named fullName)
      // ...other fields possibly present
    }

    Notes: the code prefers `doctorName`, falls back to `fullName`, then to 'Spécialiste'.

  - EndPoint.doctorGetPatients (GET)
    Purpose: return patients list for the doctor
    Possible response shapes:
      1) Map with array: { "patients": [ { ...patient fields... } ] }
      2) Direct list: [ { ...patient fields... } ]

    Patient item sample:
    {
      "id": "123",
      "user": { "fullName": "John Doe", "imageUrl": "..." },
      // or flattened fields like "fullName", "imageUrl"
    }

  - EndPoint.doctorAppointments (GET)
    Purpose: return appointments list. May be a direct list or wrapped object.
    Appointment item sample (possible shapes):
    {
      "appointmentId": 11,
      "AvailableSlot": { "date": "2026-05-07T10:00:00Z", "startTime": "...", "endTime": "...", "place": "..." },
      "patient": { "user": { "fullName": "Jane" } },
      // or flattened keys like "patientName", "date", etc.
    }

  - EndPoint.doctorMyPosts (GET / POST)
    Purpose: fetch or create doctor's posts. Typical fetch response shapes:
      { "posts": [ { "postId": "..", "title": "..", "description": "..", "type": "IMAGE|VIDEO|TEXT", "url": ".." } ] }
      or a direct list of post objects.

  Implementation guidance:
  - The service uses helper logic to accept both wrapped maps and direct lists.
  - If your backend uses different field names, update the keys below (`doctorName`, `fullName`, `patientsCount`, etc.).
*/

class SpecialistDashboardService {
  static List<dynamic> _extractList(dynamic response) {
    if (response is List<dynamic>) {
      return response;
    }

    if (response is Map<String, dynamic>) {
      final candidates = [
        response['data'],
        response['items'],
        response['results'],
        response['patients'],
        response['posts'],
        response['appointments'],
      ];

      for (final candidate in candidates) {
        if (candidate is List<dynamic>) {
          return candidate;
        }
      }
    }

    return const [];
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.now();
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DoctorAppointmentModel _mapAppointment(dynamic item) {
    final map = item is Map<String, dynamic> ? item : const <String, dynamic>{};
    final slot =
        map['AvailableSlot'] as Map<String, dynamic>? ??
        map['availableSlot'] as Map<String, dynamic>? ??
        const <String, dynamic>{};
    final patient =
        map['patient'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final patientUser =
        patient['user'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final clinic =
        (slot['clinic'] as Map<String, dynamic>?) ?? const <String, dynamic>{};

    return DoctorAppointmentModel(
      appointmentId: _readInt(map['appointmentId'] ?? map['id']),
      status: (map['status'] ?? 'SCHEDULED').toString(),
      reason: (map['reason'] ?? '').toString(),
      patientName: (patientUser['fullName'] ?? map['patientName'] ?? '')
          .toString(),
      patientImage: (patientUser['imageUrl'] ?? map['patientImage'])
          ?.toString(),
      clinicName: (clinic['name'] ?? map['clinicName'] ?? '').toString(),
      clinicAddress: (clinic['address'] ?? map['clinicAddress'] ?? '')
          .toString(),
      date: _parseDate(slot['date'] ?? map['date']),
      startTime: _parseDate(slot['startTime'] ?? map['startTime']),
      endTime: _parseDate(slot['endTime'] ?? map['endTime']),
      place: (slot['place'] ?? map['place'] ?? '').toString(),
    );
  }

  static ContentModel _mapPost(dynamic item) {
    final map = item is Map<String, dynamic> ? item : const <String, dynamic>{};
    final type = (map['type'] ?? '').toString().toUpperCase();
    final url = map['url']?.toString();

    return ContentModel(
      id: (map['postId'] ?? map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      description: map['description']?.toString(),
      imageUrl: type == 'IMAGE' ? url : null,
      videoUrl: type == 'VIDEO' ? url : null,
    );
  }

  /// Récupère les statistiques de performance du spécialiste
  static Future<SpecialistStats> getStats() async {
    try {
      final response = await EndPoint.client.get(EndPoint.doctorGetForms);
      debugPrint('📊 Dashboard stats response: $response');
      final data = response is Map<String, dynamic> ? response : {};

      // Attempt to resolve the doctor's display name.
      String? resolvedName = (data['doctorName'] ?? data['fullName'])
          ?.toString();

      // If the stats endpoint doesn't provide a name, fetch the profile as fallback.
      if (resolvedName == null || resolvedName.isEmpty) {
        try {
          final profile = await ProfileService.getSpecialistProfile();
          resolvedName = profile.fullName;
          debugPrint(
            '📌 Retrieved specialist name from profile: $resolvedName',
          );
        } catch (e) {
          debugPrint('ℹ️ Could not fetch specialist profile for name: $e');
        }
      }

      return SpecialistStats.fromJson({
        'totalPatients': data['patientsCount'] ?? 0,
        'patientGrowthPercent': 0.0,
        'adherencePercent': 0,
        'adherenceGrowthPercent': 0.0,
        'activeAlerts': data['unreadedcount'] ?? 0,
        'alertsGrowthPercent': 0.0,
        'doctorName': resolvedName ?? 'Spécialiste',
      });
    } catch (e) {
      debugPrint('❌ Error fetching dashboard stats: $e');
      return SpecialistStats.zero();
    }
  }

  /// Récupère la liste complète des patients du médecin
  static Future<List<DoctorPatientModel>> getAllPatients() async {
    try {
      final response = await EndPoint.client.get(EndPoint.doctorGetPatients);
      debugPrint('👥 getAllPatients raw response: $response');
      final data = response is Map<String, dynamic>
          ? (response['patients'] as List<dynamic>? ?? const [])
          : _extractList(response);
      debugPrint('👥 Patients response count: ${data.length}');
      return data.map((item) => DoctorPatientModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching patients: $e');
      return [];
    }
  }

  /// Récupère les rendez-vous du médecin
  static Future<List<DoctorAppointmentModel>> getDoctorAppointments() async {
    try {
      final response = await EndPoint.client.get(EndPoint.doctorAppointments);
      debugPrint('📅 getDoctorAppointments raw response: $response');
      final data = _extractList(response);
      debugPrint('📅 Appointments response count: ${data.length}');
      return data.map(_mapAppointment).toList();
    } catch (e) {
      debugPrint('❌ Error fetching appointments: $e');
      return [];
    }
  }

  /// Récupère les patients récents pour la vue dashboard
  static Future<List<DoctorPatientModel>> getRecentPatients() async {
    try {
      final patients = await getAllPatients();
      return patients.take(5).toList();
    } catch (e) {
      debugPrint('❌ Error fetching recent patients: $e');
      return [];
    }
  }

  /// Récupère les posts récents du médecin
  static Future<List<ContentModel>> getRecentDocuments() async {
    try {
      final response = await EndPoint.client.get(EndPoint.doctorMyPosts);
      debugPrint('📄 getRecentDocuments raw response: $response');
      final data = response is Map<String, dynamic>
          ? (response['posts'] as List<dynamic>? ?? const [])
          : _extractList(response);
      debugPrint('📄 Posts response count: ${data.length}');
      return data.map(_mapPost).toList();
    } catch (e) {
      debugPrint('❌ Error fetching recent documents: $e');
      return [];
    }
  }

  static Future<bool> publishDocument({
    required String title,
    required String description,
    required String type,
    required File file,
  }) async {
    try {
      final response = await EndPoint.client.post(
        EndPoint.doctorMyPosts,
        body: {
          'title': title,
          'description': description,
          'type': type,
          'file': file,
        },
      );
      debugPrint('📤 publishDocument response: $response');
      return response is Map<String, dynamic> && response['postId'] != null;
    } catch (e) {
      debugPrint('❌ Error publishing document: $e');
      return false;
    }
  }

  static Future<bool> deletePost(String postId) async {
    try {
      await EndPoint.client.delete(EndPoint.doctorDeletePost(postId));
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting post: $e');
      return false;
    }
  }
}
