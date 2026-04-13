import 'package:flutter/material.dart';

class AIDiagnosticFeedback extends StatefulWidget {
  final double elbowFlexion;
  final Future<void> Function() onGeneratePDF;

  const AIDiagnosticFeedback({
    Key? key,
    required this.elbowFlexion,
    required this.onGeneratePDF,
  }) : super(key: key);

  @override
  State<AIDiagnosticFeedback> createState() => _AIDiagnosticFeedbackState();
}

class _AIDiagnosticFeedbackState extends State<AIDiagnosticFeedback> {
  bool _isGenerating = false;

  Future<void> _handleGeneratePDF() async {
    setState(() => _isGenerating = true);
    try {
      await widget.onGeneratePDF();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de la génération : $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(24)),
        border: Border(left: BorderSide(color: Color(0xFFEF4444), width: 3)),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: Color(0xFF0D54F2), size: 14),
                SizedBox(width: 8),
                Text("MOTEUR DE DIAGNOSTIC IA CLAUDE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0D54F2))),
              ],
            ),
            const SizedBox(height: 20),
            _buildFeedbackAlert(
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFFFDF2F2),
              iconColor: const Color(0xFFEF4444),
              title: "CORRECTION PRIORITAIRE : FLEXION DU COUDE",
              description:
                  "L'IA a détecté une flexion du coude de ${widget.elbowFlexion.toInt()}° (seuil critique: 150°). Vous utilisez vos biceps pour compenser le manque de force du deltoïde antérieur. "
                  "Action corrective : Gardez le bras tendu tout au long du mouvement d'abduction.",
            ),
            const SizedBox(height: 16),
            _buildFeedbackAlert(
              icon: Icons.query_stats,
              color: const Color(0xFFF0F7FF),
              iconColor: const Color(0xFF0D54F2),
              title: "Stabilité Scapulaire (Validation Sémantique)",
              description:
                  "Analyse du schéma : Alignement dynamique stable. La symétrie de 94% indique que le recrutement des rotateurs est efficace malgré la compensation périphérique.",
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _handleGeneratePDF,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D54F2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isGenerating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Générer Rapport Technique Détaillé (PDF)",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackAlert({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: iconColor)),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(fontSize: 10, color: Colors.grey[800], height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
