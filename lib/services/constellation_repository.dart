import 'dart:convert';
import 'package:flutter/services.dart';

/// ConstellationRepository
/// -----------------------
/// Loads and provides constellation line definitions and names.
class ConstellationRepository {
  static const String _assetPath = 'lib/data/constellations.json';

  /// id -> line segments
  final Map<String, List<ConstellationLine>> _constellations = {};

  /// id -> display name
  final Map<String, String> _constellationNames = {};

  /// All known constellation IDs
  Iterable<String> get constellationIds => _constellations.keys;

  /// Load constellation definitions from assets.
  /// Safe to call multiple times.
  Future<void> loadConstellations() async {
    if (_constellations.isNotEmpty) return;

    final jsonString = await rootBundle.loadString(_assetPath);
    final List<dynamic> jsonData = json.decode(jsonString);

    for (final entry in jsonData) {
      final String id = entry['id'] as String;
      final String? name = entry['name'] as String?;

      final List<dynamic> linesJson = entry['lines'] as List<dynamic>;

      final List<ConstellationLine> lines = linesJson.map((line) {
        return ConstellationLine(
          startStarId: line[0] as String,
          endStarId: line[1] as String,
        );
      }).toList();

      _constellations[id] = lines;

      if (name != null && name.isNotEmpty) {
        _constellationNames[id] = name;
      }
    }
  }

  /// Get line definitions for a constellation.
  List<ConstellationLine> getLinesForConstellation(String constellationId) {
    return List.unmodifiable(
      _constellations[constellationId] ?? const [],
    );
  }

  /// Get human-readable constellation name.
  /// Falls back to ID if name is missing.
  String getConstellationName(String constellationId) {
    return _constellationNames[constellationId] ?? constellationId;
  }

  /// For constellation picker UI
  Map<String, String> get allConstellations =>
      Map.unmodifiable(_constellationNames);
}

/// Represents a single constellation line segment.
class ConstellationLine {
  final String startStarId;
  final String endStarId;

  const ConstellationLine({
    required this.startStarId,
    required this.endStarId,
  });
}
