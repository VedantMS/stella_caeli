import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/sky_state.dart';
import '../models/star.dart';

import '../services/astronomy_engine.dart';
import '../services/orientation_service.dart';
import '../services/projection_service.dart';
import '../services/star_catalog_service.dart';
import '../services/constellation_repository.dart';
import '../services/location_service.dart';

/// SkyController
/// -------------
/// Orchestrates sky simulation updates.
///
/// Responsibilities:
/// - React to time, location, and orientation changes
/// - Invoke astronomy and data services
/// - Mutate SkyState in a controlled manner
///
/// Non-responsibilities:
/// - No UI logic
/// - No math implementation
/// - No sensor access
class SkyController {
  final SkyState _skyState;
  final AstronomyEngine _astronomyEngine;
  final OrientationService _orientationService;
  final ProjectionService _projectionService;
  final StarCatalogService _starCatalogService;
  final ConstellationRepository _constellationRepository;
  final LocationService _locationService;

  SkyController({
    required SkyState skyState,
    required AstronomyEngine astronomyEngine,
    required OrientationService orientationService,
    required ProjectionService projectionService,
    required StarCatalogService starCatalogService,
    required ConstellationRepository constellationRepository,
    required LocationService locationService,
  })  : _skyState = skyState,
        _astronomyEngine = astronomyEngine,
        _orientationService = orientationService,
        _projectionService = projectionService,
        _starCatalogService = starCatalogService,
        _constellationRepository = constellationRepository,
        _locationService = locationService;

  // --------------------------------------------------
  // Lifecycle
  // --------------------------------------------------

  Future<void> loadSky() async {
    final allStars = await _starCatalogService.loadCatalog();
    _recalculateVisibleStars(allStars);
  }

  // --------------------------------------------------
  // Input updates
  // --------------------------------------------------

  void updateTime(DateTime newTime) {
    _skyState.updateTime(newTime);
    _recalculateVisibleStars();
  }

  void updateLocation(GeoLocation newLocation) {
    _skyState.updateLocation(newLocation);
    _recalculateVisibleStars();
  }

  // --------------------------------------------------
  // Astronomy pipeline
  // --------------------------------------------------

  void _recalculateVisibleStars([List<Star>? stars]) {
    final sourceStars = stars ?? _starCatalogService.getStars();

    final Map<Star, AltAz> visiblePositions = {};

    final lst = _astronomyEngine.computeLST(
      time: _skyState.time,
      longitude: _skyState.location.longitude,
    );

    for (final star in sourceStars) {
      final altAz = _astronomyEngine.raDecToAltAz(
        star: star,
        lst: lst,
        latitude: _skyState.location.latitude,
      );

      if (_astronomyEngine.isAboveHorizon(altAz.altitude)) {
        visiblePositions[star] = altAz;
      }
    }

    _skyState.setVisibleStarPositions(visiblePositions);
  }

  // --------------------------------------------------
  // Orientation updates
  // --------------------------------------------------

  StreamSubscription? _orientationSubscription;

  void startOrientationTracking() {
    _orientationService.start();

    _orientationSubscription =
        _orientationService.orientationStream.listen((orientation) {
          _skyState.updateOrientation(orientation);
        });
  }

  void stopOrientationTracking() {
    _orientationSubscription?.cancel();
    _orientationSubscription = null;
  }

  // --------------------------------------------------
  // Location updates
  // --------------------------------------------------

  StreamSubscription<GeoLocation>? _locationSubscription;

  void startLocationTracking() {
    _locationSubscription =
        _locationService.locationStream.listen((location) {
          _skyState.updateLocation(location);
          _recalculateVisibleStars();
        });
  }

  void stopLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  // --------------------------------------------------
  // Hit-testing (CAMERA-CORRECT)
  // --------------------------------------------------

  static const double _hFov = pi / 3; // 60°
  static const double _vFov = pi / 4; // 45°

