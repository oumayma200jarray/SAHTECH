class SpecialistModel {
  final String userId;
  final String fullName;
  final String gender;
  final String specialty;
  final String clinic;
  final String location;
  final double rating;
  final int reviewsCount;
  final String imageUrl;
  final double distance;
  final String availability; // Ex: 'Dispo demain'
  final double latitude;
  final double longitude;

  SpecialistModel({
    required this.userId,
    required this.fullName,
    required this.gender,
    required this.specialty,
    required this.clinic,
    required this.location,
    required this.rating,
    required this.reviewsCount,
    required this.imageUrl,
    required this.distance,
    required this.availability,
    required this.latitude,
    required this.longitude,
  });
  factory SpecialistModel.fromJson(Map<String, dynamic> json) {
  return SpecialistModel(
    userId: json['userId'] ?? '',
    fullName: json['fullName'] ?? '',
    gender: json['gender'] ?? '',
    specialty: json['specialist']?['speciality'] ?? '',
    clinic: json['specialist']?['clinic'] ?? '',
    location: json['specialist']?['location'] ?? '',
    rating: (json['specialist']?['rating'] ?? 0.0).toDouble(),
    reviewsCount: json['specialist']?['reviewsCount'] ?? 0,
    imageUrl: json['imageUrl'] ?? '',
    latitude: (json['specialist']?['latitude'] ?? 0.0).toDouble(),
    longitude: (json['specialist']?['longitude'] ?? 0.0).toDouble(),
    distance: 0.0, // calculated on frontend using device location
    availability: json['specialist']?['availability'] ?? '',
  );
}

Map<String, dynamic> toJson() {
  return {
    'userId': userId,
    'fullName': fullName,
    'gender': gender,
    'imageUrl': imageUrl,
    'specialist': {
      'speciality': specialty,
      'clinic': clinic,
      'location': location,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'latitude': latitude,
      'longitude': longitude,
    },
  };
}
}
