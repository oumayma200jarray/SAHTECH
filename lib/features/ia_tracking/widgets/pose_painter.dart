import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final bool isFrontCamera;

  PosePainter(
    this.poses,
    this.imageSize,
    this.rotation, {
    this.isFrontCamera = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..color = Colors.white;

    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..color = const Color(0xFF0D54F2);

    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..color = Colors.yellow;

    for (final pose in poses) {
      pose.landmarks.forEach((_, landmark) {
        if (landmark.likelihood < 0.35) return;
        canvas.drawCircle(
          Offset(
            _translateX(landmark.x, rotation, size, imageSize),
            _translateY(landmark.y, rotation, size, imageSize),
          ),
          4,
          Paint()
            ..color = paint.color
            ..style = PaintingStyle.fill,
        );
      });

      void paintLine(
        PoseLandmarkType type1,
        PoseLandmarkType type2,
        Paint paint,
      ) {
        final landmark1 = pose.landmarks[type1];
        final landmark2 = pose.landmarks[type2];
        if (landmark1 != null &&
            landmark2 != null &&
            landmark1.likelihood >= 0.35 &&
            landmark2.likelihood >= 0.35) {
          canvas.drawLine(
            Offset(
              _translateX(landmark1.x, rotation, size, imageSize),
              _translateY(landmark1.y, rotation, size, imageSize),
            ),
            Offset(
              _translateX(landmark2.x, rotation, size, imageSize),
              _translateY(landmark2.y, rotation, size, imageSize),
            ),
            paint,
          );
        }
      }

      // Draw arms
      paintLine(
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.leftElbow,
        leftPaint,
      );
      paintLine(
        PoseLandmarkType.leftElbow,
        PoseLandmarkType.leftWrist,
        leftPaint,
      );
      paintLine(
        PoseLandmarkType.rightShoulder,
        PoseLandmarkType.rightElbow,
        rightPaint,
      );
      paintLine(
        PoseLandmarkType.rightElbow,
        PoseLandmarkType.rightWrist,
        rightPaint,
      );

      // Draw body
      paintLine(
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.rightShoulder,
        paint,
      );
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, paint);
      paintLine(
        PoseLandmarkType.rightShoulder,
        PoseLandmarkType.rightHip,
        paint,
      );
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.poses != poses;
  }

  double _translateX(
    double x,
    InputImageRotation rotation,
    Size size,
    Size imageSize,
  ) {
    final bool mirrored = isFrontCamera;
    final double translatedX;
    switch (rotation) {
      case InputImageRotation.rotation90deg:
        translatedX = x * size.width / imageSize.height;
        break;
      case InputImageRotation.rotation270deg:
        translatedX = size.width - x * size.width / imageSize.height;
        break;
      case InputImageRotation.rotation180deg:
        translatedX = size.width - x * size.width / imageSize.width;
        break;
      default:
        translatedX = x * size.width / imageSize.width;
    }
    return mirrored ? size.width - translatedX : translatedX;
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
      case InputImageRotation.rotation180deg:
        return size.height - y * size.height / imageSize.height;
      default:
        return y * size.height / imageSize.height;
    }
  }
}
