import 'package:flutter/material.dart';

import '../core/service_locator.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ServiceLocator().settingsController;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Live Time'),
            subtitle: const Text('Use system clock'),
            onChanged: (enabled) {
              enabled
                  ? controller.enableLiveTime()
                  : controller.disableLiveTime();
            },
            value: false, // UI state can be refined later
          ),
          SwitchListTile(
            title: const Text('GPS Location'),
            subtitle: const Text('Use device location'),
            onChanged: (enabled) {
              enabled
                  ? controller.enableGps()
                  : controller.disableGps();
            },
            value: false,
          ),
        ],
      ),
    );
  }
}
