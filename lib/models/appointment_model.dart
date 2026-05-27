class AppointmentModel {
  final String id;
  final String specialistName;
  final String specialty;
  final String clinicName;
  final String clinicAddress;
  final DateTime date;
  final String time;
  final String status; // 'Confirmé', 'En attente', 'Annulé'
  final String type; // 'Présentiel', 'Téléconsultation'
  final String imageUrl;

  AppointmentModel({
    required this.id,
    required this.specialistName,
    required this.specialty,
    this.clinicName = '',
    this.clinicAddress = '',
    required this.date,
    required this.time,
    required this.status,
    required this.type,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'specialistName': specialistName,
      'specialty': specialty,
      'clinicName': clinicName,
      'clinicAddress': clinicAddress,
      'date': date.toIso8601String(),
      'time': time,
      'status': status,
      'type': type,
      'imageUrl': imageUrl,
    };
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      specialistName: json['specialistName'],
      specialty: json['specialty'],
      clinicName: json['clinicName'] ?? '',
      clinicAddress: json['clinicAddress'] ?? '',
      date: DateTime.parse(json['date']),
      time: json['time'],
      status: json['status'],
      type: json['type'],
      imageUrl: json['imageUrl'],
    );
  }
}
