import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:sahtek/core/widgets/buttons.dart';
import 'package:easy_localization/easy_localization.dart';

class LocalisationDouleurPage extends StatefulWidget {
  const LocalisationDouleurPage({Key? key}) : super(key: key);

  @override
  State<LocalisationDouleurPage> createState() =>
      _LocalisationDouleurPageState();
}

class _LocalisationDouleurPageState extends State<LocalisationDouleurPage> {
  // Position actuelle du point bleu (en % de l'image 0.0 à 1.0)
  Offset? _tapPoint;

  // Points de repère sur les deux silhouettes (Face et Dos)
  // x, y en % de l'image (0.0 à 1.0)
  final List<_PointInfo> _pointInfos = [
    // --- Silhouette de DOS (gauche de l'image) ---
    _PointInfo('neck'.tr(), const Offset(0.25, 0.10)),
    _PointInfo('left_shoulder'.tr(), const Offset(0.12, 0.22)),
    _PointInfo('right_shoulder'.tr(), const Offset(0.38, 0.22)),
    _PointInfo('back'.tr(), const Offset(0.25, 0.40)),
    _PointInfo('left_elbow'.tr(), const Offset(0.05, 0.48)),
    _PointInfo('right_elbow'.tr(), const Offset(0.45, 0.48)),

    // --- Silhouette de FACE (droite de l'image) ---
    _PointInfo('neck'.tr(), const Offset(0.75, 0.10)),
    _PointInfo('right_shoulder'.tr(), const Offset(0.62, 0.22)),
    _PointInfo('left_shoulder'.tr(), const Offset(0.88, 0.22)),
    _PointInfo('right_knee'.tr(), const Offset(0.68, 0.70)),
    _PointInfo('left_knee'.tr(), const Offset(0.82, 0.70)),
    _PointInfo('right_foot'.tr(), const Offset(0.68, 0.92)),
    _PointInfo('left_foot'.tr(), const Offset(0.82, 0.92)),
    _PointInfo('right_elbow'.tr(), const Offset(0.55, 0.48)),
    _PointInfo('left_elbow'.tr(), const Offset(0.95, 0.48)),
  ];

  _ImageRect _imageRect(BoxConstraints constraints) {
    const double iw = 216, ih = 346;
    final double cw = constraints.maxWidth, ch = constraints.maxHeight;
    final double scale = (cw / iw < ch / ih) ? cw / iw : ch / ih;
    final double rw = iw * scale;
    final double rh = ih * scale;
    final double ox = (cw - rw) / 2;
    final double oy = (ch - rh) / 2;
    return _ImageRect(rw, rh, ox, oy);
  }

  void _handleTap(
    Offset local,
    BoxConstraints constraints,
    GlobalDataProvider provider,
    String current,
  ) {
    final r = _imageRect(constraints);
    final double tx = local.dx - r.ox;
    final double ty = local.dy - r.oy;
    if (tx < 0 || tx > r.rw || ty < 0 || ty > r.rh) return;

    // Calculer les coordonnées en pourcentage (0.0 à 1.0) pour être indépendant de la résolution d'écran
    final double px = tx / r.rw;
    final double py = ty / r.rh;

    // ÉTAPE 1 : Logique d'Intelligence et d'Interaction
    // Trouver le point d'intérêt prédéfini le plus proche du tap de l'utilisateur
    // Utilisation du calcul de distance euclidienne (x2 - x1)^2 + (y2 - y1)^2
    String best = current;
    double minDist = double.infinity;

    for (var point in _pointInfos) {
      final double d =
          (point.pos.dx - px) * (point.pos.dx - px) +
          (point.pos.dy - py) * (point.pos.dy - py);
      if (d < minDist) {
        minDist = d;
        best = point.name;
      }
    }

    setState(() => _tapPoint = Offset(px, py));
    if (best != current) provider.setMembre(best);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GlobalDataProvider>(context);
    final selectedZone = provider.membreSelectionne;

    // Point à dessiner : là où l'utilisateur a tapé, sinon le premier point correspondant à la zone
    final Offset drawPoint =
        _tapPoint ??
        (_pointInfos
            .firstWhere(
              (p) => p.name == selectedZone,
              orElse: () => _PointInfo('', const Offset(0.5, 0.5)),
            )
            .pos);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.08),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: Colors.black87,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          'where_it_hurts'.tr(),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ── Zone image interactive ────────────────────────────────
          Positioned.fill(
            bottom: 160,
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final r = _imageRect(constraints);

                    return GestureDetector(
                      onTapDown: (d) => _handleTap(
                        d.localPosition,
                        constraints,
                        provider,
                        selectedZone,
                      ),
                      onPanUpdate: (d) => _handleTap(
                        d.localPosition,
                        constraints,
                        provider,
                        selectedZone,
                      ),
                      child: Stack(
                        children: [
                          // Corps humain
                          Positioned.fill(
                            child: Image.asset(
                              'lib/assets/images/corps_humain.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          // Titre en surimpression
                          Positioned(
                            top: 12,
                            left: 0,
                            right: 0,
                            child: Text(
                              'tap_or_slide_to_select'.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          // Points de repère (petites pastilles grises)
                          ..._pointInfos.map((point) {
                            return Positioned(
                              left: r.ox + r.rw * point.pos.dx - 4,
                              top: r.oy + r.rh * point.pos.dy - 4,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF13A29B,
                                  ).withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }).toList(),

                          // Point bleu
                          Positioned(
                            left: r.ox + r.rw * drawPoint.dx - 12,
                            top: r.oy + r.rh * drawPoint.dy - 12,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D54F2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF0D54F2,
                                    ).withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // ── Carte de sélection en bas ─────────────────────────────
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D54F2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Color(0xFF0D54F2),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'selected_zone'.tr(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              selectedZone.isEmpty
                                  ? 'no_zone_selected'.tr()
                                  : selectedZone,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  buttonC(
                    'show_exercises'.tr(),
                    () => Navigator.pushNamed(context, '/exercices_zone'),
                    icon: Icons.arrow_forward,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper class pour les dimensions de l'image rendue
class _ImageRect {
  final double rw, rh, ox, oy;
  const _ImageRect(this.rw, this.rh, this.ox, this.oy);
}

class _PointInfo {
  final String name;
  final Offset pos;
  const _PointInfo(this.name, this.pos);
}
