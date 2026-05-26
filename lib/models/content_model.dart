/// Modèle de données générique pour représenter du contenu (Vidéos, Articles, Tests IA).
/// Ce modèle est conçu pour être facilement instancié à partir de données JSON
/// provenant du backend.
class ContentModel {
  /// Identifiant unique du contenu
  final String id;

  /// Titre principal (ex: "Mobilité de la coiffe", "Flexion de l'épaule")
  final String title;

  /// Description détaillée (utilisée par exemple dans les cartes de Test IA)
  final String? description;

  /// Sous-titre court (ex: "Plan sagittal" pour les Tests IA)
  final String? subtitle;

  /// URL de l'image d'illustration ou de la miniature vidéo (optionnel)
  final String? imageUrl;

  /// URL de la vidéo d'exercice (optionnel)
  final String? videoUrl;

  /// Catégories (enum keys) associées à l'exercice
  final List<String> categories;

  /// Side values (enum keys) e.g. BACK, FRONT
  final List<String> sides;

  /// Specialist who created/shared the exercise
  final String? specialistName;

  /// Specialist avatar/image URL
  final String? specialistImageUrl;

  /// Auteur ou créateur du contenu (ex: "Par Dr. Sarah Miller")
  final String? author;

  /// Durée (format chaîne de caractères, ex: "4:30")
  final String? duration;

  /// Type d'exercice (ex: "rotation", "flexion", "abduction")
  final String? exerciseType;

  /// Vue caméra requise (ex: "face", "profil")
  final String? requiredView;

  /// Constructeur principal
  ContentModel({
    required this.id,
    required this.title,
    this.description,
    this.subtitle,
    this.imageUrl,
    this.videoUrl,
    this.author,
    this.duration,
    this.exerciseType,
    this.requiredView,
    this.categories = const [],
    this.sides = const [],
    this.specialistName,
    this.specialistImageUrl,
  });

  /// Méthode (factory) pour créer une instance de [ContentModel] à partir d'un objet JSON.
  /// Modèle très utile pour désérialiser la réponse de l'API backend.
  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      // Support both 'exerciseId' and generic 'id'
      id: (json['exerciseId'] ?? json['id'])?.toString() ?? '',
      // Support 'name' or old 'title'
      title: (json['name'] ?? json['title'])?.toString() ?? '',
      description: json['description']?.toString(),
      subtitle: json['subtitle']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      videoUrl: json['videoUrl']?.toString(),
      author: json['author']?.toString(),
      duration: json['duration']?.toString(),
      exerciseType: json['exerciseType']?.toString(),
      requiredView: json['requiredView']?.toString(),
      categories: (json['category'] is List)
          ? List<String>.from(json['category'].map((e) => e.toString()))
          : (json['categories'] is List)
          ? List<String>.from(json['categories'].map((e) => e.toString()))
          : <String>[],
      sides: (json['side'] is List)
          ? List<String>.from(json['side'].map((e) => e.toString()))
          : (json['sides'] is List)
          ? List<String>.from(json['sides'].map((e) => e.toString()))
          : <String>[],
      specialistName: json['specialist']?['user']?['fullName']?.toString(),
      specialistImageUrl: json['specialist']?['user']?['imageUrl']?.toString(),
    );
  }
}
