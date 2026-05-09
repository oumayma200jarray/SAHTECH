import 'package:sahtek/core/api/endpoint.dart';

class DoctorApiService {
  static Future<List<Map<String, dynamic>>> getDailySlots() async {
    final data = await EndPoint.client.get(EndPoint.doctorDailySlots);
    if (data == null) return [];
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
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
}
