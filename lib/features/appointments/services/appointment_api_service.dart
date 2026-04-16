import 'package:sahtek/core/api/endpoint.dart';
import 'package:sahtek/core/api/http_client.dart';

class AvailableAppointmentSlot {
  static const int _manualHourOffset = 1;

  final String availabilityId;
  final DateTime date;
  final String? rawDate;
  final String startTime;
  final String endTime;
  final String place;

  const AvailableAppointmentSlot({
    required this.availabilityId,
    required this.date,
    this.rawDate,
    required this.startTime,
    required this.endTime,
    required this.place,
  });

  factory AvailableAppointmentSlot.fromJson(Map<String, dynamic> json) {
    final parsedRawDate = json['date']?.toString();
    final parsedDate =
        (parsedRawDate != null ? DateTime.tryParse(parsedRawDate) : null) ??
        DateTime.now();
    return AvailableAppointmentSlot(
      availabilityId: (json['availabilityId'] ?? '').toString(),
      date: parsedDate,
      rawDate: parsedRawDate,
      startTime: (json['startTime'] ?? '').toString(),
      endTime: (json['endTime'] ?? '').toString(),
      place: (json['place'] ?? '').toString(),
    );
  }

  // Keep a stable YYYY-MM-DD key from server date payload to avoid timezone day shifts.
  String get dateKey {
    final raw = rawDate;
    if (raw != null && raw.isNotEmpty) {
      final isoLike = RegExp(r'^\d{4}-\d{2}-\d{2}');
      if (isoLike.hasMatch(raw)) {
        return raw.substring(0, 10);
      }

      final parsedRaw = DateTime.tryParse(raw);
      if (parsedRaw != null) {
        return '${parsedRaw.year.toString().padLeft(4, '0')}-${parsedRaw.month.toString().padLeft(2, '0')}-${parsedRaw.day.toString().padLeft(2, '0')}';
      }
    }

    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Some backends send full datetime in startTime; use it first for grouping by day.
  String get effectiveDateKey {
    final fromStart = _extractDateKey(startTime);
    if (fromStart != null) return fromStart;

    final fromEnd = _extractDateKey(endTime);
    if (fromEnd != null) return fromEnd;

    return dateKey;
  }

  String? _extractDateKey(String raw) {
    if (raw.isEmpty) return null;

    final isoLike = RegExp(r'^\d{4}-\d{2}-\d{2}');
    if (isoLike.hasMatch(raw)) {
      return raw.substring(0, 10);
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return null;
    final shifted = _applyOffset(parsed);
    return '${shifted.year.toString().padLeft(4, '0')}-${shifted.month.toString().padLeft(2, '0')}-${shifted.day.toString().padLeft(2, '0')}';
  }

  DateTime get localDay {
    final parts = dateKey.split('-');
    if (parts.length == 3) {
      final year = int.tryParse(parts[0]) ?? date.year;
      final month = int.tryParse(parts[1]) ?? date.month;
      final day = int.tryParse(parts[2]) ?? date.day;
      return DateTime(year, month, day);
    }
    return DateTime(date.year, date.month, date.day);
  }

  int get _startHour {
    final parsed = _extractHourMinute(startTime);
    if (parsed != null) return parsed.$1;
    return 0;
  }

  int get startMinutes {
    final parsed = _extractHourMinute(startTime);
    final hour = parsed?.$1 ?? 0;
    final minute = parsed?.$2 ?? 0;
    return (hour * 60) + minute;
  }

  String get displayStartTime {
    final extracted = _extractTime(startTime);
    if (extracted != null) return extracted;

    final extractedFromEnd = _extractTime(endTime);
    if (extractedFromEnd != null) return extractedFromEnd;

    return startTime;
  }

  String? _extractTime(String raw) {
    if (raw.isEmpty) return null;

    final hmPattern = RegExp(r'(\d{2}:\d{2})');
    final hmMatch = hmPattern.firstMatch(raw);
    if (hmMatch != null && !raw.contains('T')) {
      final time = hmMatch.group(1)!;
      final parts = time.split(':');
      if (parts.length < 2) return time;
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      final shiftedHour = (hour + _manualHourOffset) % 24;
      return '${shiftedHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return null;
    final shifted = _applyOffset(parsed);
    return '${shifted.hour.toString().padLeft(2, '0')}:${shifted.minute.toString().padLeft(2, '0')}';
  }

  DateTime _applyOffset(DateTime input) {
    return input.add(const Duration(hours: _manualHourOffset));
  }

  (int, int)? _extractHourMinute(String raw) {
    final time = _extractTime(raw);
    if (time == null || !time.contains(':')) return null;
    final parts = time.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return (hour, minute);
  }

  bool get isMorning => _startHour < 12;

  bool matchesConsultationType(bool isPresentiel) {
    final normalized = place.toLowerCase();
    final isCabinet =
        normalized.contains('cabinet') ||
        normalized.contains('presentiel') ||
        normalized.contains('présentiel') ||
        normalized.contains('clinic');
    final isVideo =
        normalized.contains('video') ||
        normalized.contains('distance') ||
        normalized.contains('tele') ||
        normalized.contains('online');

    if (isPresentiel) {
      return isCabinet || (!isCabinet && !isVideo);
    }

    return isVideo;
  }
}

class AppointmentApiService {
  static Future<List<AvailableAppointmentSlot>> fetchAvailableSlots(
    String specialistId,
  ) async {
    try {
      final dynamic data = await EndPoint.client.get(
        EndPoint.availableSlots(specialistId),
      );

      if (data is! List) {
        return [];
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(AvailableAppointmentSlot.fromJson)
          .toList();
    } on ApiException catch (e) {
      if (e.statusCode == 409 || e.statusCode == 404) {
        return [];
      }
      rethrow;
    }
  }

  static Future<void> createApointment({
    required String specialistId,
    required String availabilityId,
    String reason = '',
  }) async {
    await EndPoint.client.post(
      EndPoint.createApointment,
      body: {
        'specialistId': specialistId,
        'availabilityId': availabilityId,
        'reason': reason,
      },
    );
  }
}
