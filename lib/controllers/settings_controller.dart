import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stella_caeli/controllers/sky_controller.dart';

import '../models/sky_state.dart';
import '../services/time_service.dart';
import '../services/location_service.dart';

class SettingsController {
  static const _keyMode = 'mode';
  static const _keyCountry = 'country';
  static const _keyManualTime = 'manual_time';
  static const _keyTimeSpeed = 'time_speed';

  final SkyState _skyState;
  final TimeService _timeService;
  final LocationService _locationService;
  final SkyController _skyController;

  StreamSubscription<DateTime>? _timeSub;
  StreamSubscription<GeoLocation>? _locationSub;

  bool _isLiveMode = true;
  String? _currentCountry;

  SettingsController({
    required SkyState skyState,
    required TimeService timeService,
    required LocationService locationService,
    required SkyController skyController,
  })  : _skyState = skyState,
        _timeService = timeService,
        _locationService = locationService,
        _skyController = skyController;

  // -----------------------------
  // PUBLIC GETTERS (NEW)
  // -----------------------------

  bool get isLiveMode => _isLiveMode;
  String get currentCountry => _currentCountry ?? 'Unknown';

  // -----------------------------
  // LIVE MODE
  // -----------------------------

  void enableLiveTime() {
    _timeSub?.cancel();
    _timeSub = _timeService.timeStream.listen(_skyState.updateTime);
  }

  void disableLiveTime() {
    _timeSub?.cancel();
    _timeSub = null;
  }

  void enableGps() {
    _locationSub?.cancel();
    _locationSub =
        _locationService.locationStream.listen(_skyState.updateLocation);
  }

  void disableGps() {
    _locationSub?.cancel();
    _locationSub = null;
  }

  void useLiveTimeAndLocation() {
    _isLiveMode = true;
    enableLiveTime();
    enableGps();
    _saveLiveMode();
  }

  // -----------------------------
  // MANUAL MODE
  // -----------------------------

  void setManualTime(DateTime time) {
    _timeSub?.cancel();
    _skyController.updateTime(time.toUtc());
  }

  void setManualLocation(GeoLocation location, String country) {
    _locationSub?.cancel();
    _currentCountry = country;
    _skyController.updateLocation(location);
  }

  void useManualTimeAndLocation({
    required DateTime time,
    required GeoLocation location,
    required String country,
  }) {
    _isLiveMode = false;

    setManualTime(time);
    setManualLocation(location, country);

    _saveManualMode(
      country: country,
      time: time,
      timeSpeed: _timeService.currentSpeed,
    );
  }

  // -----------------------------
  // PERSISTENCE
  // -----------------------------

  Future<void> _saveLiveMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMode, 'live');
  }

  Future<void> _saveManualMode({
    required String country,
    required DateTime time,
    required double timeSpeed,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMode, 'manual');
    await prefs.setString(_keyCountry, country);
    await prefs.setString(_keyManualTime, time.toUtc().toIso8601String());
    await prefs.setDouble(_keyTimeSpeed, timeSpeed);
  }

  Future<void> restoreLastSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_keyMode) ?? 'live';

    if (mode == 'live') {
      useLiveTimeAndLocation();
      return;
    }

    final country = prefs.getString(_keyCountry) ?? 'India';
    final timeStr = prefs.getString(_keyManualTime);

    if (timeStr == null) {
      useLiveTimeAndLocation();
      return;
    }

    final time = DateTime.parse(timeStr);
    final location = _locationService.getCountryLocation(country);

    useManualTimeAndLocation(
      time: time,
      location: location,
      country: country,
    );
  }
}
