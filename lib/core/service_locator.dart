import '../controllers/settings_controller.dart';
import '../controllers/sky_controller.dart';

import '../models/sky_state.dart';

import '../services/astronomy_engine.dart';
import '../services/constellation_repository.dart';
import '../services/location_service.dart';
import '../services/orientation_service.dart';
import '../services/projection_service.dart';
import '../services/star_catalog_service.dart';
import '../services/time_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final SkyState skyState;

  late final AstronomyEngine astronomyEngine;
  late final OrientationService orientationService;
  late final ProjectionService projectionService;
  late final StarCatalogService starCatalogService;
  late final ConstellationRepository constellationRepository;
  late final TimeService timeService;
  late final LocationService locationService;

  late final SkyController skyController;
  late final SettingsController settingsController;

  Future<void> init() async {
    // Services first (no dependencies)
    timeService = TimeService();
    locationService = LocationService();
    astronomyEngine = AstronomyEngine();
    projectionService = ProjectionService();
    starCatalogService = StarCatalogService();

    constellationRepository = ConstellationRepository();
    await constellationRepository.loadConstellations(); // ✅ SAFE now

    orientationService = OrientationService(locationService);

    // State
    skyState = SkyState(
      time: DateTime.now().toUtc(),
      location: const GeoLocation(latitude: 20.59, longitude: 78.96),
      orientation: const OrientationData(
        azimuth: 0.0,
        altitude: 0.0,
        northAzimuth: 0.0,
      ),
    );

    // Controllers
    skyController = SkyController(
      skyState: skyState,
      astronomyEngine: astronomyEngine,
      orientationService: orientationService,
      projectionService: projectionService,
      starCatalogService: starCatalogService,
      constellationRepository: constellationRepository,
      locationService: locationService,
    );

    settingsController = SettingsController(
      skyState: skyState,
      timeService: timeService,
      locationService: locationService,
      skyController: skyController,
    );
  }
}
