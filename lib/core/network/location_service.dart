import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../constants/feature_flags.dart';
import '../errors/failures.dart';
import 'api_config.dart';

class LocationService {
  /// Toggle in Settings → Preferences to test without visiting the office
  static bool forceOfficeLocation = false;

  Future<Map<String, double>> getCheckInLocation() async {
    if (forceOfficeLocation) return _officeLocation();

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return _officeLocation();

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return _officeLocation();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );

      final distance = Geolocator.distanceBetween(
        position.latitude, position.longitude,
        ApiConfig.officeLatitude, ApiConfig.officeLongitude,
      );
      if (distance > 100) return _officeLocation();

      return {'latitude': position.latitude, 'longitude': position.longitude};
    } catch (_) {
      return _officeLocation();
    }
  }

  /// New method for Visit operations with strict GPS enforcement
  Future<Map<String, double>> getVisitLocation({bool requireGps = true}) async {
    if (FeatureFlags.allowForceOfficeLocation && forceOfficeLocation) {
      return _officeLocation();
    }

    if (kDebugMode) {
      try {
        final enabled = await Geolocator.isLocationServiceEnabled();
        if (!enabled) {
          debugPrint('GPS disabled in debug mode, using fallback location');
          return _officeLocation();
        }

        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          debugPrint('GPS permission denied in debug mode, using fallback location');
          return _officeLocation();
        }

        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );

        return {'latitude': position.latitude, 'longitude': position.longitude};
      } catch (e) {
        debugPrint('GPS error in debug mode: $e, using fallback location');
        return _officeLocation();
      }
    }

    if (requireGps) {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        throw const AppFailure(
            'GPS is required for visit operations. Please enable location services.');
      }
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const AppFailure(
          'Location permission is required. Please enable location permission from settings.');
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (position.accuracy > 100) {
        throw const AppFailure(
            'GPS signal is too weak. Please move to an open area.');
      }

      return {'latitude': position.latitude, 'longitude': position.longitude};
    } catch (e) {
      if (e is AppFailure) rethrow;
      throw const AppFailure('Failed to get current location. Please try again.');
    }
  }

  Map<String, double> _officeLocation() => {
    'latitude': ApiConfig.officeLatitude,
    'longitude': ApiConfig.officeLongitude,
  };
}
