import 'dart:math';

import '../services/astronomy_engine.dart';

/// ProjectionService
/// -----------------
/// Performs camera-style perspective projection.
///
/// Contract:
/// - Input AltAz MUST be view-relative (orientation already subtracted)
/// - Output is normalized screen coordinates
/// - No UI knowledge
/// - No FOV logic (handled by caller)
class ProjectionService {
  /// Perspective projection assuming camera looks along +Z axis.
  ///
  /// Returns null if point is behind the camera.
  ProjectedPoint? worldToScreen(AltAz altAz) {
    final double alt = altAz.altitude;
    final double az = altAz.azimuth;

    // Convert spherical (Alt/Az) → Cartesian (unit sphere)
    final double x = cos(alt) * sin(az);
    final double y = sin(alt);
    final double z = cos(alt) * cos(az);

    // Behind camera → not visible
    if (z <= 0) return null;

    // Perspective projection
    return ProjectedPoint(
      x: x / z,
      y: y / z,
    );
  }
}

/// Normalized projected point (camera plane)
class ProjectedPoint {
  final double x;
  final double y;

  const ProjectedPoint({
    required this.x,
    required this.y,
  });
}
