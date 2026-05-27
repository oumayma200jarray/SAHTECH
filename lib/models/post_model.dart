class PostModel {
  final String postId;
  final String title;
  final String description;
  final String type;
  final String? url;
  final bool isPublished;
  final DateTime? createdAt;

  const PostModel({
    required this.postId,
    required this.title,
    required this.description,
    required this.type,
    this.url,
    required this.isPublished,
    this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      postId: (json['postId'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      type: (json['type'] ?? 'ARTICLE').toString().toUpperCase(),
      url: json['url']?.toString(),
      isPublished: json['isPublished'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
