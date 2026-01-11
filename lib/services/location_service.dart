import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../models/sky_state.dart';

/// LocationService
/// ----------------
/// Provides observer location for the sky simulation.
///
/// Supports:
/// - Live GPS-based location
/// - Manual location (country-based)
///
/// UI and permission handling are OUTSIDE this service.
class LocationService {
  LocationMode _mode = LocationMode.live;

  GeoLocation? _manualLocation;
  StreamSubscription<Position>? _gpsSub;

  final StreamController<GeoLocation> _locationController =
  StreamController.broadcast();

  Stream<GeoLocation> get locationStream =>
      _locationController.stream;

  LocationMode get mode => _mode;

  String? currentCountry;

  // -------------------------
  // Mode control
  // -------------------------

  /// Switch to live GPS location.
  Future<void> useLiveLocation() async {
    _mode = LocationMode.live;
    _manualLocation = null;

    await _ensurePermission();

    _gpsSub?.cancel();
    _gpsSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) {
      if (_mode != LocationMode.live) return;

      _locationController.add(
        GeoLocation(
          latitude: pos.latitude,
          longitude: pos.longitude,
        ),
      );
    });
  }

  /// Switch to manual location mode.
  void useManualLocation(GeoLocation location) {
    _mode = LocationMode.manual;

    _gpsSub?.cancel();
    _gpsSub = null;

    _manualLocation = location;
    _locationController.add(location);
  }

  /// Set manual location by country name.
  GeoLocation setLocationByCountry(String country) {
    final GeoLocation? loc = _countryLocationMap[country];

    if (loc == null) {
      throw ArgumentError('Unsupported country: $country');
    }

    currentCountry = country;
    useManualLocation(loc);
    return loc;
  }

  // -------------------------
  // INITIAL EMISSION (CRITICAL)
  // -------------------------

  /// Emits a guaranteed initial location so the app never stalls.
  void emitInitialLocation() {
    if (_mode == LocationMode.manual && _manualLocation != null) {
      _locationController.add(_manualLocation!);
    } else {
      // Fallback default (India)
      _locationController.add(
        const GeoLocation(latitude: 20.5937, longitude: 78.9629),
      );
    }
  }

  // -------------------------
  // Permissions
  // -------------------------

  Future<void> _ensurePermission() async {
    final bool serviceEnabled =
    await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied.',
      );
    }
  }

  void dispose() {
    _gpsSub?.cancel();
    _locationController.close();
  }

  GeoLocation getCountryLocation(String country) {
    final GeoLocation? loc = _countryLocationMap[country];

    if (loc == null) {
      throw ArgumentError('Unsupported country: $country');
    }

    return loc;
  }

}

/// Location mode
enum LocationMode {
  live,
  manual,
}

/// Approximate country centers
final Map<String, GeoLocation> _countryLocationMap = {
  'India': GeoLocation(latitude: 20.5937, longitude: 78.9629),
  'USA': GeoLocation(latitude: 39.8283, longitude: -98.5795),
  'UK': GeoLocation(latitude: 55.3781, longitude: -3.4360),
  'Australia': GeoLocation(latitude: -25.2744, longitude: 133.7751),
  'Japan': GeoLocation(latitude: 36.2048, longitude: 138.2529),
};
