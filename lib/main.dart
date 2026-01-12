import 'package:flutter/material.dart';
import 'package:stella_caeli/screens/sky_view_screen.dart';
import 'core/service_locator.dart';

Future<void> main () async {
  WidgetsFlutterBinding.ensureInitialized();

  await ServiceLocator().init();

  //await ServiceLocator()
  //    .settingsController
  //    .restoreLastSettings();

  runApp(const StellaCaeliApp());


}

class StellaCaeliApp extends StatelessWidget {
  const StellaCaeliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SkyViewScreen(),
    );
  }
}
