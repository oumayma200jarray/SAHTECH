import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sahtek/core/api/endpoint.dart';
import 'package:sahtek/models/appointment_model.dart';

class AppointmentService {
  static const String _storageKey = 'saved_appointments';

  static Future<List<AppointmentModel>> fetchAppointments() async {
    try {
      final dynamic data = await EndPoint.client.get(EndPoint.appointments);
      if (data is! List) {
        return loadAppointments();
      }

      final appointments = data
          .whereType<Map<String, dynamic>>()
          .map(_fromBackendJson)
          .toList();

      await saveAppointments(appointments);
      return appointments;
    } catch (_) {
      // Fallback to local cache when API fails.
      return loadAppointments();
    }
  }

  static AppointmentModel _fromBackendJson(Map<String, dynamic> json) {
    final slot =
        (json['AvailableSlot'] as Map<String, dynamic>?) ??
        (json['availableSlot'] as Map<String, dynamic>?) ??
        <String, dynamic>{};
    final specialist =
        (json['specialist'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final user =
        (specialist['user'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    final String rawDate = (slot['date'] ?? '').toString();
    final String rawStartTime = (slot['startTime'] ?? '').toString();
    final DateTime appointmentDateTime = _buildAppointmentDateTime(
      rawDate,
      rawStartTime,
    );

    return AppointmentModel(
      id: (json['appointmentId'] ?? json['id'] ?? '').toString(),
      specialistName: (user['fullName'] ?? '').toString(),
      specialty:
          (specialist['speciality'] ??
                  specialist['specialty'] ??
                  slot['place'] ??
                  'Consultation')
              .toString(),
      date: DateTime(
        appointmentDateTime.year,
        appointmentDateTime.month,
        appointmentDateTime.day,
      ),
      time:
          '${appointmentDateTime.hour.toString().padLeft(2, '0')}:${appointmentDateTime.minute.toString().padLeft(2, '0')}',
      status: _normalizeStatus((json['status'] ?? 'SCHEDULED').toString()),
      type: _appointmentTypeFromPlace((slot['place'] ?? '').toString()),
      imageUrl: (user['imageUrl'] ?? '').toString(),
    );
  }

  static String _normalizeStatus(String raw) {
    final normalized = raw.trim().toUpperCase();
    switch (normalized) {
      case 'SCHEDULED':
      case 'ACEPTED':
      case 'ACCEPTED':
      case 'REJECTED':
      case 'COMPLETED':
      case 'CANCELLED':
        return normalized == 'ACCEPTED' ? 'ACEPTED' : normalized;
      case 'CONFIRME':
      case 'CONFIRMÉ':
        return 'ACEPTED';
      case 'EN ATTENTE':
      case 'PENDING':
        return 'SCHEDULED';
      case 'ANNULE':
      case 'ANNULÉ':
        return 'CANCELLED';
      default:
        return 'SCHEDULED';
    }
  }

  static DateTime _buildAppointmentDateTime(
    String rawDate,
    String rawStartTime,
  ) {
    final startParsed = DateTime.tryParse(rawStartTime);
    if (startParsed != null) {
      final startLocal = startParsed.toLocal();
      return DateTime(
        startLocal.year,
        startLocal.month,
        startLocal.day,
        startLocal.hour,
        startLocal.minute,
      );
    }

    final dateParsed = DateTime.tryParse(rawDate);
    final baseDate = (dateParsed ?? DateTime.now()).toLocal();

    final timeMatch = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(rawStartTime);
    final hour = timeMatch != null ? int.tryParse(timeMatch.group(1)!) ?? 0 : 0;
    final minute = timeMatch != null
        ? int.tryParse(timeMatch.group(2)!) ?? 0
        : 0;

    return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
  }

  static String _appointmentTypeFromPlace(String place) {
    final normalized = place.toLowerCase();
    if (normalized.contains('video') ||
        normalized.contains('distance') ||
        normalized.contains('tele') ||
        normalized.contains('online')) {
      return 'Téléconsultation';
    }
    return 'Présentiel';
  }

  static Future<void> saveAppointments(
    List<AppointmentModel> appointments,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      appointments.map((app) => app.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encodedData);
  }

  static Future<List<AppointmentModel>> loadAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_storageKey);

    if (encodedData == null || encodedData.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decodedData = jsonDecode(encodedData);
      return decodedData
          .map((item) => AppointmentModel.fromJson(item))
          .toList();
    } catch (e) {
      print('Erreur lors du chargement des rendez-vous : $e');
      return [];
    }
  }
}