  Star? handleTap({
    required Offset tapPosition,
    required Size canvasSize,
  }) {
    final Offset center =
    Offset(canvasSize.width / 2, canvasSize.height / 2);
    final double scale = canvasSize.shortestSide * 0.45;

    Star? nearestStar;
    double minDistance = double.infinity;

    for (final entry in _skyState.visibleStarAltAz.entries) {
      final Star star = entry.key;
      final AltAz altAz = entry.value;

      // View-relative coordinates (MUST match renderer)
      final double relAz =
      _wrapAngle(altAz.azimuth - _skyState.orientation.azimuth);
      final double relAlt =
          altAz.altitude - _skyState.orientation.altitude;

      // FOV culling
      if (relAz.abs() > _hFov / 2 ||
          relAlt.abs() > _vFov / 2) {
        continue;
      }

      final projected = _projectionService.worldToScreen(
        AltAz(altitude: relAlt, azimuth: relAz),
      );

      if (projected == null) continue;

      final Offset starPos = Offset(
        center.dx + projected.x * scale,
        center.dy - projected.y * scale,
      );

      final double distance = (starPos - tapPosition).distance;

      if (distance < 20 && distance < minDistance) {
        minDistance = distance;
        nearestStar = star;
      }
    }

    return nearestStar;
  }

  String? handleConstellationTap({
    required Offset tapPosition,
    required Size canvasSize,
  }) {
    final Offset center =
    Offset(canvasSize.width / 2, canvasSize.height / 2);
    final double scale = canvasSize.shortestSide * 0.45;

    final Map<String, Offset> projectedById = {};

    for (final entry in _skyState.visibleStarAltAz.entries) {
      final Star star = entry.key;
      final AltAz altAz = entry.value;

      final double relAz =
      _wrapAngle(altAz.azimuth - _skyState.orientation.azimuth);
      final double relAlt =
          altAz.altitude - _skyState.orientation.altitude;

      if (relAz.abs() > _hFov / 2 ||
          relAlt.abs() > _vFov / 2) {
        continue;
      }

      final projected = _projectionService.worldToScreen(
        AltAz(altitude: relAlt, azimuth: relAz),
      );

      if (projected == null) continue;

      projectedById[star.id] = Offset(
        center.dx + projected.x * scale,
        center.dy - projected.y * scale,
      );
    }

    for (final constellationId
    in _constellationRepository.constellationIds) {
      final lines =
      _constellationRepository.getLinesForConstellation(
          constellationId);

      for (final line in lines) {
        final start = projectedById[line.startStarId];
        final end = projectedById[line.endStarId];

        if (start == null || end == null) continue;

        final double distance =
        _distancePointToSegment(tapPosition, start, end);

        if (distance < 12.0) {
          return constellationId;
        }
      }
    }

    return null;
  }

  // --------------------------------------------------
  // Helpers
  // --------------------------------------------------

  double _wrapAngle(double a) {
    while (a > pi) a -= 2 * pi;
    while (a < -pi) a += 2 * pi;
    return a;
  }

  double _distancePointToSegment(
      Offset p,
      Offset a,
      Offset b,
      ) {
    final ap = p - a;
    final ab = b - a;

    final double t =
        (ap.dx * ab.dx + ap.dy * ab.dy) /
            (ab.dx * ab.dx + ab.dy * ab.dy);

    final double clampedT = t.clamp(0.0, 1.0);

    final closest = Offset(
      a.dx + ab.dx * clampedT,
      a.dy + ab.dy * clampedT,
    );

    return (p - closest).distance;
  }

  // --------------------------------------------------
  // CAMERA-RELATIVE constellation azimuth
  // --------------------------------------------------

  double? getTargetConstellationAzimuth() {
    final String? id = _skyState.targetConstellationId;
    if (id == null) return null;

    final lines =
    _constellationRepository.getLinesForConstellation(id);

    if (lines.isEmpty) return null;

    String normalize(String s) =>
        s.replaceAll(RegExp(r'[^0-9]'), '');

    final List<double> azimuths = [];

    for (final line in lines) {
      for (final starId in [line.startStarId, line.endStarId]) {
        final String normLineId = normalize(starId);

        for (final entry in _skyState.visibleStarAltAz.entries) {
          final Star star = entry.key;
          final AltAz altAz = entry.value;

          if (normalize(star.id) == normLineId) {
            azimuths.add(altAz.azimuth);
            break;
          }
        }
      }
    }

    if (azimuths.isEmpty) return null;

    // Circular mean (correct for angles)
    final double x =
    azimuths.map(cos).reduce((a, b) => a + b);
    final double y =
    azimuths.map(sin).reduce((a, b) => a + b);

    return atan2(y, x);
  }

  // --------------------------------------------------
  // Selection
  // --------------------------------------------------

  void selectConstellation(String constellationId) {
    _skyState.setTargetConstellation(constellationId);
  }
}
