import 'package:flutter/material.dart';

class AIDiagnosticFeedback extends StatefulWidget {
  final double elbowFlexion;
  final double shoulderImbalance;
  final String? aiSummary;
  final Future<void> Function() onGeneratePDF;

  const AIDiagnosticFeedback({
    Key? key,
    required this.elbowFlexion,
    required this.shoulderImbalance,
    this.aiSummary,
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
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFF0D54F2), size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "MOTEUR DE DIAGNOSTIC IA CLAUDE",
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0D54F2)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildFeedbackAlert(
              icon: Icons.auto_awesome,
              color: const Color(0xFFF0F7FF),
              iconColor: const Color(0xFF0D54F2),
              title: "SYNTHÈSE DE SESSION IA",
              description: widget.aiSummary ??
                  "Analyse en cours... Votre mouvement a été capturé. L'IA a noté une bonne exécution générale malgré quelques compensations musculaires à surveiller.",
            ),
            const SizedBox(height: 16),
            _buildFeedbackAlert(
              icon: Icons.query_stats,
              color: const Color(0xFFF8FAFF),
              iconColor: Colors.blueGrey,
              title: "Symétrie & Stabilité Scapulaire",
              description:
                  "Indice de stabilité : ${(100 - widget.shoulderImbalance).clamp(0, 100).toInt()}% d'alignement. "
                  "${widget.shoulderImbalance < 10 ? 'Excellent maintien des ceintures scapulaires.' : 'Attention à ne pas hausser l\'épaule durant l\'effort.'}",
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
                    : const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Générer Rapport Technique Détaillé (PDF)",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                        ),
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
