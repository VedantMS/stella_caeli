import 'package:flutter/material.dart';

import '../core/service_locator.dart';
import '../controllers/settings_controller.dart';
import '../models/sky_state.dart';
import '../services/location_service.dart';

/// TimeLocationScreen
/// ------------------
/// Allows user to choose:
/// - Live time & location
/// - Manual time & location (country-based)
class TimeLocationScreen extends StatefulWidget {
  const TimeLocationScreen({super.key});

  @override
  State<TimeLocationScreen> createState() =>
      _TimeLocationScreenState();
}

class _TimeLocationScreenState
    extends State<TimeLocationScreen> {
  late final SettingsController _settingsController;
  late final LocationService _locationService;

  bool _useLiveMode = true;

  String _selectedCountry = 'India';
  DateTime _selectedDateTime = DateTime.now();

  // 🔹 Restored manual-time controls
  double _timeOffsetHours = 0.0;
  double _timeSpeed = 1.0;

  final List<String> _countries = const [
    'India',
    'USA',
    'UK',
    'Australia',
    'Japan',
  ];

  @override
  void initState() {
    super.initState();
    final locator = ServiceLocator();
    _settingsController = locator.settingsController;
    _locationService = locator.locationService;
  }

  // -------------------------
  // UI helpers
  // -------------------------

  Future<void> _pickDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime:
      TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      _timeOffsetHours = 0.0; // reset offset
    });
  }

  Future<void> _applySelection() async {
    if (_useLiveMode) {
      _settingsController.useLiveTimeAndLocation();
    } else {
      final GeoLocation location =
      _locationService.getCountryLocation(_selectedCountry);

      _settingsController.useManualTimeAndLocation(
        time: _selectedDateTime,
        location: location, country: '',
      );
    }

    Navigator.pop(context);
  }

  // -------------------------
  // Build
  // -------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time & Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------------
            // Mode toggle
            // -------------------------
            SwitchListTile(
              title: const Text('Use live time & location'),
              value: _useLiveMode,
              onChanged: (value) {
                setState(() {
                  _useLiveMode = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // -------------------------
            // Manual controls
            // -------------------------
            if (!_useLiveMode) ...[
              const Text(
                'Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              DropdownButton<String>(
                value: _selectedCountry,
                items: _countries
                    .map(
                      (country) => DropdownMenuItem(
                    value: country,
                    child: Text(country),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCountry = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 24),

              const Text(
                'Date & Time',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDateTime
                          .toLocal()
                          .toString(),
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDateTime,
                    child: const Text('Change'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // -------------------------
              // Time scrubber (RESTORED)
              // -------------------------
              const Text(
                'Time Offset',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Slider(
                min: -12,
                max: 12,
                divisions: 48,
                label:
                '${_timeOffsetHours.toStringAsFixed(1)} h',
                value: _timeOffsetHours,
                onChanged: (value) {
                  setState(() {
                    _timeOffsetHours = value;
                    _selectedDateTime =
                        DateTime.now()
                            .toUtc()
                            .add(
                          Duration(
                            minutes:
                            (value * 60).round(),
                          ),
                        );
                  });
                },
              ),

              const SizedBox(height: 16),

              // -------------------------
              // Time speed (RESTORED)
              // -------------------------
              const Text(
                'Time Speed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              DropdownButton<double>(
                value: _timeSpeed,
                items: const [
                  DropdownMenuItem(
                    value: 1.0,
                    child: Text('×1 (Real time)'),
                  ),
                  DropdownMenuItem(
                    value: 10.0,
                    child: Text('×10'),
                  ),
                  DropdownMenuItem(
                    value: 100.0,
                    child: Text('×100'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _timeSpeed = value);
                  ServiceLocator()
                      .timeService
                      .setSpeed(value);
                },
              ),
            ],

            const Spacer(),

            // -------------------------
            // Apply button
            // -------------------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applySelection,
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
