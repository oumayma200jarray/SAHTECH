import 'package:flutter/foundation.dart';

/// Tracks the number of unseen new-appointment notifications for the doctor.
/// Increment on socket event; reset when the doctor opens the Appointments screen.
class AppointmentNotifier extends ChangeNotifier {
  int _newCount = 0;

  int get newCount => _newCount;

  void increment() {
    _newCount++;
    notifyListeners();
  }

  void reset() {
    if (_newCount == 0) return;
    _newCount = 0;
    notifyListeners();
  }
}
