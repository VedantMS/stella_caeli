import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/star.dart';

/// StarCatalogService
/// ------------------
/// Loads and provides access to the star catalog.
///
/// Responsibilities:
/// - Load star data from JSON assets
/// - Parse into Star model objects
/// - Provide read-only access to star list
///
/// Non-responsibilities:
/// - No filtering
/// - No astronomy math
/// - No UI concerns
class StarCatalogService {
  static const String _assetPath = 'lib/data/stars.json';

  List<Star> _stars = [];

  /// Load the star catalog from assets.
  ///
  /// This should be called once during initialization.
  Future<List<Star>> loadCatalog() async {
    if (_stars.isNotEmpty) {
      return _stars;
    }

    final jsonString = await rootBundle.loadString(_assetPath);
    final List<dynamic> jsonData = json.decode(jsonString);

    _stars = jsonData.map((e) => Star.fromJson(e)).toList();
    return _stars;
  }

  /// Return the loaded star catalog.
  ///
  /// Assumes [loadCatalog] has already been called.
  List<Star> getStars() {
    return List.unmodifiable(_stars);
  }
}
