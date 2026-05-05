import 'package:flutter/material.dart';
import 'package:sahtek/models/pose_model.dart';

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final bool isFrontCamera;
  final bool? isLeftArmActive;
  final double currentAngle;

  PosePainter(
    this.poses,
    this.imageSize,
    this.rotation, {
    this.isFrontCamera = false,
    this.isLeftArmActive,
    this.currentAngle = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.white70;

    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [Color(0xFF0D54F2), Color(0xFF4ADE80)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final inactivePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.white24;

    for (final pose in poses) {
      // 1. Ligne de référence verticale (Spine Alignment)
      // Senior AI: On utilise les hanches si possible, sinon les épaules comme repli
      final lHip = pose.landmarks[PoseLandmarkType.leftHip];
      final rHip = pose.landmarks[PoseLandmarkType.rightHip];
      final lSh = pose.landmarks[PoseLandmarkType.leftShoulder];
      final rSh = pose.landmarks[PoseLandmarkType.rightShoulder];
      
      double? midX;
      if (lHip != null && rHip != null) {
        midX = (lHip.x + rHip.x) / 2;
      } else if (lSh != null && rSh != null) {
        midX = (lSh.x + rSh.x) / 2;
      }

      if (midX != null) {
        final translatedMidX = _translateX(midX, rotation, size, imageSize);
        canvas.drawLine(
          Offset(translatedMidX, 0),
          Offset(translatedMidX, size.height),
          Paint()
            ..color = Colors.white.withOpacity(0.15)
            ..strokeWidth = 1.0
            ..style = PaintingStyle.stroke,
        );
      }

      // 2. Dessiner les connexions (Squelette)
      void paintLine(
        PoseLandmarkType type1,
        PoseLandmarkType type2,
        Paint p, {
        bool isAxis = false,
      }) {
        final landmark1 = pose.landmarks[type1];
        final landmark2 = pose.landmarks[type2];
        if (landmark1 != null &&
            landmark2 != null &&
            landmark1.likelihood >= 0.1 &&
            landmark2.likelihood >= 0.1) {
          canvas.drawLine(
            Offset(
              _translateX(landmark1.x, rotation, size, imageSize),
              _translateY(landmark1.y, rotation, size, imageSize),
            ),
            Offset(
              _translateX(landmark2.x, rotation, size, imageSize),
              _translateY(landmark2.y, rotation, size, imageSize),
            ),
            p,
          );
        }
      }

      // Bras Gauche
      final Paint lArmPaint = (isLeftArmActive == true) ? activePaint : inactivePaint;
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, lArmPaint);
      paintLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, lArmPaint);

      // Bras Droit
      final Paint rArmPaint = (isLeftArmActive == false) ? activePaint : inactivePaint;
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, rArmPaint);
      paintLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, rArmPaint);

      // Tronc et Épaules
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder, paint);
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, paint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, paint);
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip, paint);

      // 3. Dessiner les Articulations (Glow effect)
      pose.landmarks.forEach((type, landmark) {
        if (landmark.likelihood < 0.1) return;

        final offset = Offset(
          _translateX(landmark.x, rotation, size, imageSize),
          _translateY(landmark.y, rotation, size, imageSize),
        );

        // Glow
        canvas.drawCircle(
          offset,
          8.0,
          Paint()
            ..color = (isLeftArmActive != null && type.name.contains(isLeftArmActive! ? 'left' : 'right'))
                ? const Color(0xFF0D54F2).withOpacity(0.3)
                : Colors.white10
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );

        // Joint Point
        canvas.drawCircle(
          offset,
          4.0,
          Paint()
            ..color = (isLeftArmActive != null && type.name.contains(isLeftArmActive! ? 'left' : 'right'))
                ? const Color(0xFF0D54F2)
                : Colors.white
            ..style = PaintingStyle.fill,
        );

        // 4. Étiquette d'Angle (Uniquement pour l'épaule active)
        if ((isLeftArmActive == true && type == PoseLandmarkType.leftShoulder) ||
            (isLeftArmActive == false && type == PoseLandmarkType.rightShoulder)) {
          _drawAngleLabel(canvas, offset, currentAngle);
        }
      });
    }
  }

  void _drawAngleLabel(Canvas canvas, Offset offset, double angle) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: "${angle.toInt()}°",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(blurRadius: 4, color: Colors.black)],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset + const Offset(15, -15));
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.poses != poses ||
        oldDelegate.isLeftArmActive != isLeftArmActive ||
        oldDelegate.currentAngle != currentAngle;
  }

  double _translateX(
    double x,
    InputImageRotation rotation,
    Size size,
    Size imageSize,
  ) {
    // Senior AI: On simplifie la logique pour éviter les inversions parasites
    switch (rotation) {
      case InputImageRotation.rotation90deg:
      case InputImageRotation.rotation270deg:
        // En portrait, on mappe sur imageSize.height
        final double val = x * size.width / imageSize.height;
        return isFrontCamera ? size.width - val : val;
      default:
        final double val = x * size.width / imageSize.width;
        return isFrontCamera ? size.width - val : val;
    }
  }

  double _translateY(
    double y,
    InputImageRotation rotation,
    Size size,
    Size imageSize,
  ) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
      case InputImageRotation.rotation270deg:
        return y * size.height / imageSize.width;
      default:
        return y * size.height / imageSize.height;
    }
  }
}
