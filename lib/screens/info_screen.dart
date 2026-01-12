import 'package:flutter/material.dart';
import '../models/star.dart';

/// InfoScreen
/// ----------
/// Displays educational information about a tapped object.
///
/// Responsibilities:
/// - Present star information
/// - No logic, no state mutation
class InfoScreen extends StatelessWidget {
  final Star star;

  const InfoScreen({
    super.key,
    required this.star,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(star.id),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Right Ascension', '${star.ra}°'),
            _infoRow('Declination', '${star.dec}°'),
            _infoRow('Magnitude', star.magnitude.toString()),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label)),
          Text(value),
        ],
      ),
    );
  }
}
