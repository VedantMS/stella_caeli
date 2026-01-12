import 'dart:math';
import 'package:flutter/material.dart';
import 'package:stella_caeli/screens/time_location_screen.dart';

import '../controllers/settings_controller.dart';
import '../core/service_locator.dart';
import '../controllers/sky_controller.dart';
import '../models/sky_state.dart';
import '../models/star.dart';
import '../services/orientation_service.dart';
import '../widgets/sky_canvas.dart';
import 'constellation_info_screen.dart';

class SkyViewScreen extends StatefulWidget {
  const SkyViewScreen({super.key});

  @override
  State<SkyViewScreen> createState() => _SkyViewScreenState();
}

class _SkyViewScreenState extends State<SkyViewScreen> {
  late final SkyController _skyController;
  late final SkyState _skyState;
  late final OrientationService _orientationService;
  late final SettingsController _settingsController;

  @override
  void initState() {
    super.initState();
    final locator = ServiceLocator();

    _skyController = locator.skyController;
    _skyState = locator.skyState;
    _orientationService = locator.orientationService;
    _settingsController = locator.settingsController;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _skyController.loadSky();
      _skyController.startOrientationTracking();
      _skyController.startLocationTracking();
    });
  }

  @override
  void dispose() {
    _skyController.stopOrientationTracking();
    _skyController.stopLocationTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locator = ServiceLocator();
    final constellationRepo = locator.constellationRepository;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _skyState,
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final Size size =
              Size(constraints.maxWidth, constraints.maxHeight);
              final Offset center =
              Offset(size.width / 2, size.height / 2);

              // --------------------------------
              // Focused star (reticle)
              // --------------------------------
              final Star? focusedStar = _skyController.handleTap(
                tapPosition: center,
                canvasSize: size,
              );

              // --------------------------------
              // Target constellation
              // --------------------------------
              final String? targetName =
              _skyState.targetConstellationId == null
                  ? null
                  : constellationRepo.getConstellationName(
                _skyState.targetConstellationId!,
              );

              final double? targetAzimuth =
              _skyController.getTargetConstellationAzimuth();

              final bool isPointingAtConstellation =
                  targetAzimuth != null &&
                      (_wrapAngle(
                        targetAzimuth -
                            _skyState.orientation.azimuth,
                      ).abs() <
                          6 * pi / 180); // ~6°

              return Stack(
                children: [
                  // -----------------------------
                  // Sky
                  // -----------------------------
                  SkyCanvas(skyState: _skyState),

                  // -----------------------------
                  // Mode overlay
                  // -----------------------------
                  Positioned(
                    top: 40,
                    left: 16,
                    child: _ModeInfoOverlay(
                      isLive: _settingsController.isLiveMode,
                      time: _skyState.time,
                      location: _skyState.location,
                    ),
                  ),

                  // -----------------------------
                  // Constellation arrow
                  // -----------------------------
                  if (targetAzimuth != null)
                    IgnorePointer(
                      child: Center(
                        child: _ConstellationIndicator(
                          cameraAzimuth:
                          _skyState.orientation.azimuth,
                          targetAzimuth: targetAzimuth,
                        ),
                      ),
                    ),

                  // -----------------------------
                  // Reticle
                  // -----------------------------
                  Center(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        final String? targetId = _skyState.targetConstellationId;

                        if (targetId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ConstellationInfoScreen(id: targetId),
                            ),
                          );
                        }
                      },
                      child: const _CenterReticle(),
                    ),
                  ),

                  // -----------------------------
                  // Label (star OR constellation)
                  // -----------------------------
                  if (focusedStar != null ||
                      (isPointingAtConstellation &&
                          targetName != null))
                    Positioned(
                      top: size.height / 2 + 42,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: _ObjectLabel(
                          text:
                          focusedStar?.id ?? targetName!,
                        ),
                      ),
                    ),

                  // -----------------------------
                  // Time & Location
                  // -----------------------------
                  Positioned(
                    bottom: 40,
                    left: 20,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor:
                      Colors.black.withOpacity(0.6),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const TimeLocationScreen(),
                          ),
                        );
                      },
                      child: const Icon(Icons.access_time,
                          color: Colors.white, size: 20),
                    ),
                  ),

                  // -----------------------------
                  // Constellation picker
                  // -----------------------------
                  Positioned(
                    bottom: 40,
                    right: 20,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor:
                      Colors.black.withOpacity(0.6),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.black,
                          builder: (_) =>
                          const _ConstellationPicker(),
                        );
                      },
                      child: const Icon(Icons.auto_awesome,
                          color: Colors.cyanAccent, size: 20),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  double _wrapAngle(double a) {
    while (a > pi) {
      a -= 2 * pi;
    }
    while (a < -pi) {
      a += 2 * pi;
    }
    return a;
  }
}

