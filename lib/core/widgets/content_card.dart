import 'package:flutter/material.dart';
import 'package:sahtek/models/content_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:video_player/video_player.dart';

/// WIDGET 1 : [MediaCardWidget]
/// Composant réutilisable pour afficher une carte de contenu "Média" (Vidéo ou Article).
/// Conçu pour être utilisé dans un carrousel horizontal (sur la page Accueil par exemple).
class MediaCardWidget extends StatelessWidget {
  /// Les données du contenu à afficher
  final ContentModel item;

  /// Action déclenchée au clic sur la carte entière
  final VoidCallback onTap;

  const MediaCardWidget({Key? key, required this.item, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Largeur fixe pour garantir un affichage uniforme dans le ListView horizontal
        width: 220,
        // Espacement entre les cartes (à droite de chaque carte)
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          // Alignement du texte à gauche pour correspondre à la maquette
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Bloc Image avec indicateur de durée en superposition ---
            Stack(
              children: [
                // Image principale avec coins arrondis
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.imageUrl ?? '',
                    height: 130, // Hauteur fixe de l'image
                    width: double.infinity,
                    // L'image couvre tout l'espace alloué et est coupée si nécessaire, sans être déformée
                    fit: BoxFit.cover,
                    // Widget de secours en cas d'erreur de chargement de l'image depuis l'URL
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 130,
                      width: double.infinity,
                      color: Colors.grey[300],
                      // Icône d'erreur par défaut
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
                // Affichage conditionnel : Si une durée est fournie, on l'affiche en bas à droite
                if (item.duration != null)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        // Fond noir semi-transparent pour bien lire l'heure
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.duration!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // --- Titre du média ---
            // Limité à 2 lignes. Si le texte dépasse, de petits points (...) sont affichés
            Text(
              item.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // --- Affichage conditionnel de l'auteur ---
            if (item.author != null)
              Text(
                item.author!,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                maxLines: 1, // Limité scrupuleusement à 1 ligne
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}

/// WIDGET 2 : [TestCardWidget]
/// Composant réutilisable pour afficher une carte de sélection de "Test IA".
/// Conçu pour être affiché dans une liste verticale (ex: Sélection du Test IA).
class TestCardWidget extends StatefulWidget {
  /// Les données du test à afficher
  final ContentModel item;

  /// Action déclenchée au clic sur le bouton "Lancer l'analyse" (uniquement ce bouton)
  final VoidCallback onStartAnalysis;

  const TestCardWidget({
    Key? key,
    required this.item,
    required this.onStartAnalysis,
  }) : super(key: key);

  @override
  State<TestCardWidget> createState() => _TestCardWidgetState();
}

class _TestCardWidgetState extends State<TestCardWidget> {
  VideoPlayerController? _controller;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    if (widget.item.videoUrl != null) {
      final String url = widget.item.videoUrl!;
      _controller = url.startsWith('http')
          ? VideoPlayerController.networkUrl(Uri.parse(url))
          : VideoPlayerController.asset(url);

      _controller!
          .initialize()
          .then((_) {
            if (mounted) {
              setState(() {});
              _controller?.setLooping(true);
              _controller?.play();
              _controller?.setVolume(0); // Muet pour la carte
            }
          })
          .catchError((e) {
            if (mounted) {
              setState(() => _isError = true);
            }
          });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Marges extérieures pour espacer la carte du bord de l'écran et des autres cartes
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      // Espacement intérieur (padding entre la bordure et le contenu)
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Légère ombre projetée vers le bas pour donner un effet de survol/relief
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4), // L'ombre descend de 4 pixels
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- EN-TÊTE : Icône (à gauche) + Titre et Sous-titre (à droite de l'icône) ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Conteneur de l'icône (fond bleu clair avec bords très arrondis)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.accessibility_new_rounded,
                  color: Colors.blue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Bloc Titre et Sous-titre (Expanded pour éviter le débordement)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre (ex: "Flexion de l'épaule")
                    Text(
                      widget.item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),

                    // Sous-titre conditionnel (ex: "PLAN SAGITTAL")
                    if (widget.item.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        // On force le texte en majuscule comme sur la maquette
                        widget.item.subtitle!.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          letterSpacing:
                              0.5, // Espacement des lettres (style tag/badge)
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // --- CORPS DE LA CARTE : Description détaillée ---
          if (widget.item.description != null)
            Text(
              widget.item.description!,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
                height:
                    1.4, // Interligne augmenté pour une lecture plus confortable
              ),
            ),

          const SizedBox(height: 16),

          // --- BAS DE LA CARTE : Miniature du mouvement (gauche) + Bouton d'action (droite) ---
          Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // Repousse l'image à gauche et le bouton à droite
            children: [
              // Miniature de la vidéo ou du mouvement (gauche)
              Container(
                width: 70,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(6),
                ),
                clipBehavior: Clip.antiAlias,
                child: _controller != null && _controller!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          if (widget.item.imageUrl != null)
                            Image.network(
                              widget.item.imageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, e, s) => const Icon(
                                Icons.videocam_off,
                                color: Colors.white24,
                                size: 16,
                              ),
                            ),
                          if (!_isError)
                            const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white24,
                              ),
                            )
                          else
                            const Icon(
                              Icons.error_outline,
                              color: Colors.white24,
                              size: 24,
                            ),
                        ],
                      ),
              ),

              // Bouton principal d'action bleu
              ElevatedButton(
                onPressed: widget.onStartAnalysis, // Déclenche le callback
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF0056FF,
                  ), // Bleu spécifique du design
                  shape: RoundedRectangleBorder(
                    // Bordure très arrondie pour faire un style "pilule"
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation:
                      0, // Désactivation de l'ombre portée propre au ElevatedButton
                  // Espacement interne du bouton pour l'élargir légèrement
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize
                      .min, // S'adapte à la largeur du texte et de l'icône, pas plus grand
                  children: [
                    Text(
                      "start_analysis".tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(
                      width: 6,
                    ), // Espace entre le texte et l'icône chevron
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
