import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/models/content_model.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:sahtek/features/content_library/services/exercise_service.dart';
import 'package:sahtek/core/widgets/video_player_widget.dart';
import 'package:sahtek/core/widgets/buttons.dart';
import 'package:easy_localization/easy_localization.dart';

class ExercicesZonePage extends StatelessWidget {
  const ExercicesZonePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Récupération de la zone depuis le provider
    final selectedZone = Provider.of<GlobalDataProvider>(
      context,
    ).membreSelectionne;

    // Appel au serviceExerciseService (Backend simulé)
    final Future<List<ContentModel>> exercicesFuture =
        ExerciseService.fetchExercicesByZone(selectedZone);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.08),
            radius: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Color.fromARGB(255, 104, 140, 216),
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Text(
          selectedZone.toUpperCase(), // Titre dynamique
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey.withOpacity(0.1),
              radius: 20,
              child: IconButton(
                icon: const Icon(
                  Icons.more_horiz,
                  color: Colors.black87,
                  size: 20,
                ),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<ContentModel>>(
        future: exercicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 13, 84, 242),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final exercices = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carte Objectif
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      255,
                      239,
                      246,
                      255,
                    ), // Bleu très clair
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 13, 84, 242),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.accessibility_new,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${'objective'.tr()} ${selectedZone}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color.fromARGB(255, 13, 84, 242),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'zone_rehab_desc'.tr(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                if (exercices.isEmpty) ...[
                  // État vide
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Icon(
                          Icons.info_outline,
                          color: Colors.grey.withOpacity(0.5),
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'no_content_available'.tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ] else ...[
                  // En-tête liste exercices
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'recommended_routine'.tr(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        'exercises_count_time'.tr(
                          namedArgs: {'count': exercices.length.toString()},
                        ),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 13, 84, 242),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Liste des exercices
                ...exercices
                    .map(
                      (ex) => GestureDetector(
                        onTap: () {
                          // Simulation d'une vidéo
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(ex.title),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: 200,
                                    width: double.maxFinite,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: VideoPlayerWidget(
                                      videoUrl: ex.videoUrl ?? '',
                                      autoPlay: true,
                                      showControls: true,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '${"video_url".tr()} ${ex.videoUrl ?? "video_not_available".tr()}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('close'.tr()),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                spreadRadius: 0,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  ex.imageUrl ?? '',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ex.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.refresh,
                                          size: 14,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          ex.subtitle ?? '',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          ex.duration ?? '',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Color.fromARGB(255, 13, 84, 242),
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),

                if (exercices.isNotEmpty)
                  // Bouton Lancer la routine
                  Center(
                    child: buttonC('start_routine', () {
                      // Par défaut, on sélectionne le premier exercice pour le test
                      Provider.of<GlobalDataProvider>(context, listen: false)
                          .setExercise(exercices.first);
                      Navigator.pushNamed(context, '/preparation_test_ia');
                    }),
                  ),
                const SizedBox(height: 24),

                // Conseil clinique
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lightbulb,
                            color: Color.fromARGB(255, 13, 84, 242),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'clinical_advice'.tr(),
                            style: const TextStyle(
                              color: Color.fromARGB(255, 13, 84, 242),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'clinical_advice_text'.tr(),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          height: 1.4,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
