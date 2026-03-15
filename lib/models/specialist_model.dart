class SpecialistModel {
  final String id;
  final String name;
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
    required this.id,
    required this.name,
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
}
