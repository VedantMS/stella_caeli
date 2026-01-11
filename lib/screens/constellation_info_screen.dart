import 'package:flutter/material.dart';

/// ConstellationInfoScreen
/// ----------------------
/// Displays educational information about a constellation.
class ConstellationInfoScreen extends StatelessWidget {
  final String id;

  const ConstellationInfoScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(id),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Constellation Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Historical background, mythology, and '
                  'astronomical details can be added here.',
            ),
          ],
        ),
      ),
    );
  }
}
