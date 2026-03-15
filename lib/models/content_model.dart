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

  /// Auteur ou créateur du contenu (ex: "Par Dr. Sarah Miller")
  final String? author;

  /// Durée (format chaîne de caractères, ex: "4:30")
  final String? duration;

  /// Type d'exercice (ex: "rotation", "flexion", "abduction")
  final String? exerciseType;

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
  });

  /// Méthode (factory) pour créer une instance de [ContentModel] à partir d'un objet JSON.
  /// Modèle très utile pour désérialiser la réponse de l'API backend.
  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      // Si 'id' est null, on renvoie une chaîne vide par défaut
      id: json['id']?.toString() ?? '',
      // Si 'title' est null, on renvoie une chaîne vide
      title: json['title'] ?? '',
      description: json['description'],
      subtitle: json['subtitle'],
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      author: json['author'],
      duration: json['duration'],
      exerciseType: json['exerciseType'],
    );
  }
}
