import 'dart:async';

/// TimeService
/// -----------
/// Provides simulation time.
///
/// - Live mode: emits current UTC time every second
/// - Manual mode: controller sets time directly
class TimeService {
  double _speed = 1.0;
  double get currentSpeed => _speed;

  void setSpeed(double speed) {
    _speed = speed;
  }

  Stream<DateTime> get timeStream =>
      Stream.periodic(
        const Duration(seconds: 1),
            (_) => DateTime.now().toUtc().add(
          Duration(
            milliseconds: (1000 * _speed).round(),
          ),
        ),
      );

  int _elapsedMs = 0;
}
