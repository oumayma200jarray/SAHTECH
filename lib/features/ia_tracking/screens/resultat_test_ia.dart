import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sahtek/models/ia_tracking_model.dart';
import 'package:intl/intl.dart';

class ResultatsTestIAPage extends StatelessWidget {
  const ResultatsTestIAPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GlobalDataProvider>(context);
    final lastResult = provider.lastTrackingResult;
    
    if (lastResult == null) {
      return Scaffold(body: Center(child: Text('no_content_available'.tr())));
    }

    // --- DATA EXTRACTION ---
    final List<Map<String, dynamic>> movements = [
      {'id': 'flexion', 'name': 'Flexion Antérieure', 'max': 180.0, 'unit': '°'},
      {'id': 'abduction', 'name': 'Abduction', 'max': 180.0, 'unit': '°'},
      {'id': 'rotation_externe', 'name': 'Rotation Externe', 'max': 90.0, 'unit': '°'},
      {'id': 'extension', 'name': 'Extension', 'max': 60.0, 'unit': '°'},
      {'id': 'adduction', 'name': 'Adduction', 'max': 45.0, 'unit': '°'},
      {'id': 'rotation_interne', 'name': 'Rotation Interne', 'max': 70.0, 'unit': '°'},
    ];

    final List<Map<String, dynamic>> analysisData = movements.map((m) {
      final healthy = (provider.getValueForSide(m['id'], healthy: true) ?? 0.0).toDouble();
      final patho = (provider.getValueForSide(m['id'], healthy: false) ?? 0.0).toDouble();
      
      // Récupérer la valeur de la séance PRÉCÉDENTE pour ce même exercice
      final prevValue = (provider.getPreviousSessionValue('ia_shoulder_${m['id']}') ?? 
                        provider.getPreviousSessionValue('ia_${m['id']}') ??
                        provider.getPreviousSessionValue(m['id']) ?? 0.0).toDouble();
      
      // Delta = valeur actuelle - valeur précédente
      // Uniquement si on a fait l'exercice aujourd'hui (patho > 0) et qu'on a une valeur précédente
      final delta = (prevValue > 0 && patho > 0) ? (patho - prevValue) : 0.0;
      
      return {
        ...m,
        'healthy': healthy,
        'patho': patho,
        'delta': delta,
      };
    }).where((m) => (m['patho'] as num) > 0).toList();

