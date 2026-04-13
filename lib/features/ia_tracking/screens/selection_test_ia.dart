import 'package:flutter/material.dart';
import 'package:sahtek/core/widgets/custom_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:sahtek/models/content_model.dart';
import 'package:easy_localization/easy_localization.dart';

class SelectionTestIAPage extends StatefulWidget {
  const SelectionTestIAPage({Key? key}) : super(key: key);

  @override
  State<SelectionTestIAPage> createState() => _SelectionTestIAPageState();
}

class _SelectionTestIAPageState extends State<SelectionTestIAPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final provider = Provider.of<GlobalDataProvider>(context, listen: false);
    // Fetch assigned exercises from backend
    await provider.fetchPatientExercises();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Liste des exercices statiques du système
    final List<Map<String, dynamic>> systemExercises = [
      {
        'id': 'ia_shoulder_flexion',
        'title': 'Flexion de l\'épaule',
        'plan': 'PLAN SAGITTAL',
        'description':
            'Levez votre bras droit devant vous aussi haut que possible en gardant le coude tendu.',
        'icon': Icons.accessibility_new,
        'image': 'lib/assets/images/shoulder_flex.png',
        'videoUrl':
            'https://firebasestorage.googleapis.com/v0/b/easyrdv-836e1.appspot.com/o/exercices%2Fshoulder_flexion.mp4?alt=media',
        'isAssigned': false,
      },
      {
        'id': 'ia_shoulder_abduction',
        'title': 'Abduction de l\'épaule',
        'plan': 'PLAN FRONTAL',
        'description':
            'Levez votre bras sur le côté en l\'éloignant de votre corps jusqu\'au maximum.',
        'icon': Icons.directions_run,
        'image': 'lib/assets/images/shoulder_abd.png',
        'videoUrl':
            'https://firebasestorage.googleapis.com/v0/b/easyrdv-836e1.appspot.com/o/exercices%2Fshoulder_abduction.mp4?alt=media',
        'isAssigned': false,
      },
      {
        'id': 'ia_rotation_externe',
        'title': 'Rotation externe',
        'plan': 'PLAN TRANSVERSAL',
        'description':
            'Avec le coude plié à 90°, pivotez votre avant-bras vers l\'extérieur.',
        'icon': Icons.sync,
        'image': 'lib/assets/images/shoulder_rot.png',
        'videoUrl':
            'https://firebasestorage.googleapis.com/v0/b/easyrdv-836e1.appspot.com/o/exercices%2Fshoulder_rotation.mp4?alt=media',
        'isAssigned': false,
      },
    ];

    // 2. Récupération des exercices assignés dynamiquement via le Provider
    final provider = Provider.of<GlobalDataProvider>(context);
    final assignedExercises = provider.assignedExercises.map((content) {
      return {
        'id': content.id,
        'title': content.title,
        'plan': content.subtitle!.isNotEmpty ? content.subtitle : 'ASSIGNÉ',
        'description': content.description,
        'icon': Icons.medical_services_outlined,
        'image': content.imageUrl!.isNotEmpty
            ? content.imageUrl
            : 'lib/assets/images/shoulder_flex.png', // Placeholder par défaut
        'videoUrl': content.videoUrl,
        'isAssigned': true,
      };
    }).toList();

    // 3. Fusion des deux listes (Les assignés apparaissent en premier)
    final allExercises = [...assignedExercises, ...systemExercises];

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
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF0D54F2),
                  size: 18,
                ),
                onPressed: () =>
                    Navigator.pushNamed(context, 'acceuil_patient'),
              ),
            ),
          ),
        ),
        title: Text(
          'choice_movement'.tr(),
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? _buildSkeletonLoader()
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'choice_movement'.tr(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'select_exercise_desc'.tr(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ...allExercises
                      .map((ex) => _buildExerciseCard(context, ex))
                      .toList(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
    );
  }

  // --- UI Components ---

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          height: 180,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(24),
          ),
        );
      },
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    Map<String, dynamic> exercise,
  ) {
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
                  color: exercise['isAssigned']
                      ? const Color(0xFFFFF0EC)
                      : const Color(0xFFF0F5FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  exercise['icon'],
                  color: exercise['isAssigned']
                      ? const Color(0xFFFF5630)
                      : const Color(0xFF0D54F2),
                  size: 28,
                ),
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
                        color: exercise['isAssigned']
                            ? const Color(0xFFFF5630)
                            : Colors.grey[400],
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
                    image: exercise['image'].startsWith('http')
                        ? NetworkImage(exercise['image']) as ImageProvider
                        : AssetImage(exercise['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Bouton Lancer
              SizedBox(
                width: 180,
                child: ElevatedButton(
                  onPressed: () {
                    final provider = Provider.of<GlobalDataProvider>(
                      context,
                      listen: false,
                    );
                    provider.setExercise(
                      ContentModel(
                        id: exercise['id'],
                        title: exercise['title'],
                        subtitle: exercise['plan'],
                        description: exercise['description'],
                        imageUrl: exercise['image'],
                        videoUrl: exercise['videoUrl'],
                      ),
                    );
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'start_analysis'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, size: 18),
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
