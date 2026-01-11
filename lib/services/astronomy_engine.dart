import 'dart:math';

import '../models/star.dart';
import '../models/sky_state.dart';

/// AstronomyEngine
/// ----------------
/// Performs core astronomical coordinate calculations.
/// Stateless and deterministic.
class AstronomyEngine {
  /// Compute Local Sidereal Time (LST) in radians
  ///
  /// Formula (simplified, sufficient for planetarium use):
  /// LST = GMST + longitude
  double computeLST({
    required DateTime time,
    required double longitude, // degrees
  }) {
    // Convert time to Julian centuries
    final double jd = _julianDate(time);
    final double t = (jd - 2451545.0) / 36525.0;

    // Greenwich Mean Sidereal Time (degrees)
    double gmst = 280.46061837 +
        360.98564736629 * (jd - 2451545.0) +
        0.000387933 * t * t -
        t * t * t / 38710000.0;

    gmst = gmst % 360.0;
    if (gmst < 0) gmst += 360.0;

    // Local Sidereal Time
    final double lstDeg = gmst + longitude;

    return _degToRad(lstDeg % 360.0);
  }

  /// Convert RA/Dec to Altitude/Azimuth (radians)
  AltAz raDecToAltAz({
    required Star star,
    required double lst, // radians
    required double latitude, // degrees
  }) {
    final double ra = _degToRad(star.ra);
    final double dec = _degToRad(star.dec);
    final double lat = _degToRad(latitude);

    final double ha = lst - ra; // hour angle

    final double sinAlt =
        sin(dec) * sin(lat) + cos(dec) * cos(lat) * cos(ha);

    final double alt = asin(sinAlt);

    final double cosAz =
        (sin(dec) - sin(alt) * sin(lat)) /
            (cos(alt) * cos(lat));

    double az = acos(cosAz);

    if (sin(ha) > 0) {
      az = 2 * pi - az;
    }

    return AltAz(
      altitude: alt,
      azimuth: az,
    );
  }

  /// Horizon check
  bool isAboveHorizon(double altitude) {
    return altitude > 0;
  }

  // -------------------------
  // Helpers
  // -------------------------

  double _degToRad(double deg) => deg * pi / 180.0;

  double _julianDate(DateTime time) {
    final int y = time.year;
    final int m = time.month;
    final double d =
        time.day +
            (time.hour +
                time.minute / 60 +
                time.second / 3600) /
                24;

    int yy = y;
    int mm = m;

    if (mm <= 2) {
      yy -= 1;
      mm += 12;
    }

    final int a = yy ~/ 100;
    final int b = 2 - a + (a ~/ 4);

    return (365.25 * (yy + 4716)).floorToDouble() +
        (30.6001 * (mm + 1)).floorToDouble() +
        d +
        b -
        1524.5;
  }
}

/// Altitude / Azimuth pair (radians)
class AltAz {
  final double altitude;
  final double azimuth;

  const AltAz({
    required this.altitude,
    required this.azimuth,
  });
}