/// ------------------------------
/// Constellation picker
/// ------------------------------
class _ConstellationPicker extends StatelessWidget {
  const _ConstellationPicker();

  @override
  Widget build(BuildContext context) {
    final locator = ServiceLocator();
    final repo = locator.constellationRepository;
    final skyState = locator.skyState;

    return SafeArea(
      child: ListView(
        children: repo.constellationIds.map((id) {
          final name = repo.getConstellationName(id);
          final selected = skyState.targetConstellationId == id;

          return ListTile(
            title: Text(
              name,
              style: TextStyle(
                color: selected ? Colors.cyanAccent : Colors.white,
              ),
            ),
            trailing:
            selected ? const Icon(Icons.check, color: Colors.cyanAccent) : null,
            onTap: () {
              skyState.setTargetConstellation(id);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}

/// ------------------------------
/// Constellation arrow
/// ------------------------------
class _ConstellationIndicator extends StatelessWidget {
  final double cameraAzimuth;
  final double targetAzimuth;

  const _ConstellationIndicator({
    required this.cameraAzimuth,
    required this.targetAzimuth,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(80, 80),
      painter: _ConstellationPainter(
        cameraAzimuth: cameraAzimuth,
        targetAzimuth: targetAzimuth,
      ),
    );
  }
}

class _ConstellationPainter extends CustomPainter {
  final double cameraAzimuth;
  final double targetAzimuth;

  _ConstellationPainter({
    required this.cameraAzimuth,
    required this.targetAzimuth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    const radius = 34;

    double angle = targetAzimuth - cameraAzimuth;
    angle = (angle + pi) % (2 * pi) - pi;

    final tip = Offset(
      center.dx + radius * sin(angle),
      center.dy - radius * cos(angle),
    );

    final paint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    canvas.drawLine(center, tip, paint);
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter old) =>
      old.cameraAzimuth != cameraAzimuth ||
          old.targetAzimuth != targetAzimuth;
}

/// ------------------------------
/// Reticle
/// ------------------------------
class _CenterReticle extends StatelessWidget {
  const _CenterReticle();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(56, 56),
      painter: _ReticlePainter(),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.65)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(c, size.width / 2, paint);
    canvas.drawLine(Offset(c.dx - 8, c.dy), Offset(c.dx + 8, c.dy), paint);
    canvas.drawLine(Offset(c.dx, c.dy - 8), Offset(c.dx, c.dy + 8), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

/// ------------------------------
/// LIVE / MANUAL overlay
/// ------------------------------
class _ModeInfoOverlay extends StatelessWidget {
  final bool isLive;
  final DateTime time;
  final GeoLocation location;

  const _ModeInfoOverlay({
    required this.isLive,
    required this.time,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isLive ? Colors.greenAccent : Colors.orangeAccent;
    final local = time.toLocal();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isLive ? 'LIVE' : 'MANUAL',
              style: TextStyle(color: accent, fontSize: 12)),
          Text(
            '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} '
                '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          Text(
            'Lat ${location.latitude.toStringAsFixed(2)}, Lon ${location.longitude.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------
/// Object label
/// ------------------------------
class _ObjectLabel extends StatelessWidget {
  final String text;

  const _ObjectLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text,
          style: const TextStyle(color: Colors.white, fontSize: 14)),
    );
  }
}
