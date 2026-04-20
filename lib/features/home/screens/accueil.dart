import 'package:flutter/material.dart';
import 'package:sahtek/core/api/endpoint.dart';
import 'package:sahtek/core/widgets/buttons.dart';
import 'package:sahtek/core/widgets/custom_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/core/api/http_client.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:sahtek/models/appointment_model.dart';
import 'package:sahtek/core/services/storage_service.dart';
import 'package:sahtek/core/utils/url_helper.dart';
import 'package:sahtek/core/widgets/video_player_widget.dart';
import 'package:sahtek/features/content_library/services/favorite_posts_service.dart';
import 'package:easy_localization/easy_localization.dart';

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  late final Future<List<_FeedPostItem>> _feedFuture = _fetchFeedItems();
  final Set<String> _favoritePostIds = {};
  bool _favoritesLoaded = false;
  String? _updatingFavoriteId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNewGoogleUserFlow();
    });
    _loadFavoritePostIds();
  }

  Future<void> _loadFavoritePostIds() async {
    try {
      final favorites = await FavoritePostsService.getFavoritePosts();
      if (!mounted) return;
      setState(() {
        _favoritePostIds
          ..clear()
          ..addAll(favorites.map((item) => item.id));
        _favoritesLoaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _favoritesLoaded = true;
      });
    }
  }

  Future<void> _toggleFavorite(_FeedPostItem item) async {
    if (item.id.isEmpty || !_favoritesLoaded || _updatingFavoriteId != null) {
      return;
    }

    final isFavorite = _favoritePostIds.contains(item.id);
    setState(() {
      _updatingFavoriteId = item.id;
    });

    try {
      if (isFavorite) {
        await FavoritePostsService.removeFavoritePost(item.id);
        if (!mounted) return;
        setState(() {
          _favoritePostIds.remove(item.id);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('removed_from_favorites'.tr())));
      } else {
        await FavoritePostsService.addFavoritePost(item.id);
        if (!mounted) return;
        setState(() {
          _favoritePostIds.add(item.id);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('added_to_favorites'.tr())));
      }
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiException
          ? e.message
          : 'favorite_action_failed'.tr();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          _updatingFavoriteId = null;
        });
      }
    }
  }

  Future<List<_FeedPostItem>> _fetchFeedItems() async {
    final results = await Future.wait([
      EndPoint.client.get(EndPoint.posts),
      EndPoint.client.get(EndPoint.publicExercises),
    ]);

    final postsRaw = (results[0] as List<dynamic>?) ?? <dynamic>[];
    final exercisesRaw = (results[1] as List<dynamic>?) ?? <dynamic>[];

    final articles = postsRaw
        .whereType<Map<String, dynamic>>()
        .where((json) {
          final type = (json['type'] ?? '').toString().toLowerCase();
          return !type.contains('video');
        })
        .map((json) {
          final specialist = json['specialist'] as Map<String, dynamic>?;
          final user = specialist?['user'] as Map<String, dynamic>?;
          return _FeedPostItem(
            id: (json['postId'] ?? '').toString(),
            authorName: (user?['fullName'] ?? '').toString(),
            authorImageUrl: UrlHelper.fixImageUrl(
              user?['imageUrl']?.toString(),
            ),
            title: (json['title'] ?? '').toString(),
            description: (json['description'] ?? '').toString(),
            mediaUrl: UrlHelper.fixImageUrl(json['url']?.toString()),
            isVideo: false,
          );
        })
        .toList();

    final videos = exercisesRaw.whereType<Map<String, dynamic>>().map((json) {
      final specialist = json['specialist'] as Map<String, dynamic>?;
      final user = specialist?['user'] as Map<String, dynamic>?;
      return _FeedPostItem(
        id: (json['exerciseId'] ?? '').toString(),
        authorName: (user?['fullName'] ?? '').toString(),
        authorImageUrl: UrlHelper.fixImageUrl(user?['imageUrl']?.toString()),
        title: (json['name'] ?? '').toString(),
        description: (json['description'] ?? '').toString(),
        mediaUrl: UrlHelper.fixImageUrl(json['videoUrl']?.toString()),
        isVideo: true,
      );
    }).toList();

    return [...videos, ...articles];
  }

  Future<void> _handleNewGoogleUserFlow() async {
    final shouldCompleteProfile =
        await StorageService.getNeedsProfileCompletion();

    if (!mounted || !shouldCompleteProfile) return;

    final shouldNavigate = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Complete your profile'),
          content: Text(
            'You need to complete your profile information before continuing.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    await StorageService.setNeedsProfileCompletion(false);

    if (!mounted || shouldNavigate != true) return;
    Navigator.pushNamed(context, '/personal_info');
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GlobalDataProvider>(context);
    final allApps = provider.appointments;

    // Trouver le prochain rendez-vous réel
    AppointmentModel? upcomingAppointment;
    final now = DateTime.now();

    for (var app in allApps) {
      final hourParts = app.time.split(':');
      final appDateTime = DateTime(
        app.date.year,
        app.date.month,
        app.date.day,
        int.parse(hourParts[0]),
        int.parse(hourParts[1]),
      );

      if (appDateTime.isAfter(now)) {
        if (upcomingAppointment == null) {
          upcomingAppointment = app;
        } else {
          final currentNextDt = DateTime(
            upcomingAppointment.date.year,
            upcomingAppointment.date.month,
            upcomingAppointment.date.day,
            int.parse(upcomingAppointment.time.split(':')[0]),
            int.parse(upcomingAppointment.time.split(':')[1]),
          );
          if (appDateTime.isBefore(currentNextDt)) {
            upcomingAppointment = app;
          }
        }
      }
    }

    // --- 2. Construction de l'interface ---
    return Scaffold(
      backgroundColor: Colors.white,
      // SafeArea permet d'éviter les encoches (notch) et la barre d'état du téléphone
      body: SafeArea(
        child: SingleChildScrollView(
          // Permet de faire défiler toute la page verticalement
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête (Profil utilisateur)
                _buildHeader(context),
                const SizedBox(height: 32),

                // Section "Programme d'exercices"
                _buildDailyProgramCard(context),
                const SizedBox(height: 40),

                // Titre de section principal
                Text(
                  'specialized_content'.tr(),
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 24),

                // Section "Vidéos d'exercices"
                _buildSectionHeader('exercise_videos'.tr()),
                const SizedBox(height: 16),
                _buildPostsFeed(),

                const SizedBox(height: 32),

                // Section "Prochaine évaluation" (Uniquement s'il y a un RDV à venir)
                if (upcomingAppointment != null) ...[
                  _buildEvaluationCard(context, upcomingAppointment),
                  const SizedBox(height: 40),
                ],
              ],
            ),
          ),
        ),
      ),
      // Bottom Navigation Bar réutilisable
      bottomNavigationBar: const CustomBottomNavBar(
        currentIndex: 0, // 0 = Accueil
      ),
    );
  }

  // --- Widgets Utilitaires Locaux ---

  // Construit l'en-tête (Photo, Bonjour Jean Dupont...)
  Widget _buildHeader(BuildContext context) {
    final profile = context.watch<GlobalDataProvider>().profile;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: Text(
                  profile.fullName.isNotEmpty
                      ? profile.fullName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 13, 84, 242),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'welcome_back'.tr(),
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                Text(
                  profile.fullName.isNotEmpty ? profile.fullName : '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            _buildHeaderAction(
              icon: Icons.search_rounded,
              onTap: () =>
                  Navigator.pushNamed(context, '/localisation_douleur'),
              semanticLabel: 'search'.tr(),
            ),
            const SizedBox(width: 10),
            _buildHeaderAction(
              icon: Icons.notifications_none_rounded,
              onTap: () => Navigator.pushNamed(context, '/notifications'),
              semanticLabel: 'notifications_title'.tr(),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    255,
                    13,
                    84,
                    242,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color.fromARGB(255, 13, 84, 242),
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required VoidCallback onTap,
    required String semanticLabel,
  }) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: const Color(0xFFF4F7FF),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              icon,
              color: const Color.fromARGB(255, 13, 84, 242),
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  // Construit la carte bleue "les exercices prévus aujourd'hui"
  Widget _buildDailyProgramCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'today'.tr(),
            style: const TextStyle(
              color: Color.fromARGB(255, 13, 84, 242),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.directions_run,
                color: Color.fromARGB(255, 13, 84, 242),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'exercise_program'.tr(),
                style: const TextStyle(
                  color: Color.fromARGB(255, 13, 84, 242),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'scheduled_exercises_today'.tr(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'objective_mobility'.tr(),
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),

          buttonC(
            'start_session'.tr(),
            () => Navigator.pushNamed(context, '/selection_test_ia'),
            icon: Icons.play_arrow,
          ),
        ],
      ),
    );
  }

  // Construit l'en-tête d'une section (Titre à gauche, "Voir tout" à droite)
  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'see_all'.tr(),
            style: const TextStyle(
              color: Color.fromARGB(255, 13, 84, 242),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostsFeed() {
    return FutureBuilder<List<_FeedPostItem>>(
      future: _feedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color.fromARGB(255, 13, 84, 242),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'error_loading'.tr(),
              style: TextStyle(color: Colors.red[300]),
            ),
          );
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return Center(child: Text('no_content_available'.tr()));
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) => _buildFeedPostCard(items[index]),
        );
      },
    );
  }

  Widget _buildFeedPostCard(_FeedPostItem item) {
    final isFavorite = _favoritePostIds.contains(item.id);
    final isUpdating = _updatingFavoriteId == item.id;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFEAF0FF),
                backgroundImage: item.authorImageUrl.isNotEmpty
                    ? NetworkImage(item.authorImageUrl)
                    : null,
                child: item.authorImageUrl.isEmpty
                    ? Text(
                        item.authorName.isNotEmpty
                            ? item.authorName[0].toUpperCase()
                            : 'S',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 13, 84, 242),
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.authorName.isEmpty ? 'Specialist' : item.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      item.isVideo ? 'Video exercise' : 'Article',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (!item.isVideo)
                IconButton(
                  onPressed: isUpdating ? null : () => _toggleFavorite(item),
                  icon: isUpdating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite
                              ? Colors.redAccent
                              : Colors.grey[500],
                        ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          if (item.description.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.description,
              style: TextStyle(color: Colors.grey[700], height: 1.45),
            ),
          ],
          if (item.isVideo && item.mediaUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: VideoPlayerWidget(
                videoUrl: item.mediaUrl,
                autoPlay: false,
                looping: false,
              ),
            ),
          ] else if (!item.isVideo && item.mediaUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                item.mediaUrl,
                width: double.infinity,
                height: 190,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Construit la carte d'évaluation en bas (Dynamique)
  Widget _buildEvaluationCard(BuildContext context, AppointmentModel app) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 239, 246, 255),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () =>
            Navigator.pushNamed(context, '/details_rdv', arguments: app),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat(
                      'MMM',
                      context.locale.toString(),
                    ).format(app.date).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat(
                      'dd',
                      context.locale.toString(),
                    ).format(app.date),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'next_evaluation'.tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${DateFormat('EEEE', context.locale.toString()).format(app.date)}, ${app.time} • ${app.specialistName}",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color.fromARGB(255, 13, 84, 242),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedPostItem {
  final String id;
  final String authorName;
  final String authorImageUrl;
  final String title;
  final String description;
  final String mediaUrl;
  final bool isVideo;

  const _FeedPostItem({
    required this.id,
    required this.authorName,
    required this.authorImageUrl,
    required this.title,
    required this.description,
    required this.mediaUrl,
    required this.isVideo,
  });
}
