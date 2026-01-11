import 'package:flutter/foundation.dart';

import 'star.dart';
import '../services/astronomy_engine.dart'; // AltAz only

class SkyState extends ChangeNotifier {
  DateTime _time;
  GeoLocation _location;
  OrientationData _orientation;

  List<Star> _starsVisible;
  Map<Star, AltAz> _visibleStarAltAz = {};

  String? _targetConstellationId;

  SkyState({
    required DateTime time,
    required GeoLocation location,
    required OrientationData orientation,
    List<Star>? starsVisible,
  })  : _time = time,
        _location = location,
        _orientation = orientation,
        _starsVisible = starsVisible ?? [];

  DateTime get time => _time;
  GeoLocation get location => _location;
  OrientationData get orientation => _orientation;

  List<Star> get starsVisible => List.unmodifiable(_starsVisible);
  Map<Star, AltAz> get visibleStarAltAz =>
      Map.unmodifiable(_visibleStarAltAz);

  String? get targetConstellationId => _targetConstellationId;

  void updateTime(DateTime newTime) {
    if (_time == newTime) return;
    _time = newTime;
    notifyListeners();
  }

  void updateLocation(GeoLocation newLocation) {
    if (_location == newLocation) return;
    _location = newLocation;
    notifyListeners();
  }

  void updateOrientation(OrientationData newOrientation) {
    _orientation = newOrientation;
    notifyListeners();
  }

  void setVisibleStars(List<Star> stars) {
    _starsVisible = stars;
    notifyListeners();
  }

  void setVisibleStarPositions(Map<Star, AltAz> positions) {
    _visibleStarAltAz = positions;
    notifyListeners();
  }

  void setTargetConstellation(String? id) {
    if (_targetConstellationId == id) return;
    _targetConstellationId = id;
    notifyListeners();
  }
}

class GeoLocation {
  final double latitude;
  final double longitude;

  const GeoLocation({
    required this.latitude,
    required this.longitude,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is GeoLocation &&
              latitude == other.latitude &&
              longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}

class OrientationData {
  final double azimuth;      // camera yaw
  final double altitude;     // camera pitch
  final double northAzimuth; // absolute magnetic north

  const OrientationData({
    required this.azimuth,
    required this.altitude,
    required this.northAzimuth,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is OrientationData &&
              azimuth == other.azimuth &&
              altitude == other.altitude &&
              northAzimuth == other.northAzimuth;

  @override
  int get hashCode =>
      azimuth.hashCode ^ altitude.hashCode ^ northAzimuth.hashCode;
}
