import 'package:flutter/material.dart';
import 'package:sahtek/models/ia_tracking_model.dart';
import 'package:sahtek/models/pose_model.dart';

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final bool isFrontCamera;
  final bool? isLeftArmActive;
  final double currentAngle;

  final CameraView? selectedView;
  final String exerciseId;

  bool? isLeftSideVisible;

  PosePainter(
    this.poses,
    this.imageSize,
    this.rotation, {
    this.isFrontCamera = false,
    this.isLeftArmActive,
    this.currentAngle = 0.0,
    this.selectedView,
    this.isLeftSideVisible,
    this.exerciseId = '',
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Colors for Premium Clinical Design
    const Color neonJointColor = Color(0xFF4ADE80); // Vibrant Green
    const Color activeJointColor = Color(0xFF0D54F2); // Sahtech Blue
    const Color skeletonColor = Colors.white;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = skeletonColor.withAlpha(180);

    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..color = activeJointColor;

    final activeGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..color = activeJointColor.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final neonPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = neonJointColor;

    for (final pose in poses) {
      _drawGuidanceZones(canvas, size);

      // 0. Side Locking Logic (Profile View)
      final bool? leftSideLocked = isLeftSideVisible;

      // 1. Draw Skeleton Lines
      void paintLine(PoseLandmarkType type1, PoseLandmarkType type2, Paint p, {bool forceDisplay = false}) {
        final landmark1 = pose.landmarks[type1];
        final landmark2 = pose.landmarks[type2];

        if (landmark1 == null ||
            landmark2 == null ||
            landmark1.likelihood < 0.35 ||
            landmark2.likelihood < 0.35)
          return;

        // --- Fit-to-Aspect Scaling for Lines ---
        final double scaleX =
            rotation == InputImageRotation.rotation90deg ||
                rotation == InputImageRotation.rotation270deg
            ? size.width / imageSize.height
            : size.width / imageSize.width;
        final double scaleY =
            rotation == InputImageRotation.rotation90deg ||
                rotation == InputImageRotation.rotation270deg
            ? size.height / imageSize.width
            : size.height / imageSize.height;

        // Profile Filtering: Surgical Isolation (SKIP for active/forced lines)
        if (!forceDisplay && selectedView == CameraView.profile && leftSideLocked != null) {
          final bool connIsLeft =
              type1.name.contains('left') || type2.name.contains('left');
          final bool connIsRight =
              type1.name.contains('right') || type2.name.contains('right');

          if (leftSideLocked! && connIsRight && !connIsLeft) return;
          if (!leftSideLocked! && connIsLeft && !connIsRight) return;

          if (connIsLeft && connIsRight) return;
        }

        canvas.drawLine(
          Offset(
            isFrontCamera
                ? size.width - (landmark1.x * scaleX)
                : landmark1.x * scaleX,
            landmark1.y * scaleY,
          ),
          Offset(
            isFrontCamera
                ? size.width - (landmark2.x * scaleX)
                : landmark2.x * scaleX,
            landmark2.y * scaleY,
          ),
          p,
        );
      }

      // Draw all connections with consistent visibility
      final List<List<PoseLandmarkType>> connections = [
        [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
        [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
        [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
        [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
        [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
        [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
        [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
        [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
        [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
        [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
        [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
        [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
        // Face connections for better orientation
        [PoseLandmarkType.leftEar, PoseLandmarkType.leftEye],
        [PoseLandmarkType.rightEar, PoseLandmarkType.rightEye],
        [PoseLandmarkType.leftEye, PoseLandmarkType.nose],
        [PoseLandmarkType.rightEye, PoseLandmarkType.nose],
      ];

      for (final conn in connections) {
        bool isActive = false;
        if (isLeftArmActive != null) {
          // Seules les connexions du BRAS doivent être en bleu (pas le tronc, pas le visage, pas les jambes)
          final bool isArmConnection = 
              (conn[0].name.contains('Shoulder') && conn[1].name.contains('Elbow')) ||
              (conn[0].name.contains('Elbow') && conn[1].name.contains('Shoulder')) ||
              (conn[0].name.contains('Elbow') && conn[1].name.contains('Wrist')) ||
              (conn[0].name.contains('Wrist') && conn[1].name.contains('Elbow'));
          
          if (isArmConnection) {
            final String targetSide = isLeftArmActive! ? 'left' : 'right';
            // Only highlight if BOTH ends of the segment are on the active side
            // and have high confidence
            final p1 = pose.landmarks[conn[0]];
            final p2 = pose.landmarks[conn[1]];
            if (p1 != null && p2 != null && p1.likelihood > 0.5 && p2.likelihood > 0.5) {
              if (conn[0].name.toLowerCase().startsWith(targetSide) && 
                  conn[1].name.toLowerCase().startsWith(targetSide)) {
                isActive = true;
              }
            }
          }
        }

        // Priority: Always draw active limb connections to prevent flickering
        if (isActive) {
          paintLine(conn[0], conn[1], activeGlowPaint, forceDisplay: true);
          paintLine(conn[0], conn[1], activePaint, forceDisplay: true);
          continue;
        }

        // --- View Filtering Logic (for non-active segments) ---
        bool shouldDraw = true;
        if (selectedView == CameraView.profile) {
          final bool connIsLeft = conn[0].name.contains('left') || conn[1].name.contains('left');
          final bool connIsRight = conn[0].name.contains('right') || conn[1].name.contains('right');
          
          // Hide connections that cross the trunk in profile (Shoulder-Shoulder, Hip-Hip)
          if ((conn[0].name.contains('Shoulder') && conn[1].name.contains('Shoulder')) ||
              (conn[0].name.contains('Hip') && conn[1].name.contains('Hip'))) {
            shouldDraw = false;
          } else {
            // Depth filtering for trunk segments
            final p1 = pose.landmarks[conn[0]];
            final p2 = pose.landmarks[conn[1]];
            if (p1 != null && p2 != null) {
              final otherS1Type = connIsLeft ? PoseLandmarkType.rightShoulder : PoseLandmarkType.leftShoulder;
              final otherS1 = pose.landmarks[otherS1Type];
              if (otherS1 != null && p1.z > otherS1.z + 25 && p2.z > otherS1.z + 25) {
                shouldDraw = false;
              }
            }
          }
        }

        if (shouldDraw) {
          paintLine(conn[0], conn[1], paint);
        }
      }

      // 2. Draw Joints (Circles with Glow)
      pose.landmarks.forEach((type, landmark) {
        // --- Fit-to-Aspect Calculation ---
        final double scaleX =
            rotation == InputImageRotation.rotation90deg ||
                rotation == InputImageRotation.rotation270deg
            ? size.width / imageSize.height
            : size.width / imageSize.width;
        final double scaleY =
            rotation == InputImageRotation.rotation90deg ||
                rotation == InputImageRotation.rotation270deg
            ? size.height / imageSize.width
            : size.height / imageSize.height;

        final offset = Offset(
          isFrontCamera
              ? size.width - (landmark.x * scaleX)
              : landmark.x * scaleX,
          landmark.y * scaleY,
        );

        bool isActive = false;
        final bool isArmJoint = type.name.contains('Shoulder') || type.name.contains('Elbow') || type.name.contains('Wrist');
        if (isLeftArmActive != null && isArmJoint && landmark.likelihood > 0.5) {
          final String targetSide = isLeftArmActive! ? 'left' : 'right';
          if (type.name.toLowerCase().startsWith(targetSide)) isActive = true;
        }

        // --- Joint Filtering Logic (Confidence & Profile Depth) ---
        if (landmark.likelihood < 0.35) return;
        
        bool shouldDrawJoint = true;
        if (selectedView == CameraView.profile) {
          // In profile, we prioritize the "locked" side
          // If not locked, we hide joints that are too far in the background (Z)
          final bool isLeftJoint = type.name.contains('left');
          final bool isRightJoint = type.name.contains('right');

          if (leftSideLocked != null) {
            if (leftSideLocked! && isRightJoint) shouldDrawJoint = false;
            if (!leftSideLocked! && isLeftJoint) shouldDrawJoint = false;
          } else {
            // Dynamic depth filtering: hide joints that are too far in the background (Z)
            // This prevents the "double line" effect before a side is locked.
            final PoseLandmarkType otherType;
            if (isLeftJoint) {
               otherType = PoseLandmarkType.rightShoulder; // Approximation for trunk
            } else if (isRightJoint) {
               otherType = PoseLandmarkType.leftShoulder;
            } else {
               otherType = type;
            }
            
            final otherLandmark = pose.landmarks[otherType];
            if (otherLandmark != null && landmark.z > otherLandmark.z + 15) {
              shouldDrawJoint = false;
            }
          }
        }

        if (!shouldDrawJoint) return;

        // Core Point (Sharp & Vibrant Green like clinical reference)
        canvas.drawCircle(
          offset,
          isActive ? 8.0 : 5.0,
          Paint()
            ..color = neonJointColor
            ..style = PaintingStyle.fill,
        );

        // Pivot Indicator for Rotation
        if (isActive && type.name.contains('Elbow')) {
          canvas.drawCircle(
            offset,
            12.0,
            Paint()
              ..color = Colors.white.withOpacity(0.5)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5,
          );
        }

        // Active Indicator (Blue ring for active joints)
        if (isActive) {
          canvas.drawCircle(
            offset,
            8.0,
            Paint()
              ..color = activeJointColor
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0,
          );
        }

        // 3. Angle Label & Reference Axis
        bool showAtThisJoint = false;
        if (exerciseId.contains('rotation')) {
          showAtThisJoint = (type == PoseLandmarkType.leftElbow || type == PoseLandmarkType.rightElbow);
        } else {
          showAtThisJoint = (type == PoseLandmarkType.leftShoulder || type == PoseLandmarkType.rightShoulder);
        }

        if (isActive && showAtThisJoint) {
          _drawAngleLabel(canvas, offset, currentAngle);
          _drawReferenceAxis(canvas, offset, size);
        }
      });
    }
  }

  void _drawReferenceAxis(Canvas canvas, Offset shoulderPos, Size size) {
    final refPaint = Paint()
      ..color = const Color(0xFF0D54F2).withOpacity(0.8) // High visibility blue
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Draw vertical reference line (0 degree axis) - LONGER for better visibility
    canvas.drawLine(
      shoulderPos,
      Offset(shoulderPos.dx, shoulderPos.dy + 300),
      refPaint,
    );
    
    // Draw a small horizontal cross-line at the shoulder to form a "Goniometer" look
    // This might be the "horizontal line" the user mentioned, now it's part of a clear design
    canvas.drawLine(
      Offset(shoulderPos.dx - 20, shoulderPos.dy),
      Offset(shoulderPos.dx + 20, shoulderPos.dy),
      refPaint,
    );

    // Add a professional clinical label
    final textPainter = TextPainter(
      text: TextSpan(
        text: "AXE REF 0°",
        style: TextStyle(
          color: const Color(0xFF0D54F2).withOpacity(0.9),
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(shoulderPos.dx - 25, shoulderPos.dy + 305));
  }

  void _drawGuidanceZones(Canvas canvas, Size size) {
    final double zoneHeight = size.height / 3;
    final paintLine = Paint()
      ..color = Colors.white.withAlpha(51)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final String viewSuffix = selectedView == CameraView.profile
        ? " (PROFIL)"
        : selectedView == CameraView.back
        ? " (DOS)"
        : " (FACE)";
    final List<String> labels = [
      "ZONE SUPÉRIEURE$viewSuffix",
      "ZONE MÉDIANE$viewSuffix",
      "ZONE INFÉRIEURE$viewSuffix",
    ];

    for (int i = 0; i < 3; i++) {
      final double top = i * zoneHeight;

      // Ligne séparatrice
      if (i > 0) {
        canvas.drawLine(Offset(0, top), Offset(size.width, top), paintLine);
      }

      // Étiquette de zone
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: Colors.white.withAlpha(77),
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(20, top + 10));
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
