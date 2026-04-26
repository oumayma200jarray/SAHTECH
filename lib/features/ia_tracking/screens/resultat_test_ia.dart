import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sahtek/models/ia_tracking_model.dart';
import 'package:sahtek/core/widgets/time_lapse_player.dart';

// Importation des sous-widgets modularisés
import '../widgets/results/result_professional_chart.dart';
import '../widgets/results/rom_analysis_widget.dart';
import '../widgets/results/quality_anti_triche_widget.dart';
import '../widgets/results/exercise_status_timeline.dart';
import '../widgets/results/ai_diagnostic_feedback.dart';
import '../services/report_service.dart';

/// Page de résultats principale (Layout).
class ResultatsTestIAPage extends StatelessWidget {
  ResultatsTestIAPage({Key? key}) : super(key: key);

  final ReportService _reportService = ReportService();

  @override
  Widget build(BuildContext context) {
    final lastResult = Provider.of<GlobalDataProvider>(
      context,
    ).lastTrackingResult;

    if (lastResult == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        appBar: _buildAppBar(context),
        body: Center(child: Text('no_content_available'.tr())),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGlobalSummary(lastResult),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(
                    Icons.share,
                    "1. Analyse Posturale & Géométrique",
                  ),
                  const SizedBox(height: 16),
                  ROMAnalysisCard(
                    title: "ROM : FLEXION",
                    subtitle: "Points de repère Google ML Kit",
                    value: "${lastResult.currentValue.toStringAsFixed(1)}°",
                    label: "ÉLÉVATION",
                    progress: (lastResult.currentValue / lastResult.objective)
                        .clamp(0.0, 1.0),
                    imagePath: lastResult.sessionFrames.isNotEmpty
                        ? lastResult.sessionFrames.last
                        : null,
                  ),
                  const SizedBox(height: 16),
                  ROMAnalysisCard(
                    title: "ROM : ABDUCTION",
                    subtitle: "Calcul Vectoriel",
                    value: lastResult.currentValue > 170 ? "OPTIMALE" : "${lastResult.currentValue.toStringAsFixed(1)}°",
                    label: "AMPLITUDE",
                    progress: (lastResult.currentValue / lastResult.objective)
                        .clamp(0.0, 1.0),
                    imagePath: lastResult.sessionFrames.length > 1
                        ? lastResult.sessionFrames[lastResult
                                  .sessionFrames
                                  .length -
                              2]
                        : null,
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle(Icons.bar_chart, "Analyse Temporelle"),
                  const SizedBox(height: 8),
                  Text(
                    "Le nombre de points de données s'ajuste automatiquement selon le nombre de répétitions effectuées durant la session.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ResultChartCard(
                    title: "Évolution de la Mobilité (ROM)",
                    icon: Icons.trending_up,
                    iconColor: const Color(0xFF0D54F2),
                    footerLabel: "Axe Y: Angle (°)",
                    footerValue: lastResult.angleHistory.length > 1 
                        ? "+${(lastResult.angleHistory.last - lastResult.angleHistory.first).toStringAsFixed(1)}° progression"
                        : "Session initiale",
                    footerValueColor: const Color(0xFF0D54F2),
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: ProfessionalChartPainter(
                        data: lastResult.angleHistory.isNotEmpty
                            ? lastResult.angleHistory
                            : [30, 35, 42, 48, 55, 68, 72, 78],
                        color: const Color(0xFF0D54F2),
                        maxY: 180,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ResultChartCard(
                    title: "Suivi de la Douleur (EVA)",
                    icon: Icons.auto_graph,
                    iconColor: const Color(0xFFA34914),
                    footerLabel: "Axe Y: Intensité (1-10)",
                    footerValue: "-6.5 pts réduction",
                    footerValueColor: const Color(0xFFA34914),
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: ProfessionalChartPainter(
                        data: lastResult.painHistory.isNotEmpty
                            ? lastResult.painHistory
                            : [8, 7.5, 7, 6.5, 5, 4.5, 3.8, 3],
                        color: const Color(0xFFA34914),
                        maxY: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle(
                    Icons.security,
                    "2. Qualité du Mouvement (\"Anti-Triche\")",
                  ),
                  const SizedBox(height: 20),
                  QualityAntiTricheWidget(
                    trunkLeanAngle: lastResult.trunkLeanAngle,
                    elbowFlexion: lastResult.elbowFlexion,
                    isPostureCorrect: lastResult.isPostureCorrect,
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle(
                    Icons.dashboard_customize,
                    "3. État de l'Exercice",
                  ),
                  const SizedBox(height: 20),
                  ExerciseStatusTimeline(
                    validatedReps: lastResult.repetitionCount,
                    totalReps: lastResult.totalRepsPlanned,
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle(
                    Icons.auto_awesome,
                    "4. Feedback Local & Recommandations",
                  ),
                  const SizedBox(height: 20),
                  AIDiagnosticFeedback(
                    elbowFlexion: lastResult.minElbowFlexion,
                    shoulderImbalance: lastResult.avgShoulderImbalance,
                    aiSummary: lastResult.aiSummary,
                    onGeneratePDF: () =>
                        _reportService.generateAndOpenReport(lastResult),
                  ),
                  const SizedBox(height: 32),
                  _buildVideoReview(lastResult),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: const Text(
        'Rapport Biomécanique SAHTECH',
        style: TextStyle(
          color: Color(0xFF0D54F2),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  double _qualityPercent(IATrackingData result) {
    // Backward compatibility: older sessions may store precision in [0..1].
    final raw = result.precision;
    final normalized = raw <= 1.0 ? raw * 100.0 : raw;
    return normalized.clamp(0.0, 100.0);
  }

  String _qualityLabel(double quality) {
    if (quality >= 85) return 'Optimale';
    if (quality >= 65) return 'Acceptable';
    return 'À corriger';
  }

  double _mobilityPercent(IATrackingData result) {
    if (result.objective <= 0) return 0.0;
    return ((result.currentValue / result.objective) * 100.0).clamp(0.0, 100.0);
  }

  double _posturePercent(IATrackingData result) {
    final trunkPenalty = (result.trunkLeanAngle / 30.0).clamp(0.0, 1.0);
    final elbowPenalty = ((180.0 - result.elbowFlexion) / 60.0).clamp(0.0, 1.0);
    final score = 100.0 - ((trunkPenalty * 40.0) + (elbowPenalty * 40.0));
    return (result.isPostureCorrect ? score : score - 20.0).clamp(0.0, 100.0);
  }

  Widget _buildGlobalSummary(IATrackingData result) {
    final quality = _qualityPercent(result);
    final qualityLabel = _qualityLabel(quality);
    final mobility = _mobilityPercent(result);
    final posture = _posturePercent(result);

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Analyse Cinématique\nSAHTECH",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D54F2), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D54F2).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "QUALITÉ D'EXÉCUTION",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${quality.toStringAsFixed(1)}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.white24),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Qualité Biomécanique : $qualityLabel",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Moteur local Google ML Kit : Actif",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildBreakdownCard(
                  label: 'Mobilité',
                  value: mobility,
                  color: const Color(0xFF0D54F2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBreakdownCard(
                  label: 'Posture',
                  value: posture,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard({
    required String label,
    required double value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${value.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0D54F2), size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoReview(IATrackingData result) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: TimeLapsePlayer(images: result.sessionFrames, height: 60),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Revoir l\'exécution',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'Vidéo analysée localement • 0:12',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[300]),
        ],
      ),
    );
  }
}
