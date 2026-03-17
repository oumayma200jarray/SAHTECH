import 'package:flutter/material.dart';

class IAFeedbackBadges extends StatelessWidget {
  final int completedReps;
  final double maxAngle;
  final String unit;

  const IAFeedbackBadges({
    Key? key,
    required this.completedReps,
    required this.maxAngle,
    required this.unit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBadge(
          icon: Icons.repeat,
          label: 'Répétitions',
          value: '$completedReps',
          color: Colors.orange,
        ),
        _buildBadge(
          icon: Icons.height,
          label: 'Record',
          value: '${maxAngle.toInt()}$unit',
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
