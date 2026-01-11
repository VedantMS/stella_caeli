import 'dart:math';

import 'package:flutter/material.dart';

import '../core/service_locator.dart';
import '../models/sky_state.dart';
import '../models/star.dart';
import '../screens/info_screen.dart';
import '../screens/constellation_info_screen.dart';
import '../services/projection_service.dart';
import '../services/constellation_repository.dart';
import '../services/astronomy_engine.dart';

/// SkyCanvas
/// ---------
/// Renders the sky as a CAMERA VIEW into a celestial dome.
class SkyCanvas extends StatelessWidget {
  final SkyState skyState;

  const SkyCanvas({
    super.key,
    required this.skyState,
  });

  @override
  Widget build(BuildContext context) {
    final locator = ServiceLocator();
    final skyController = locator.skyController;

    final double devicePixelRatio =
        View.of(context).devicePixelRatio;

    return LayoutBuilder(
      builder: (context, constraints) {
        final Size canvasSize =
        Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          onTapDown: (details) {
            final Offset tapPosition = details.localPosition;

            final Star? star = skyController.handleTap(
              tapPosition: tapPosition,
              canvasSize: canvasSize,
            );

            if (star != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InfoScreen(star: star),
                ),
              );
              return;
            }

            final String? constellationId =
            skyController.handleConstellationTap(
              tapPosition: tapPosition,
              canvasSize: canvasSize,
            );

            if (constellationId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ConstellationInfoScreen(id: constellationId),
                ),
              );
            }
          },
          child: CustomPaint(
            painter: _SkyPainter(
              starPositions: skyState.visibleStarAltAz,
              orientation: skyState.orientation,
              projectionService: locator.projectionService,
              constellationRepository:
              locator.constellationRepository,
              devicePixelRatio: devicePixelRatio,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class _SkyPainter extends CustomPainter {
  final Map<Star, AltAz> starPositions;
  final OrientationData orientation;
  final ProjectionService projectionService;
  final ConstellationRepository constellationRepository;
  final double devicePixelRatio;

  _SkyPainter({
    required this.starPositions,
    required this.orientation,
    required this.projectionService,
    required this.constellationRepository,
    required this.devicePixelRatio,
  });

  // Camera field of view (radians)
  static const double hFov = 70 * pi / 180;
  static const double vFov = 50 * pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    // ---------------- Background ----------------
    final Rect skyRect = Offset.zero & size;

    canvas.drawRect(
      skyRect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -0.8),
          radius: 1.4,
          colors: [
            Color(0xFF0B1026),
            Color(0xFF000000),
          ],
        ).createShader(skyRect),
    );

    final double verticalBias =
        size.height * 0.18; // ~18% downward camera shift

    final Offset screenCenter = Offset(
      size.width / 2,
      size.height / 2 + verticalBias,
    );

    // ID → projected position
    final Map<String, Offset> projected = {};
    final Map<String, Star> starsById = {};

    // ---------------- Project stars ----------------
    for (final entry in starPositions.entries) {
      final Star star = entry.key;
      final AltAz altAz = entry.value;

      final double relAz = _wrapAngle(
        altAz.azimuth
            - orientation.northAzimuth
            - orientation.azimuth,
      );

      final double relAlt =
          altAz.altitude - orientation.altitude;

      const double fovMargin = 0.35; // radians ≈ 20°

      final double upperAltLimit = vFov / 2 + 1.1;
      final double lowerAltLimit = -(vFov / 2 + 0.35);

      if (relAz.abs() > hFov / 2 + fovMargin ||
          relAlt > upperAltLimit ||
          relAlt < lowerAltLimit) {
        continue;
      }

      final projectedPoint = projectionService.worldToScreen(
        AltAz(altitude: relAlt, azimuth: relAz),
      );

      final double xNdc = projectedPoint!.x / tan(hFov / 2);
      const double verticalScale = 0.72;

      final double yNdc =
          (projectedPoint.y / tan(vFov / 2)) * verticalScale;

      final Offset pos = Offset(
        screenCenter.dx + xNdc * screenCenter.dx,
        screenCenter.dy - yNdc * screenCenter.dy,
      );


      projected[star.id] = pos;
      starsById[star.id] = star;
    }

    // ---------------- Vertical framing correction ----------------
    if (projected.isNotEmpty) {
      final double maxStarY =
      projected.values.map((p) => p.dy).reduce(max);

      // 1 cm ≈ 38 px @ 160 dpi → scale by DPR
      final double maxBlankPx = devicePixelRatio * 38;

      final double blankBelow = size.height - maxStarY;

      if (blankBelow > maxBlankPx) {
        final double shiftY = blankBelow - maxBlankPx;

        projected.updateAll(
              (_, pos) => pos + Offset(0, shiftY),
        );
      }
    }

    // ---------------- Draw stars ----------------
    for (final entry in projected.entries) {
      final Star star = starsById[entry.key]!;
      _drawStar(canvas, entry.value, star);
    }

    // ---------------- Draw constellations ----------------
    final Paint linePaint = Paint()
      ..color = Colors.white.withOpacity(0.45)
      ..strokeWidth = 1.2;

    for (final String constellationId
    in constellationRepository.constellationIds) {
      final lines =
      constellationRepository.getLinesForConstellation(
          constellationId);

      for (final line in lines) {
        final Offset? a = projected[line.startStarId];
        final Offset? b = projected[line.endStarId];

        if (a != null || b != null) {
          final Offset p1 = a ?? b!;
          final Offset p2 = b ?? a!;

          canvas.drawLine(p1, p2, linePaint);
        }
      }
    }
  }

  // ---------------- Helpers ----------------

  double _wrapAngle(double a) {
    while (a > pi) a -= 2 * pi;
    while (a < -pi) a += 2 * pi;
    return a;
  }

  void _drawStar(Canvas canvas, Offset p, Star star) {
    final double size =
    (4.5 - star.magnitude).clamp(1.0, 4.0);
    final double alpha =
    (1.2 - star.magnitude * 0.15).clamp(0.3, 1.0);

    if (star.magnitude < 1.5) {
      canvas.drawCircle(
        p,
        size * 2.2,
        Paint()
          ..color = Colors.white.withOpacity(alpha * 0.4)
          ..maskFilter =
          const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    canvas.drawCircle(
      p,
      size,
      Paint()..color = Colors.white.withOpacity(alpha),
    );
  }

  @override
  bool shouldRepaint(covariant _SkyPainter old) =>
      old.starPositions != starPositions ||
          old.orientation != orientation;
}
