import 'package:sahtek/core/api/endpoint.dart';
import 'package:sahtek/models/content_model.dart';

class FavoritePostsService {
  static Future<List<ContentModel>> getFavoritePosts() async {
    final List<dynamic> response = await EndPoint.client.get(
      EndPoint.favoritePosts,
    );

    return response
        .whereType<Map<String, dynamic>>()
        .map(_fromFavoritePostJson)
        .toList();
  }

  static Future<void> addFavoritePost(String postId) async {
    await EndPoint.client.post(EndPoint.favoritePost(postId));
  }

  static Future<void> removeFavoritePost(String postId) async {
    await EndPoint.client.delete(EndPoint.favoritePost(postId));
  }

  static ContentModel _fromFavoritePostJson(Map<String, dynamic> json) {
    final specialist = json['specialist'] as Map<String, dynamic>?;
    final user = specialist?['user'] as Map<String, dynamic>?;
    final type = (json['type'] ?? '').toString().toLowerCase();
    final mediaUrl = (json['url'] ?? '').toString();

    return ContentModel(
      id: (json['postId'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      subtitle: (user?['fullName'] ?? '').toString(),
      imageUrl: type.contains('video') ? null : mediaUrl,
      videoUrl: type.contains('video') ? mediaUrl : null,
      author: (user?['fullName'] ?? '').toString(),
    );
  }
}
