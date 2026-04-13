import 'package:flutter/material.dart';

class ExerciseStatusTimeline extends StatelessWidget {
  final int validatedReps;
  final int totalReps;

  const ExerciseStatusTimeline({
    Key? key,
    required this.validatedReps,
    required this.totalReps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimelineStep("1", "REPOS", true, false),
              _buildTimelineStep("2", "PROGRESSION", true, false),
              _buildTimelineStep(
                "",
                "VALIDATION RÉP.",
                true,
                true,
                isCurrent: true,
              ),
              _buildTimelineStep("4", "TERMINÉ", false, false, isFuture: true),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  "RÉPÉTITIONS VALIDÉES",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      validatedReps.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D54F2),
                      ),
                    ),
                    Text(
                      " / $totalReps",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
    String label,
    String title,
    bool isCompleted,
    bool isIcon, {
    bool isCurrent = false,
    bool isFuture = false,
  }) {
    Color color = isCompleted ? const Color(0xFF0D54F2) : Colors.grey[200]!;
    if (isCurrent) color = const Color(0xFF0D54F2);

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCurrent ? Colors.white : (isFuture ? Colors.white : color),
            border: Border.all(
              color: isCurrent
                  ? const Color(0xFF0D54F2)
                  : (isFuture ? Colors.grey[100]! : color),
              width: isCurrent ? 2 : 1,
            ),
          ),
          child: Center(
            child: isIcon
                ? Icon(Icons.refresh, color: color, size: 20)
                : Text(
                    label,
                    style: TextStyle(
                      color: isFuture
                          ? Colors.grey[300]
                          : (isCurrent
                                ? const Color(0xFF0D54F2)
                                : Colors.white),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: isFuture ? Colors.grey[300] : color,
          ),
        ),
      ],
    );
  }
}
