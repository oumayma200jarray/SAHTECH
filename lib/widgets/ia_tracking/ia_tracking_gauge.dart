import 'package:flutter/material.dart';

class IATrackingGauge extends StatelessWidget {
  final double currentValue;
  final double objective;
  final String unit;

  const IATrackingGauge({
    Key? key,
    required this.currentValue,
    required this.objective,
    required this.unit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = (currentValue / objective).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0 ? Colors.green : Colors.blue,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${currentValue.toInt()}$unit',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                     progress >= 1.0 ? 'Objectif !' : 'Cible: ${objective.toInt()}$unit',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
