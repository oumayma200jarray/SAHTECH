import 'package:sahtek/core/api/endpoint.dart';
import 'package:sahtek/models/clinic_model.dart';

class DoctorApiService {
  // ─── Daily Slots ────────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getDailySlots() async {
    final data = await EndPoint.client.get(EndPoint.doctorDailySlots);
    if (data == null) return [];
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().map((item) {
        final clinic = (item['clinic'] as Map?)?.cast<String, dynamic>() ?? {};
        return {
          ...item,
          'clinicId': (clinic['clinicId'] ?? clinic['id'] ?? '').toString(),
          'clinicName': (clinic['name'] ?? '').toString(),
        };
      }).toList();
    }
    return [];
  }

  static Future<void> createDailySlots(Map<String, dynamic> payload) async {
    await EndPoint.client.post(EndPoint.doctorDailySlots, body: payload);
  }

  static Future<void> updateDailySlots(
    String id,
    Map<String, dynamic> payload,
  ) async {
    await EndPoint.client.patch(EndPoint.doctorUpdateSlot(id), body: payload);
  }

  static Future<void> deleteDailySlots(String id) async {
    await EndPoint.client.delete(EndPoint.doctorUpdateSlot(id));
  }

  // ─── Appointments ───────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getAppointments() async {
    final data = await EndPoint.client.get(EndPoint.doctorAppointments);
    if (data == null) return [];
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  static Future<void> modifyAppointment(
    String appointmentId,
    Map<String, dynamic> body,
  ) async {
    await EndPoint.client.patch(
      EndPoint.doctorUpdateAppointment(appointmentId),
      body: body,
    );
  }

  // ─── Clinics ────────────────────────────────────────────────────────────
  static Future<List<ClinicModel>> getClinics() async {
    try {
      final data = await EndPoint.client.get(EndPoint.getAllClinics);
      if (data == null) return [];
      final list = (data is Map) ? data['data'] : data;
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(ClinicModel.fromJson)
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<List<ClinicModel>> getDoctorClinics() async {
    try {
      final data = await EndPoint.client.get(EndPoint.doctorClinics);
      if (data == null) return [];
      final list = (data is Map) ? data['data'] : data;
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(ClinicModel.fromJson)
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<ClinicModel> createClinic(Map<String, dynamic> body) async {
    final data = await EndPoint.client.post(EndPoint.doctorClinics, body: body);
    return ClinicModel.fromJson(data as Map<String, dynamic>);
  }
}
