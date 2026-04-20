import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sahtek/core/api/http_client.dart';
import 'package:sahtek/core/utils/url_helper.dart';
import 'package:sahtek/features/content_library/services/favorite_posts_service.dart';
import 'package:sahtek/models/content_model.dart';
import 'package:easy_localization/easy_localization.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<List<ContentModel>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = FavoritePostsService.getFavoritePosts();
  }

  void _reloadFavorites() {
    setState(() {
      _favoritesFuture = FavoritePostsService.getFavoritePosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'my_favorites'.tr(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<ContentModel>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('error_loading'.tr()));
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return _buildEmptyState('no_favorites'.tr());
          }

          return RefreshIndicator(
            onRefresh: () async => _reloadFavorites(),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildFavoritePostCard(item);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, color: Colors.grey[300], size: 60),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFavoritePostCard(ContentModel item) {
    final isVideo = item.videoUrl != null && item.videoUrl!.isNotEmpty;
    final mediaUrl = isVideo ? item.videoUrl! : (item.imageUrl ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mediaUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: isVideo
                  ? Container(
                      height: 190,
                      width: double.infinity,
                      color: Colors.grey[100],
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          color: Colors.blue,
                          size: 44,
                        ),
                      ),
                    )
                  : Image.network(
                      UrlHelper.fixImageUrl(mediaUrl),
                      height: 190,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 190,
                        color: Colors.grey[100],
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle?.isNotEmpty == true
                      ? item.subtitle!
                      : (item.author ?? ''),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      isVideo ? Icons.play_circle_outline : Icons.article,
                      color: Colors.blue,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isVideo ? 'videos'.tr() : 'articles'.tr(),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () async {
                        try {
                          await FavoritePostsService.removeFavoritePost(
                            item.id,
                          );
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('removed_from_favorites'.tr()),
                            ),
                          );
                          _reloadFavorites();
                        } catch (e) {
                          if (!mounted) return;
                          final message = e is ApiException
                              ? e.message
                              : 'favorite_action_failed'.tr();
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));
                        }
                      },
                      icon: const Icon(Icons.favorite, size: 16),
                      label: Text('remove'.tr()),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
