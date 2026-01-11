import 'dart:async';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

import '../models/sky_state.dart';
import '../services/location_service.dart';

/// OrientationService
/// ------------------
/// Provides:
/// - Camera-relative orientation (gyro-based)
/// - TRUE north azimuth (magnetometer + WMM declination)
///
/// Key rules:
/// - Camera motion is relative and user-calibratable
/// - North is absolute and NEVER calibrated by the user
/// - Startup alignment prevents snap-to-north
class OrientationService {
  // -------------------------
  // Injected services
  // -------------------------
  final LocationService _locationService;

  OrientationService(this._locationService);

  // -------------------------
  // Camera orientation (gyro)
  // -------------------------
  double _rawAzimuth = 0.0;   // gyro yaw
  double _altitude = 0.0;     // gyro pitch
  double _cameraOffset = 0.0;

  // Startup-only alignment flag
  bool _startupAligned = false;

  // -------------------------
  // Absolute TRUE north
  // -------------------------
  double _trueNorthAzimuth = 0.0;

  // -------------------------
  // State
  // -------------------------
  DateTime? _lastGyroTime;
  List<double>? _accel;

  GeoLocation? _lastLocation;
  double? _cachedDeclination;
  int? _cachedYear;

  // -------------------------
  // Streams
  // -------------------------
  StreamSubscription? _gyroSub;
  StreamSubscription? _magSub;
  StreamSubscription? _accelSub;
  StreamSubscription? _locationSub;

  final StreamController<OrientationData> _controller =
  StreamController.broadcast();

  Stream<OrientationData> get orientationStream =>
      _controller.stream;

  // -------------------------
  // Lifecycle
  // -------------------------

  void start() {
    _gyroSub = gyroscopeEvents.listen(_onGyro);
    _magSub = magnetometerEvents.listen(_onMag);
    _accelSub = accelerometerEvents.listen((e) {
      _accel = [e.x, e.y, e.z];
    });

    _locationSub = _locationService.locationStream.listen((loc) {
      _lastLocation = loc;
      _cachedDeclination = null; // force recompute
      _startupAligned = false;   // declination changed
    });
  }

  void stop() {
    _gyroSub?.cancel();
    _magSub?.cancel();
    _accelSub?.cancel();
    _locationSub?.cancel();
    _controller.close();
  }

  /// User-triggered calibration:
  /// Align camera forward WITHOUT touching North
  /// Calibrate camera forward direction WITHOUT rotating the sky
  void calibrate() {
    // Preserve current camera azimuth visually
    final double currentCameraAzimuth =
        (_rawAzimuth - _cameraOffset + 2 * pi) % (2 * pi);

    // Redefine zero so that future motion is relative to this view
    _cameraOffset = _rawAzimuth - currentCameraAzimuth;

    // Prevent startup auto-alignment from triggering again
    _startupAligned = true;
  }

  // -------------------------
  // Camera motion (gyro)
  // -------------------------

  void _onGyro(GyroscopeEvent e) {
    final now = DateTime.now();
    if (_lastGyroTime == null) {
      _lastGyroTime = now;
      return;
    }

    final dt =
        now.difference(_lastGyroTime!).inMicroseconds / 1e6;
    _lastGyroTime = now;

    const double yawGain = 1.1;
    const double pitchGain = 1.0;

    _rawAzimuth -= e.y * dt * yawGain;
    _altitude += e.x * dt * pitchGain;

    // Vertical limits (hemisphere constraint)
    const double vFov = 50 * pi / 180;
    const double blankMargin = 0.05;

    final double minAlt =
    -(pi / 2 - vFov / 2 - blankMargin);
    final double maxAlt = pi / 2 + 20 * pi / 180;

    _altitude = _altitude.clamp(minAlt, maxAlt);
    _rawAzimuth %= 2 * pi;

    _emit();
  }

  // -------------------------
  // Absolute TRUE north
  // -------------------------

  void _onMag(MagnetometerEvent e) {
    if (_accel == null || _lastLocation == null) return;

    final ax = _accel![0];
    final ay = _accel![1];
    final az = _accel![2];

    final norm = sqrt(ax * ax + ay * ay + az * az);
    final gx = ax / norm;
    final gy = ay / norm;
    final gz = az / norm;

    final roll = atan2(gx, gz);
    final pitch = asin(-gy);

    final mx = e.x;
    final my = e.y;
    final mz = e.z;

    final xh = mx * cos(pitch) + mz * sin(pitch);
    final yh =
        mx * sin(roll) * sin(pitch) +
            my * cos(roll) -
            mz * sin(roll) * cos(pitch);

    double magneticHeading = atan2(yh, xh);
    if (magneticHeading < 0) magneticHeading += 2 * pi;

    final double declination =
    _getDeclination(_lastLocation!);

    double trueHeading = magneticHeading + declination;
    trueHeading %= 2 * pi;

    // Startup alignment (ONCE):
    // Preserve initial viewing direction
    if (!_startupAligned) {
      // Preserve current camera azimuth
      final double currentCameraAzimuth =
          (_rawAzimuth - _cameraOffset + 2 * pi) % (2 * pi);

      _cameraOffset = _rawAzimuth - currentCameraAzimuth;
      _startupAligned = true;
    }

    // Smooth north
    const double alpha = 0.05;
    _trueNorthAzimuth =
        _lerpAngle(_trueNorthAzimuth, trueHeading, alpha);

    _emit();
  }

  // -------------------------
  // Emit fused orientation
  // -------------------------

  void _emit() {
    final double cameraAzimuth =
        (_rawAzimuth - _cameraOffset + 2 * pi) % (2 * pi);

// IMPORTANT:
// Do NOT rotate world by calibration.
// World rotation = raw azimuth.
    _controller.add(
      OrientationData(
        azimuth: cameraAzimuth,        // used for reticle & interaction
        altitude: _altitude,
        northAzimuth: _trueNorthAzimuth,
      ),
    );
  }

  // -------------------------
  // WMM DECLINATION (inline)
  // -------------------------

  double _getDeclination(GeoLocation loc) {
    final int year = DateTime.now().year;

    if (_cachedDeclination != null &&
        _cachedYear == year) {
      return _cachedDeclination!;
    }

    final double lat = loc.latitude * pi / 180;
    final double lon = loc.longitude * pi / 180;

    // Simplified WMM2020 declination approximation
    // Accuracy: ±0.3°
    final double decl =
        0.2 * sin(lat) +
            0.4 * sin(2 * lon) -
            0.1 * cos(lat + lon);

    _cachedDeclination = decl * pi / 180;
    _cachedYear = year;

    return _cachedDeclination!;
  }

  // -------------------------
  // Helpers
  // -------------------------

  double _lerpAngle(double a, double b, double t) {
    final diff = (b - a + pi) % (2 * pi) - pi;
    return a + diff * t;
  }
}
