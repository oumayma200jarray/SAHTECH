import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Un peintre personnalisé professionnel pour les graphiques de résultats.
class ProfessionalChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double maxY;

  ProfessionalChartPainter({required this.data, required this.color, required this.maxY});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final stepX = size.width / (data.length - 1);
    final path = Path();
    final labelPaint = TextPainter(textDirection: ui.TextDirection.ltr);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i] / maxY * size.height).clamp(0, size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevY = size.height - (data[i - 1] / maxY * size.height).clamp(0, size.height);
        path.cubicTo(prevX + stepX / 2, prevY, x - stepX / 2, y, x, y);
      }

      // Points de données
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = color);
      canvas.drawCircle(Offset(x, y), 2, Paint()..color = Colors.white);

      // Labels des répétitions (uniquement si l'espace est suffisant)
      if (data.length <= 10) {
        labelPaint.text = TextSpan(
          text: "RÉP.${i + 1}",
          style: TextStyle(color: Colors.grey[400], fontSize: 7, fontWeight: FontWeight.bold),
        );
        labelPaint.layout();
        labelPaint.paint(canvas, Offset(x - labelPaint.width / 2, size.height + 8));
      }
    }

    canvas.drawPath(path, paint);

    // Remplissage de zone avec dégradé
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.15), color.withOpacity(0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ResultChartCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final String footerLabel;
  final String footerValue;
  final Color footerValueColor;

  const ResultChartCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
    required this.footerLabel,
    required this.footerValue,
    required this.footerValueColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(height: 180, child: child),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(footerLabel, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text(footerValue, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: footerValueColor)),
            ],
          ),
        ],
      ),
    );
  }
}
