import 'package:flutter/material.dart';

class ROMAnalysisCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String label;
  final double progress;
  final String? imagePath;

  const ROMAnalysisCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.label,
    required this.progress,
    this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF0D54F2), fontSize: 9, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF0F5FF), borderRadius: BorderRadius.circular(8)),
                child: Text(value, style: const TextStyle(color: Color(0xFF0D54F2), fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFF),
              borderRadius: BorderRadius.circular(16),
              image: imagePath != null ? DecorationImage(image: AssetImage(imagePath!), fit: BoxFit.cover) : null,
            ),
            child: imagePath == null ? const Center(child: Icon(Icons.accessibility_new, color: Color(0xFF0D54F2), size: 40)) : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D54F2)),
                    minHeight: 6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
