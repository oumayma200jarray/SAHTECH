import 'package:flutter/material.dart';
import 'package:sahtek/core/api/endpoint.dart';
import 'package:sahtek/models/content_model.dart';
import 'package:sahtek/core/widgets/content_card.dart';
import 'package:sahtek/core/widgets/buttons.dart';
import 'package:sahtek/core/widgets/custom_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:sahtek/models/appointment_model.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:sahtek/features/dashboard/services/dashboard_services.dart';

class AccueilPage extends StatelessWidget {
  const AccueilPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Fonction pour récupérer les vidéos d'exercices depuis le Backend
    Future<List<ContentModel>> fetchVideosFromBackend() async {
      try {
        final List<dynamic> data = await EndPoint.client.get('/videos');
        return data.map((json) => ContentModel.fromJson(json)).toList();
      } catch (e) {
        debugPrint('Erreur chargement vidéos (Backend non prêt?): $e');
        // Fallback: Récupérer depuis les documents récents du spécialiste
        final recentDocs = await SpecialistDashboardService.getRecentDocuments();
        return recentDocs.where((doc) => doc.videoUrl != null && doc.videoUrl!.isNotEmpty).toList();
      }
    }

    // Fonction pour récupérer les articles depuis le Backend
    Future<List<ContentModel>> fetchArticlesFromBackend() async {
      try {
        final List<dynamic> data = await EndPoint.client.get('/articles');
        return data.map((json) => ContentModel.fromJson(json)).toList();
      } catch (e) {
        debugPrint('Erreur chargement articles (Backend non prêt?): $e');
        // Fallback: Récupérer depuis les documents récents du spécialiste
        final recentDocs = await SpecialistDashboardService.getRecentDocuments();
        return recentDocs.where((doc) => doc.videoUrl == null || doc.videoUrl!.isEmpty).toList();
      }
    }

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
                _buildAsyncHorizontalList(
                  fetchVideosFromBackend(),
                ), // Utilisation FutureBuilder

                const SizedBox(height: 32),

                // Section "Articles Pédagogiques"
                _buildSectionHeader('educational_articles'.tr()),
                const SizedBox(height: 16),
                _buildAsyncHorizontalList(
                  fetchArticlesFromBackend(),
                ), // Utilisation FutureBuilder

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
            IconButton(
              icon: const Icon(Icons.search, color: Colors.grey),
              onPressed: () {
                Navigator.pushNamed(context, '/localisation_douleur');
              },
            ),
            IconButton(
              icon: const Icon(Icons.person, color: Colors.grey),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
      ],
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

  // Construit la liste horizontale des MediaCards AVEC FutureBuilder (Asynchrone)
  Widget _buildAsyncHorizontalList(Future<List<ContentModel>> dataFuture) {
    return SizedBox(
      height: 220, // Hauteur nécessaire pour l'image + le texte en dessous
      child: FutureBuilder<List<ContentModel>>(
        future: dataFuture,
        builder: (context, snapshot) {
          // Affichage pendant le chargement
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

          // Affichage en cas d'erreur
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'error_loading'.tr(),
                style: TextStyle(color: Colors.red[300]),
              ),
            );
          }

          // Si pas de données
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('no_content_available'.tr()));
          }

          final items = snapshot.data!;

          // Si on a les données, on affiche la liste !
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return MediaCardWidget(
                item: item,
                onTap: () {
                  Provider.of<GlobalDataProvider>(
                    context,
                    listen: false,
                  ).addToViewed(item);
                  print('Cliqué sur : ${item.title}');
                },
              );
            },
          );
        },
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
