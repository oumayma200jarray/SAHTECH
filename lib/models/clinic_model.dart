class ClinicModel {
  final String clinicId;
  final String name;
  final String address;
  final String phone;
  final String email;

  const ClinicModel({
    required this.clinicId,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
      clinicId: json['clinicId']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'phone': phone,
        'email': email,
      };
}

/// Lightweight object returned inside the specialist profile response.
class PrimaryClinic {
  final String clinicId;
  final String name;
  final String address;

  const PrimaryClinic({
    required this.clinicId,
    required this.name,
    required this.address,
  });

  factory PrimaryClinic.fromJson(Map<String, dynamic> json) {
    return PrimaryClinic(
      clinicId: json['clinicId']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
    );
  }
}
