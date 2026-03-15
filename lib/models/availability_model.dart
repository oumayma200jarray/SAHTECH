enum AvailabilityType { cabinet, video }

class AvailabilitySlot {
  final String id;
  final int dayOfWeek; // 1 (Mon) to 7 (Sun)
  final String startTime; // "08:30"
  final String endTime; // "11:30"
  final AvailabilityType type;

  AvailabilitySlot({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.type,
  });

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlot(
      id: json['id'],
      dayOfWeek: json['dayOfWeek'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      type: AvailabilityType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
        'type': type.toString().split('.').last,
      };

  AvailabilitySlot copyWith({
    String? id,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    AvailabilityType? type,
  }) {
    return AvailabilitySlot(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
    );
  }
}
