import 'package:flutter/material.dart';

class QualityAntiTricheWidget extends StatelessWidget {
  final double trunkLeanAngle;
  final double elbowFlexion;
  final bool isPostureCorrect;

  const QualityAntiTricheWidget({
    Key? key,
    required this.trunkLeanAngle,
    required this.elbowFlexion,
    required this.isPostureCorrect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FF).withOpacity(0.5),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          _buildMetricRow(
            label: "INCLINAISON TRONC",
            value: "${trunkLeanAngle.toStringAsFixed(1)}°",
            status: trunkLeanAngle < 15 ? "VALIDE" : "ALERTE",
            statusColor: trunkLeanAngle < 15
                ? const Color(0xFF10B981)
                : Colors.orange,
            progress: (trunkLeanAngle / 45).clamp(0.0, 1.0),
            threshold: "Seuil: 15°",
          ),
          const SizedBox(height: 32),
          _buildMetricRow(
            label: "FLEXION COUDE",
            value: "${elbowFlexion.toInt()}°",
            status: elbowFlexion > 150 ? "VALIDE" : "ÉCHEC",
            statusColor: elbowFlexion > 150
                ? const Color(0xFF10B981)
                : const Color(0xFFEF4444),
            progress: (elbowFlexion / 180).clamp(0.0, 1.0),
            threshold: "Seuil: 150°",
            isError: elbowFlexion <= 150,
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              const Text(
                "POSTURE CORRECTE",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPostureCorrect
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isPostureCorrect ? "VRAI" : "FAUX",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isPostureCorrect
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
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

  Widget _buildMetricRow({
    required String label,
    required String value,
    required String status,
    required Color statusColor,
    required double progress,
    required String threshold,
    bool isError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                threshold,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      isError ? Icons.history : Icons.check_circle_outline,
                      size: 13,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              isError ? const Color(0xFFEF4444) : const Color(0xFF0D54F2),
            ),
          ),
        ),
      ],
    );
  }
}
