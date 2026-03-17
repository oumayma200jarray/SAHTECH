import 'package:flutter/material.dart';
import 'package:sahtek/core/widgets/custom_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:sahtek/models/content_model.dart';

class SelectionTestIAPage extends StatelessWidget {
  const SelectionTestIAPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Liste des exercices avec les métadonnées pour le design
    final List<Map<String, dynamic>> exercises = [
      {
        'id': 'ia_shoulder_flexion',
        'title': 'Flexion de l\'épaule',
        'plan': 'PLAN SAGITTAL',
        'description': 'Levez votre bras droit devant vous aussi haut que possible en gardant le coude tendu.',
        'icon': Icons.accessibility_new,
        'image': 'lib/assets/images/shoulder_flex.png',
        'videoUrl': 'https://firebasestorage.googleapis.com/v0/b/easyrdv-836e1.appspot.com/o/exercices%2Fshoulder_flexion.mp4?alt=media',
      },
      {
        'id': 'ia_shoulder_abduction',
        'title': 'Abduction de l\'épaule',
        'plan': 'PLAN FRONTAL',
        'description': 'Levez votre bras sur le côté en l\'éloignant de votre corps jusqu\'au maximum.',
        'icon': Icons.directions_run,
        'image': 'lib/assets/images/shoulder_abd.png',
        'videoUrl': 'https://firebasestorage.googleapis.com/v0/b/easyrdv-836e1.appspot.com/o/exercices%2Fshoulder_abduction.mp4?alt=media',
      },
      {
        'id': 'ia_rotation_externe',
        'title': 'Rotation externe',
        'plan': 'PLAN TRANSVERSAL',
        'description': 'Avec le coude plié à 90°, pivotez votre avant-bras vers l\'extérieur.',
        'icon': Icons.sync,
        'image': 'lib/assets/images/shoulder_rot.png',
        'videoUrl': 'https://firebasestorage.googleapis.com/v0/b/easyrdv-836e1.appspot.com/o/exercices%2Fshoulder_rotation.mp4?alt=media',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: CircleAvatar(
              backgroundColor: const Color(0xFFF0F5FF),
              radius: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0D54F2), size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
        title: Text(
          'Selection du Test IA',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Choisir un mouvement',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sélectionnez un exercice pour commencer votre séance d\'analyse de mouvement assistée par IA.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ...exercises.map((ex) => _buildExerciseCard(context, ex)).toList(),
            const SizedBox(height: 100), // Espace pour la bottom nav
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
    );
  }

  Widget _buildExerciseCard(BuildContext context, Map<String, dynamic> exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F5FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(exercise['icon'], color: const Color(0xFF0D54F2), size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise['plan'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            exercise['description'],
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Miniature/Image
              Container(
                width: 60,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(exercise['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Bouton Lancer
              SizedBox(
                width: 180,
                child: ElevatedButton(
                  onPressed: () {
                    final provider = Provider.of<GlobalDataProvider>(context, listen: false);
                    provider.setExercise(ContentModel(
                      id: exercise['id'],
                      title: exercise['title'],
                      subtitle: exercise['plan'],
                      description: exercise['description'],
                      imageUrl: exercise['image'],
                      videoUrl: exercise['videoUrl'], // Sera null s'il n'y a pas de video
                    ));
                    Navigator.pushNamed(context, '/preparation_test_ia');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D54F2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Lancer l\'analyse',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
