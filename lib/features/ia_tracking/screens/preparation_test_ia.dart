import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class PreparationTestIAPage extends StatefulWidget {
  const PreparationTestIAPage({super.key});

  @override
  State<PreparationTestIAPage> createState() => _PreparationTestIAPageState();
}

class _PreparationTestIAPageState extends State<PreparationTestIAPage> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    final provider = Provider.of<GlobalDataProvider>(context, listen: false);
    final exercise = provider.selectedExercise;
    if (exercise?.videoUrl != null && exercise!.videoUrl!.isNotEmpty) {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(exercise.videoUrl!));
      _videoPlayerController!.initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            autoPlay: false,
            looping: true,
            aspectRatio: _videoPlayerController!.value.aspectRatio,
            placeholder: Container(color: Colors.black),
            materialProgressColors: ChewieProgressColors(
              playedColor: const Color(0xFF0D54F2),
              handleColor: const Color(0xFF0D54F2),
              backgroundColor: Colors.grey,
              bufferedColor: Colors.white.withOpacity(0.5),
            ),
          );
        });
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GlobalDataProvider>(context);
    final exercise = provider.selectedExercise;
    final isProfil = exercise?.requiredView == 'profil';

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
          style: TextStyle(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Text(
                exercise?.title ?? 'Préparez votre espace',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Suivez les instructions ci-dessous pour garantir la précision de l'analyse biomécanique.",
                  style: TextStyle(color: Colors.grey[500], fontSize: 14, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Video Demo Section
            if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Chewie(controller: _chewieController!),
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0D54F2)),
                    SizedBox(height: 16),
                    Text("Chargement de la démo...", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            
            const SizedBox(height: 28),

            // Camera positioning banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isProfil 
                    ? [const Color(0xFF7C3AED), const Color(0xFFA78BFA)] // Purple for profile
                    : [const Color(0xFF0D54F2), const Color(0xFF4C8FFF)], // Blue for face
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isProfil ? Icons.person_outline : Icons.face_retouching_natural, 
                      color: Colors.white, 
                      size: 22
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isProfil ? 'Position de PROFIL requise' : 'Position de FACE requise',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isProfil 
                            ? 'Placez le téléphone sur le côté pour voir votre profil.'
                            : 'Placez le téléphone face à vous pour voir tout votre corps.',
                          style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildStepTile(
              icon: Icons.phone_android,
              title: "Positionnez le téléphone",
              description: "À hauteur de poitrine, sur une surface stable.",
            ),
            const SizedBox(height: 12),
            _buildStepTile(
              icon: Icons.accessibility_new,
              title: "Recul utilisateur",
              description: "Reculez de 2 mètres pour que votre corps soit entièrement visible.",
            ),
            const SizedBox(height: 12),
            _buildStepTile(
              icon: Icons.auto_awesome,
              title: "Analyse Intelligente",
              description: "L'IA validera votre position (Vue de ${isProfil ? 'Profil' : 'Face'}) avant de commencer.",
            ),
            const SizedBox(height: 40),

            // Bouton démarrer
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/suivi_ia_direct');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D54F2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Démarrer le test',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTile({
    required IconData icon,
    required String title,
    required String description,
  }) {
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

