class MedicalDocument {
  final String id;
  final String title;
  final DateTime date;
  final String type; // 'PDF', 'Image'
  final String category; // 'Radiographies', 'Prescriptions', etc.
  final String fileUrl;

  MedicalDocument({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    required this.category,
    required this.fileUrl,
  });

  factory MedicalDocument.fromJson(Map<String, dynamic> json) {
    return MedicalDocument(
      id: json['id'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      type: json['type'],
      category: json['category'],
      fileUrl: json['fileUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'type': type,
      'category': category,
      'fileUrl': fileUrl,
    };
  }
}