    // Calculate Global Score (only for performed exercises)
    double totalMobility = 0;
    int performedCount = 0;
    for (var m in analysisData) {
      final double maxVal = (m['max'] as num).toDouble();
      final double pathoVal = (m['patho'] as num).toDouble();
      if (maxVal > 0 && pathoVal > 0) {
        totalMobility += (pathoVal / maxVal) * 100;
        performedCount++;
      }
    }
    final double globalMobility = performedCount > 0 
        ? (totalMobility / performedCount).clamp(0.0, 100.0).toDouble() 
        : 0.0;
    final double painLevel = lastResult.painLevel ?? 0.0;
    final double recoveryScore = (globalMobility * 0.7 + (10 - painLevel) * 10 * 0.3).clamp(0.0, 100.0).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(lastResult),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildKinematicsCard(analysisData),
                  const SizedBox(height: 24),
                  _buildDeficitIndicator(analysisData),
                  const SizedBox(height: 24),
                  _buildQualitySection(lastResult),
                  const SizedBox(height: 32),
                  _buildSymmetryScore(analysisData),
                  const SizedBox(height: 32),
                  _buildCorrelationCard(analysisData, painLevel),
                  const SizedBox(height: 32),
                  _buildGlobalRecoveryGauge(recoveryScore, globalMobility, painLevel),
                  const SizedBox(height: 40),
                  _buildNewSessionButton(context),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[200],
            backgroundImage: const AssetImage('lib/assets/images/doc_avatar.png'),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("SAHTECH", style: TextStyle(color: Color(0xFF0D54F2), fontWeight: FontWeight.w900, fontSize: 14)),
              Text("Dossier Médical", style: TextStyle(color: Color(0xFF1E293B), fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.settings_outlined, color: Color(0xFF1E293B)), onPressed: () {}),
      ],
    );
  }

  Widget _buildHeader(IATrackingData result) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("MOTEUR DE DIAGNOSTIC IA V4.3", style: TextStyle(color: Color(0xFF0D54F2), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          const Text("Résultat de\nPerformance IA", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF1E293B), height: 1.1)),
          const SizedBox(height: 12),
          Text("Analyse biomécanique avancée et corrélation neurale pour la rééducation de l'épaule.\nPatient : Jean-Dominique Morel", style: TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.5)),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF0D54F2).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  children: [
                    Icon(Icons.circle, color: Color(0xFF0D54F2), size: 8),
                    SizedBox(width: 8),
                    Text("Analyse en Direct 100%", style: TextStyle(color: Color(0xFF0D54F2), fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKinematicsCard(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("MOTEUR D'ANALYSE D'AMPLITUDE™", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  SizedBox(height: 4),
                  Text("Cinématique\nArticulaire", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                ],
              ),
              _buildSmallBadge("V4.3", "SEM-1"),
            ],
          ),
          const SizedBox(height: 32),
          ...data.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: _buildClinicalProgressBar(
              m['name'].toString(), 
              (m['patho'] as num).toDouble(), 
              (m['max'] as num).toDouble(), 
              (m['delta'] as num).toDouble(),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildClinicalProgressBar(String label, double val, double max, double delta) {
    final bool isPositive = delta >= 0;
    final double progress = (val / max).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
            Text(
              "${val.toInt()}°  ${isPositive ? '+' : ''}${delta.toInt()}°", 
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isPositive ? const Color(0xFF0D54F2) : const Color(0xFFEF4444)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(height: 6, width: constraints.maxWidth, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(3))),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  height: 6,
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF0D54F2), Color(0xFF3B82F6)]),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDeficitIndicator(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    // Detect largest deficit
    var worstMove = data.first;
    double maxDeficit = 0;
    for (var m in data) {
      double deficit = ((m['healthy'] as num) - (m['patho'] as num)).clamp(0.0, 500.0).toDouble();
      if (deficit > maxDeficit) {
        maxDeficit = deficit;
        worstMove = m;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFF1F5FF), borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.analytics_outlined, color: Color(0xFF0D54F2), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Indicateur de Déficit", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(
                  "Zone de restriction détectée en fin de course d'${worstMove['name']} (${worstMove['patho'].toInt()}° - ${worstMove['max'].toInt()}°).",
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualitySection(IATrackingData result) {
    // ── Contrôle Moteur : score composite sur 4 critères cliniques
    // 1. Posture générale correcte (booléen IA)
    // 2. Coude étendu pendant le geste (flexion minimale ≥ 160°)
    // 3. Précision du mouvement (champ 'precision' 0-1, seuil > 0.65)
    // 4. Déséquilibre scapulaire faible pendant le geste (< 10°)
    int motorScore = 0;
    if (result.isPostureCorrect) motorScore++;
    if (result.minElbowFlexion >= 160.0) motorScore++;
    if (result.precision > 0.65) motorScore++;
    if (result.avgShoulderImbalance < 10.0) motorScore++;

    final String motorStatus;
    final Color motorColor;
    final String motorSub;
    if (motorScore == 4) {
      motorStatus = "EXCELLENT";
      motorColor = const Color(0xFF10B981);
      motorSub = "Contrôle neuro-moteur optimal (4/4 critères validés)";
    } else if (motorScore == 3) {
      motorStatus = "BON";
      motorColor = const Color(0xFF10B981);
      motorSub = "Contrôle satisfaisant (${motorScore}/4) — légères irrégularités";
    } else if (motorScore == 2) {
      motorStatus = "MODÉRÉ";
      motorColor = const Color(0xFFF59E0B);
      motorSub = "Contrôle partiel (${motorScore}/4) — coude: ${result.minElbowFlexion.toInt()}°, précision: ${(result.precision * 100).toInt()}%";
    } else {
      motorStatus = "INSUFFISANT";
      motorColor = const Color(0xFFEF4444);
      motorSub = "Contrôle insuffisant (${motorScore}/4) — réévaluation recommandée";
    }

    // ── Compensations : basé sur l'inclinaison du tronc
    final bool hasCompensation = result.avgTrunkLean.abs() > 8.0;
    final String compSub = hasCompensation
        ? "Inclinaison du tronc détectée : ${result.avgTrunkLean.toStringAsFixed(1)}° (norme < 8°)"
        : "Aucune compensation significative observée";
    final String compStatus = hasCompensation ? "MODÉRÉ" : "NORMAL";
    final Color compColor = hasCompensation ? const Color(0xFFF59E0B) : const Color(0xFF10B981);

    // ── Dyskinesie Scapulaire : basé sur le déséquilibre des épaules
    final bool hasDyskinesia = result.avgShoulderImbalance > 12.0;
    final String dysSub = hasDyskinesia
        ? "Asymétrie scapulaire de ${result.avgShoulderImbalance.toStringAsFixed(1)}° — pattern anormal"
        : "Symétrie scapulaire dans les normes (${result.avgShoulderImbalance.toStringAsFixed(1)}°)";
    final String dysStatus = hasDyskinesia ? "DÉPISTÉ" : "NORMAL";
    final Color dysColor = hasDyskinesia ? const Color(0xFF0D54F2) : const Color(0xFF10B981);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("ANALYSE DE LA QUALITÉ DU MOUVEMENT™", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 16),
        _buildQualityCard("Contrôle Moteur", motorSub, motorStatus, motorColor),
        const SizedBox(height: 12),
        _buildQualityCard("Compensations", compSub, compStatus, compColor),
        const SizedBox(height: 12),
        _buildQualityCard("Dyskinesie Scapulaire", dysSub, dysStatus, dysColor),
      ],
    );
  }

  Widget _buildQualityCard(String title, String sub, String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.check_circle_outline, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              Text(sub, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
            ]),
          ),
          Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _buildSymmetryScore(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    // Average healthy vs patho
    double avgHealthy = 0;
    double avgPatho = 0;
    for (var m in data) {
      avgHealthy += m['healthy'];
      avgPatho += m['patho'];
    }
    avgHealthy /= data.length;
    avgPatho /= data.length;
    final int score = avgHealthy > 0 ? (avgPatho / avgHealthy * 100).clamp(0, 100).toInt() : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
      child: Column(
        children: [
          const Text("SCORE DE SYMÉTRIE DE L'ÉPAULE™", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildSymmetryBar("GAUCHE (SAIN)", 0.95),
              _buildSymmetryBar("DROITE (PATHO)", avgHealthy > 0 ? (avgPatho / avgHealthy) : 0.0),
            ],
          ),
          const SizedBox(height: 32),
          Text("$score%", style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
          const Text("Indice de Symétrie Dynamique", style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSymmetryBar(String label, double ratio) {
    return Column(
      children: [
        Container(
          width: 90, 
          height: 140 * ratio.clamp(0.1, 1.0), 
          decoration: BoxDecoration(
            color: const Color(0xFF0D54F2), 
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: const Color(0xFF0D54F2).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
          )
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8))),
      ],
    );
  }

  Widget _buildCorrelationCard(List<Map<String, dynamic>> data, double pain) {
    if (data.isEmpty) return const SizedBox.shrink();
    final flexion = data.firstWhere((element) => element['id'] == 'flexion', orElse: () => data.first);
    final double gain = (flexion['delta'] as num).toDouble();
    final String exerciseName = flexion['name'].toString();
    final double flexionPatho = (flexion['patho'] as num).toDouble();

    // Génère un titre et un texte analytique basés sur les vraies données
    final bool improving = gain > 0;
    final bool hasPain = pain > 2.0;
    final String correlationTitle = improving
        ? "Amélioration de la mobilité avec diminution de la douleur"
        : "Maintien de l'amplitude — travail de consolidation";
    final String correlationBody = gain != 0
        ? "L'analyse croisée indique un ${improving ? 'gain' : 'déficit'} de ${gain.abs().toInt()}° en $exerciseName "
          "(amplitude actuelle : ${flexionPatho.toInt()}°). "
          "${hasPain ? 'La douleur rapportée (${pain.toStringAsFixed(1)}/10) indique une sensibilisation périphérique résiduelle. Un travail de désensibilisation progressive est recommandé.' 
          : 'Absence de douleur significative (${pain.toStringAsFixed(1)}/10) — tolérance tissulaire satisfaisante. Progression vers des amplitudes plus élevées possible.'}"
        : "Première séance enregistrée. Les prochaines sessions permettront de calculer votre courbe de progression personnalisée.";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0D54F2), Color(0xFF1E40AF)]),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: const Color(0xFF0D54F2).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("CORRÉLATION DOULEUR +\nMOUVEMENT™", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          Text(correlationTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
          const SizedBox(height: 24),
          Text(
            correlationBody,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 32),
          _buildWorkloadChart(),
        ],
      ),
    );
  }

  Widget _buildWorkloadChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Charge de travail", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                Text("1.5", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.normal)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text("+18%", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                Text("(Optimum)", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 8, fontWeight: FontWeight.normal)),
              ]),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _miniBar(0.3), _miniBar(0.4), _miniBar(0.6), _miniBar(0.8), _miniBar(1.0, color: Colors.white),
            ],
          ),
          const SizedBox(height: 16),
          const Text("PROJECTION RÉCUPÉRATION : 22 JOURS", style: TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _miniBar(double h, {Color color = Colors.white54}) => Container(width: 25, height: 40 * h, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)));

  Widget _buildGlobalRecoveryGauge(double score, double mobility, double pain) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
      child: Column(
        children: [
          const Text("SCORE DE RÉCUPÉRATION SAHTECH™", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 32),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(width: 180, height: 180, child: CircularProgressIndicator(value: score / 100, strokeWidth: 12, backgroundColor: const Color(0xFFF1F5F9), valueColor: const AlwaysStoppedAnimation(Color(0xFF0D54F2)))),
              Column(
                children: [
                  Text("${score.toInt()}", style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                  const Text("/ 100", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _metricSummary("MOBILITÉ", "${mobility.toInt()}%"),
              _metricSummary("DOULEUR", "${(pain * 10).toInt()}%", color: const Color(0xFFEF4444)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricSummary(String label, String val, {Color color = const Color(0xFF1E293B)}) {
    return Column(children: [
      Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
      const SizedBox(height: 4),
      Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
    ]);
  }

  Widget _buildSmallBadge(String val, String sub) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: Color(0xFFDBEAFE), shape: BoxShape.circle),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF0D54F2))),
          Text(sub, style: const TextStyle(fontSize: 6, fontWeight: FontWeight.bold, color: Color(0xFF0D54F2))),
        ],
      ),
    );
  }

  Widget _buildNewSessionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Provider.of<GlobalDataProvider>(context, listen: false).resetCurrentSession();
          Navigator.pushNamedAndRemoveUntil(context, '/selection_test_ia', (route) => false);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D54F2), 
          padding: const EdgeInsets.symmetric(vertical: 20), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          shadowColor: const Color(0xFF0D54F2).withOpacity(0.3),
        ),
        child: const Text("REDÉMARRER UNE SÉANCE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
      ),
    );
  }
}
