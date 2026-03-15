class PatientProfile {
  final String fullName;
  final String email;
  final String phone;
  final double weight;
  final double height;
  final String medicalHistory;
  final String imageUrl;

  PatientProfile({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.weight,
    required this.height,
    required this.medicalHistory,
    required this.imageUrl,
  });

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      weight: (json['weight'] ?? 0.0).toDouble(),
      height: (json['height'] ?? 0.0).toDouble(),
      medicalHistory: json['medicalHistory'] ?? '',
      imageUrl: json['imageUrl'] ?? 'https://i.pravatar.cc/150?u=jean',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'weight': weight,
      'height': height,
      'medicalHistory': medicalHistory,
      'imageUrl': imageUrl,
    };
  }

  PatientProfile copyWith({
    String? fullName,
    String? email,
    String? phone,
    double? weight,
    double? height,
    String? medicalHistory,
    String? imageUrl,
  }) {
    return PatientProfile(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory PatientProfile.empty() {
    return PatientProfile(
      fullName: '',
      email: '',
      phone: '',
      weight: 0.0,
      height: 0.0,
      medicalHistory: '',
      imageUrl: 'https://i.pravatar.cc/150?u=jean',
    );
  }
}
