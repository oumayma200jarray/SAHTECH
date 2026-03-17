import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sahtek/models/ia_tracking_model.dart';
import 'package:sahtek/core/widgets/time_lapse_player.dart';

class ResultatsTestIAPage extends StatelessWidget {
  const ResultatsTestIAPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lastResult = Provider.of<GlobalDataProvider>(
      context,
    ).lastTrackingResult;

    if (lastResult == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: Center(child: Text('no_content_available'.tr())),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreBadge(lastResult),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  _buildResultsCard(lastResult),
                  const SizedBox(height: 32),
                  _buildMovementAnalysis(lastResult),
                  const SizedBox(height: 32),
                  _buildReviewExecution(lastResult),
                  const SizedBox(height: 48),
                  _buildActionButtons(context),
                  const SizedBox(height: 48),
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
      leadingWidth: 70,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Center(
          child: CircleAvatar(
            backgroundColor: const Color(0xFFF0F5FF),
            radius: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Color(0xFF0D54F2),
                size: 18,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      title: Text(
        'ia_results_title'.tr(),
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildScoreBadge(IATrackingData result) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      child: const Column(children: [SizedBox(height: 10)]),
    );
  }

  Widget _buildResultsCard(IATrackingData result) {
    final double progress = (result.currentValue / result.objective).clamp(
      0.0,
      1.0,
    );

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 2,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF0D54F2),
                  ),
                ),
              ),
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${result.currentValue.toInt()}°',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D54F2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F9F1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stars, color: Color(0xFF10B981), size: 16),
                SizedBox(width: 8),
                Text(
                  "NOUVEAU RECORD",
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Mobilité excellente",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Progression de +10° par rapport à votre session du 12 oct.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[400],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovementAnalysis(IATrackingData result) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ANALYSE TEMPORELLE'.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 1.0,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Suivi de Récupération',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildLegendItem("MOBILITÉ", const Color(0xFF0D54F2)),
                  const SizedBox(width: 16),
                  _buildLegendItem("DOULEUR", const Color(0xFFFF5252)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: MovementChartPainter(
                      result.angleHistory,
                      result.painHistory,
                      result.objective,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Builder(builder: (context) {
                  // Dates des sessions passées + date actuelle
                  final provider = Provider.of<GlobalDataProvider>(context, listen: false);
                  final history = provider.trackingHistory;
                  final List<DateTime> sessionDates;
                  if (history.length >= 5) {
                    sessionDates = history.sublist(history.length - 5).map((e) => e.date).toList();
                  } else if (history.isNotEmpty) {
                    sessionDates = history.map((e) => e.date).toList();
                  } else {
                    // Placeholder : 5 dates fictives hebdomadaires
                    sessionDates = List.generate(5, (i) => result.date.subtract(Duration(days: (4 - i) * 7)));
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: sessionDates.map((date) {
                      bool isLast = date == sessionDates.last;
                      final label = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isLast ? const Color(0xFFF0F5FF) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isLast ? const Color(0xFF0D54F2) : Colors.grey[400],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewExecution(IATrackingData result) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
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
                    'Vidéo analysée par l\'IA • 0:12',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/preparation_test_ia'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              side: BorderSide(color: Colors.grey[200]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, size: 20, color: Color(0xFF1E293B)),
                SizedBox(width: 8),
                Text(
                  'Réessayer',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/accueil',
              (route) => false,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D54F2),
              padding: const EdgeInsets.symmetric(vertical: 20),
              elevation: 10,
              shadowColor: const Color(0xFF0D54F2).withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save, size: 20, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Enregistrer',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MovementChartPainter extends CustomPainter {
  final List<double> mobilityData;
  final List<double> painData;
  final double objective;

  MovementChartPainter(this.mobilityData, this.painData, this.objective);

  @override
  void paint(Canvas canvas, Size size) {
    // 0. Setup drawing area and scales
    final double maxMobilityY = objective * 1.25;
    const double maxPainY = 10.0;

    final gridPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 1;

    // 1. Draw Grid Lines (Horizontal)
    for (int i = 0; i <= 4; i++) {
      double y = size.height - (i * size.height / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Draw Mobility Curve (Blue)
    List<double> mobilityToDraw = mobilityData.isNotEmpty ? List.from(mobilityData) : [25, 35, 45, 60, 80];
    if (mobilityToDraw.length == 1) mobilityToDraw.insert(0, mobilityToDraw.first * 0.8);
    
    _drawCurve(
      canvas,
      size,
      mobilityToDraw,
      maxMobilityY,
      const Color(0xFF0D54F2),
      size.width / (mobilityToDraw.length - 1),
      true,
      mobilityData.isNotEmpty ? "mobility" : "",
    );

    // 3. Draw Pain Curve (Red) - inverse of mobility (descending)
    final List<double> mobilityForInverse = mobilityToDraw;
    final double mobilityMax = mobilityForInverse.reduce((a, b) => a > b ? a : b);
    List<double> painToDraw;
    if (painData.isNotEmpty) {
      painToDraw = List.from(painData);
    } else {
      // Default: inverse of the mobility placeholder (descending)
      painToDraw = mobilityForInverse.map((v) => ((mobilityMax - v) / mobilityMax) * maxPainY).toList();
    }
    if (painToDraw.length == 1) painToDraw.insert(0, painToDraw.first + 1);

    _drawCurve(
      canvas,
      size,
      painToDraw,
      maxPainY,
      const Color(0xFFFF5252),
      size.width / (painToDraw.length - 1),
      false,
      painData.isNotEmpty ? "pain" : "",
    );
  }

  void _drawCurve(
    Canvas canvas,
    Size size,
    List<double> points,
    double maxY,
    Color color,
    double stepX,
    bool fill,
    String type,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final double x = i * stepX;
      final double y =
          size.height - (points[i] / maxY * size.height).clamp(0, size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Smooth curve
        final double prevX = (i - 1) * stepX;
        final double prevY =
            size.height -
            (points[i - 1] / maxY * size.height).clamp(0, size.height);
        path.cubicTo(prevX + stepX / 2, prevY, x - stepX / 2, y, x, y);
      }
    }

    canvas.drawPath(path, paint);

    if (fill) {
      final fillPath = Path.from(path)
        ..lineTo((points.length - 1) * stepX, size.height)
        ..lineTo(0, size.height)
        ..close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.1), Colors.white.withOpacity(0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(fillPath, fillPaint);
    }

    // End point marker
    if (points.isNotEmpty && type.isNotEmpty) {
      final lastIndex = points.length - 1;
      final lastX = lastIndex * stepX;
      final lastY =
          size.height -
          (points.last / maxY * size.height).clamp(0, size.height);

      // Point
      canvas.drawCircle(Offset(lastX, lastY), 4, Paint()..color = color);
      canvas.drawCircle(
        Offset(lastX, lastY),
        6,
        Paint()..color = color.withOpacity(0.2),
      );

      // Value Label
      final textPainter = TextPainter(
        text: TextSpan(
          text: type == "mobility"
              ? "${points.last.toInt()}°"
              : "VAS ${points.last.toInt()}",
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(lastX - textPainter.width / 2, lastY - 20),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
