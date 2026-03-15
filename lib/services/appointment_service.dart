import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sahtek/models/appointment_model.dart';

class AppointmentService {
  static const String _storageKey = 'saved_appointments';

  static Future<List<AppointmentModel>> fetchAppointments() async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 500));

    // Charger les rendez-vous persistés localement
    return await loadAppointments();
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
