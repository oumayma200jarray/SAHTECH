import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sahtek/models/availability_model.dart';

class AvailabilityService {
  static const String _storageKey = 'specialist_availabilities';

  static Future<List<AvailabilitySlot>> getAvailabilities() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    
    if (data == null) {
      // Return some default mock data if empty
      return [
        AvailabilitySlot(
          id: '1',
          dayOfWeek: 1, // Lundi
          startTime: '08:30',
          endTime: '11:30',
          type: AvailabilityType.cabinet,
        ),
        AvailabilitySlot(
          id: '2',
          dayOfWeek: 2, // Mardi
          startTime: '14:00',
          endTime: '18:00',
          type: AvailabilityType.video,
        ),
        AvailabilitySlot(
          id: '3',
          dayOfWeek: 4, // Jeudi
          startTime: '09:00',
          endTime: '12:00',
          type: AvailabilityType.cabinet,
        ),
      ];
    }

    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => AvailabilitySlot.fromJson(e)).toList();
  }

  static Future<void> saveAvailabilities(List<AvailabilitySlot> slots) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(slots.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
