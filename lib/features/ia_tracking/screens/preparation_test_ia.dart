import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:sahtek/core/widgets/video_player_widget.dart';

class PreparationTestIAPage extends StatefulWidget {
  const PreparationTestIAPage({Key? key}) : super(key: key);

  @override
  State<PreparationTestIAPage> createState() => _PreparationTestIAPageState();
}

class _PreparationTestIAPageState extends State<PreparationTestIAPage> {
  @override
  Widget build(BuildContext context) {
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
          'Préparation du Test IA',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Center(
              child: Text(
                // ÉTAPE 0 : Conditionnement de l'environnement de capture (Dataset source)
                // L'utilisateur positionne l'appareil pour garantir le minimum de bruit (Outliers) dans l'acquisition
                // Cela aide le modèle de vision par ordinateur à avoir un meilleur contraste et une détection précise des landmarks
                'Préparez votre espace',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Suivez ces étapes pour assurer une analyse précise de vos mouvements par l'IA.",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Étapes
            _buildStepTile(
              icon: Icons.phone_android,
              title: "Positionnement du téléphone",
              description: "Positionnez votre téléphone à hauteur de poitrine sur une surface stable.",
            ),
            const SizedBox(height: 12),
            _buildStepTile(
              icon: Icons.accessibility_new,
              title: "Recul utilisateur",
              description: "Reculez de 2 mètres, positionnez-vous de profil face à la caméra.",
            ),
            const SizedBox(height: 32),

            // Image d'illustration (Positionnement)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                image: const DecorationImage(
                  image: AssetImage('lib/assets/images/prep_illustration.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Section Démo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "DÉMONSTRATION DU MOUVEMENT",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D54F2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Guide Vidéo",
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF0D54F2),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Consumer<GlobalDataProvider>(
              builder: (context, provider, _) {
                // ÉTAPE 1 : Chargement Dynamique de la démonstration
                // On récupère l'url vidéo correspondant au mouvement attendu
                final videoUrl = provider.selectedExercise?.videoUrl;
                return Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: (videoUrl != null && videoUrl.isNotEmpty)
                        ? VideoPlayerWidget(
                            videoUrl: videoUrl,
                            autoPlay: true,
                            looping: true,
                            showControls: false,
                          )
                        : const Center(
                            child: Icon(Icons.videocam_off, size: 48, color: Colors.grey),
                          ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Bouton
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/suivi_ia_direct'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D54F2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Démarrer le test",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.play_arrow, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                "L'analyse commencera après un compte à rebours de 3 secondes",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTile({required IconData icon, required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E7FF).withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0D54F2), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
